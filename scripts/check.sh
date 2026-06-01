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
#   3. walk up for safe-code markers (AGENTS.md / .agents/) when not in git
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
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.agents" ]; then
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
[ -f CHANGELOG.md ] && pass "CHANGELOG.md present" || warn "CHANGELOG.md missing"
echo

# ---- 2. context/ project brain ----------------------------------------------
echo "context/ project brain"
if [ -d context ]; then
	pass "context/ present"
	for f in project-overview architecture user-preferences code-standards \
		ai-workflow-rules ui-context progress-tracker; do
		[ -f "context/$f.md" ] && pass "context/$f.md" || warn "context/$f.md missing"
	done
	[ -d context/feature-specs ] && pass "context/feature-specs/" ||
		warn "context/feature-specs/ missing"
else
	warn "context/ missing (run /safe-code to scaffold)"
fi
echo

# ---- 3. .agents/ session state ----------------------------------------------
echo ".agents/ session state"
if [ -d .agents ]; then
	pass ".agents/ present"
	for f in ACTIVE SESSION LOG BACKLOG MEMORY safe-refactor-code; do
		[ -f ".agents/$f.md" ] && pass ".agents/$f.md" || warn ".agents/$f.md missing"
	done
	# stale SESSION.md: working memory is meant to be wiped on --save.
	if [ -f .agents/SESSION.md ]; then
		if find .agents/SESSION.md -mtime +7 >/dev/null 2>&1 &&
			[ -n "$(find .agents/SESSION.md -mtime +7 2>/dev/null)" ]; then
			warn ".agents/SESSION.md not touched in 7+ days (stale? run /safe-code --save)"
		fi
	fi
else
	warn ".agents/ missing (run /safe-code to scaffold)"
fi
# legacy layout detection
for legacy in .codex/agents .claude/agents .cursor/agents .windsurf/agents .codex/memory; do
	if [ -d "$legacy" ]; then
		warn "legacy session folder '$legacy' found — move its *.md into .agents/ (v3.0)"
	fi
done
echo

# ---- 4. current-issues.md must stay local (HARD) ----------------------------
echo "current-issues.md (local-only, gitignored)"
if [ -f context/current-issues.md ]; then
	if git_tracked context/current-issues.md; then
		fail "context/current-issues.md is COMMITTED to git — it may contain secrets/logs. Run: git rm --cached context/current-issues.md"
	else
		pass "context/current-issues.md present and not tracked"
	fi
fi
if [ -f .gitignore ] && grep -qE '(^|/)context/current-issues\.md' .gitignore; then
	pass ".gitignore covers context/current-issues.md"
else
	if [ -f context/current-issues.md ] || [ -d context ]; then
		warn "add '/context/current-issues.md' to .gitignore"
	fi
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
