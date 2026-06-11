#!/usr/bin/env bash
#
# safe-code check — verify safe-code hygiene conventions in the current repo.
#
# Converts safe-code's prompt-only conventions into a checkable contract.
# Run from anywhere inside a project; it walks up to the project root.
#
# Exit codes:
#   0  all hard checks passed (warnings may still print)
#   1  one or more hard checks failed
#
# Usage:
#   bash scripts/check.sh [project-root]
#
set -u

# ---- tiny output helpers (no color if not a tty) ----------------------------
if [ -t 1 ]; then
	C_OK=$'\033[32m'
	C_WARN=$'\033[33m'
	C_ERR=$'\033[31m'
	C_DIM=$'\033[2m'
	C_RST=$'\033[0m'
else
	C_OK=""
	C_WARN=""
	C_ERR=""
	C_DIM=""
	C_RST=""
fi

FAILS=0
WARNS=0

pass() { printf "  %s[ok]%s   %s\n" "$C_OK" "$C_RST" "$1"; }
warn() {
	printf "  %s[warn]%s %s\n" "$C_WARN" "$C_RST" "$1"
	WARNS=$((WARNS + 1))
}
fail() {
	printf "  %s[FAIL]%s %s\n" "$C_ERR" "$C_RST" "$1"
	FAILS=$((FAILS + 1))
}
info() { printf "  %s%s%s\n" "$C_DIM" "$1" "$C_RST"; }

# ---- locate project root ----------------------------------------------------
# Anchor strategy (most reliable first), so the check never escapes the project
# it is run inside:
#   1. explicit arg
#   2. git toplevel (natural project boundary; will not walk past it)
#   3. walk up for safe-code markers (AGENTS.md / .safe-code/ / legacy .agents/)
#   4. current directory
find_root() {
	if [ "${1:-}" != "" ] && [ -d "$1" ]; then
		(cd "$1" && pwd)
		return
	fi
	if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
		git rev-parse --show-toplevel
		return
	fi
	local dir
	dir="$(pwd)"
	while [ "$dir" != "/" ]; do
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.safe-code" ] || [ -d "$dir/.agents" ]; then
			echo "$dir"
			return
		fi
		dir="$(dirname "$dir")"
	done
	pwd
}

ROOT="$(find_root "${1:-}")"
cd "$ROOT" || {
	echo "cannot enter $ROOT"
	exit 1
}

printf "safe-code check\n"
info "project root: $ROOT"
echo

# ---- helpers ----------------------------------------------------------------
is_git() { command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; }

git_tracked() { # is path tracked by git?
	is_git || return 1
	git ls-files --error-unmatch "$1" >/dev/null 2>&1
}

# ---- 1. root entry point ----------------------------------------------------
echo "Root files"
[ -f AGENTS.md ] && pass "AGENTS.md present" || warn "AGENTS.md missing (run /safe-code to scaffold)"
[ -f .safe-code/CHANGELOG.md ] && pass ".safe-code/CHANGELOG.md present" || warn ".safe-code/CHANGELOG.md missing"
echo

# ---- 2. .safe-code/context/ project brain ------------------------------------
echo ".safe-code/context/ project brain"
if [ -d .safe-code/context ]; then
	pass ".safe-code/context/ present"
	for f in project-overview architecture user-preferences code-standards \
		ai-workflow-rules ui-context progress-tracker; do
		[ -f ".safe-code/context/$f.md" ] && pass "context/$f.md" || warn "context/$f.md missing"
	done
	[ -d .safe-code/context/feature-specs ] && pass "context/feature-specs/" ||
		warn "context/feature-specs/ missing"
else
	warn ".safe-code/context/ missing (run /safe-code to scaffold)"
fi
echo

# ---- 3. .safe-code/ session state ---------------------------------------------
echo ".safe-code/ session state"
if [ -d .safe-code ]; then
	pass ".safe-code/ present"
	for f in ACTIVE SESSION LOG BACKLOG MEMORY safe-refactor-code; do
		[ -f ".safe-code/$f.md" ] && pass ".safe-code/$f.md" || warn ".safe-code/$f.md missing"
	done
	# stale SESSION.md: working memory is meant to be wiped on --save.
	if [ -f .safe-code/SESSION.md ]; then
		if find .safe-code/SESSION.md -mtime +7 >/dev/null 2>&1 &&
			[ -n "$(find .safe-code/SESSION.md -mtime +7 2>/dev/null)" ]; then
			warn ".safe-code/SESSION.md not touched in 7+ days (stale? run /safe-code --save)"
		fi
	fi
else
	warn ".safe-code/ missing (run /safe-code to scaffold)"
fi
# legacy layout detection (pre-v3 per-agent dirs + v3 .agents/ + v3 root context/)
for legacy in .codex/agents .claude/agents .cursor/agents .windsurf/agents .codex/memory .agents; do
	if [ -d "$legacy" ]; then
		warn "legacy session folder '$legacy' found — run 'bash scripts/migrate.sh --apply' (v4.0)"
	fi
done
if [ -d context ] && [ -f context/progress-tracker.md ]; then
	warn "legacy v3 root context/ found — run 'bash scripts/migrate.sh --apply' (v4.0)"
fi
echo

# ---- 4. current-issues.md must stay local (HARD) ----------------------------
echo "current-issues.md (local-only, gitignored)"
if [ -f .safe-code/context/current-issues.md ]; then
	if git_tracked .safe-code/context/current-issues.md; then
		fail ".safe-code/context/current-issues.md is COMMITTED to git — it may contain secrets/logs. Run: git rm --cached .safe-code/context/current-issues.md"
	else
		pass ".safe-code/context/current-issues.md present and not tracked"
	fi
fi
if [ -f .gitignore ] && grep -qE '(^|/)\.safe-code/context/current-issues\.md' .gitignore; then
	pass ".gitignore covers .safe-code/context/current-issues.md"
else
	if [ -f .safe-code/context/current-issues.md ] || [ -d .safe-code/context ]; then
		warn "add '/.safe-code/context/current-issues.md' to .gitignore"
	fi
fi
echo

# ---- 4b. provider bridges (advisory) ----------------------------------------
echo "Provider bridges (auto-load context in other hosts)"
if [ -f AGENTS.md ]; then
	for b in "CLAUDE.md" "GEMINI.md" ".github/copilot-instructions.md" ".cursor/rules/safe-code.mdc"; do
		if [ -f "$b" ]; then
			if grep -qE 'safe-code:bridge|AGENTS\.md|\.safe-code' "$b" 2>/dev/null; then
				pass "$b points at AGENTS.md/.safe-code"
			else
				warn "$b exists but does not reference AGENTS.md/.safe-code"
			fi
		else
			info "$b not present (lazy — written when safe-code runs under that host)"
		fi
	done
else
	info "AGENTS.md missing — skipping bridge checks"
fi
echo

# ---- 5. light hygiene scan --------------------------------------------------
echo "Hygiene"
tmp_hits="$(find . -path ./.git -prune -o \
	\( -name '*.tmp' -o -name '*.bak' -o -name '*.orig' -o -name '*~' \) -print 2>/dev/null | head -20)"
if [ -n "$tmp_hits" ]; then
	warn "temp/scratch files present:"
	printf '%s\n' "$tmp_hits" | sed 's/^/         /'
else
	pass "no obvious temp/scratch files"
fi
echo

# ---- summary ----------------------------------------------------------------
printf "Summary: "
if [ "$FAILS" -eq 0 ]; then
	printf "%s%d passed-as-hard%s, %s%d warning(s)%s\n" "$C_OK" 1 "$C_RST" "$C_WARN" "$WARNS" "$C_RST"
	printf "%sResult: OK%s\n" "$C_OK" "$C_RST"
	exit 0
else
	printf "%s%d failure(s)%s, %s%d warning(s)%s\n" "$C_ERR" "$FAILS" "$C_RST" "$C_WARN" "$WARNS" "$C_RST"
	printf "%sResult: FAILED%s\n" "$C_ERR" "$C_RST"
	exit 1
fi
