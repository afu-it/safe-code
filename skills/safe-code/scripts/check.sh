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
# Ships inside the skill (<skill-dir>/scripts/check.sh); the skill's source
# repo keeps a root shim at scripts/check.sh.
#
# Usage:
#   bash <skill-dir>/scripts/check.sh [project-root]
#
set -u

# sibling scripts (migrate.sh) live next to this one
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
HARD=0 # hard checks run (counted, never hard-coded)

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
# Unified rule (same as save-reminder.sh), so the check never escapes the
# project it is run inside:
#   1. explicit arg
#   2. nearest dir holding .safe-code/, walking up from cwd but never above the
#      git toplevel (a monorepo package with its own brain wins over the root)
#   3. git toplevel (natural project boundary)
#   4. outside git: walk up for safe-code markers (AGENTS.md / .safe-code/ /
#      legacy .agents/ session files)
#   5. current directory
find_root() {
	if [ "${1:-}" != "" ] && [ -d "$1" ]; then
		(cd "$1" && pwd)
		return
	fi
	local dir top=""
	dir="$(pwd -P)"
	command -v git >/dev/null 2>&1 && top="$(git rev-parse --show-toplevel 2>/dev/null)"
	if [ -n "$top" ]; then
		while :; do
			if [ -d "$dir/.safe-code" ]; then
				echo "$dir"
				return
			fi
			if [ "$dir" = "$top" ] || [ "$dir" = "/" ]; then
				break
			fi
			dir="$(dirname "$dir")"
		done
		echo "$top"
		return
	fi
	while [ "$dir" != "/" ]; do
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.safe-code" ] || [ -f "$dir/.agents/ACTIVE.md" ] ||
			[ -f "$dir/.agents/SESSION.md" ]; then
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
# created lazily on the first releasable change, so absence is not a warning
[ -f .safe-code/CHANGELOG.md ] && pass ".safe-code/CHANGELOG.md present" ||
	info ".safe-code/CHANGELOG.md not created yet (written on the first releasable change)"
echo

# ---- 2. .safe-code/context/ project brain ------------------------------------
echo ".safe-code/context/ project brain"
if [ -d .safe-code/context ]; then
	pass ".safe-code/context/ present"
	for f in project-overview architecture user-preferences code-standards \
		ai-workflow-rules progress-tracker; do
		[ -f ".safe-code/context/$f.md" ] && pass "context/$f.md" || warn "context/$f.md missing"
	done
	# created lazily on the first UI work, so absence is not a warning
	[ -f .safe-code/context/ui-context.md ] && pass "context/ui-context.md" ||
		info "context/ui-context.md not created yet (written on the first UI work)"
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
# legacy layout detection (pre-v3 per-agent dirs + v3 .agents/ + v3 root context/).
# Same rule as migrate.sh: a folder is legacy only when it holds safe-code session
# files AND carries a marker (ACTIVE.md / SESSION.md / safe-refactor-code.md in
# it, or a project-level marker). .claude/agents/ subagents and .agents/skills/
# are standard host folders, never legacy on their own.
V3_GITIGNORE=0
if [ -f .gitignore ] && grep -qE '^/?context/current-issues\.md' .gitignore; then
	V3_GITIGNORE=1
fi
PROJECT_MARKER=0
if [ -d .safe-code ] || [ "$V3_GITIGNORE" -eq 1 ] ||
	{ [ -f AGENTS.md ] && grep -qi 'safe-code' AGENTS.md; }; then
	PROJECT_MARKER=1
fi
# exact-case match (a case-insensitive filesystem would let MEMORY.md match a
# subagent's memory.md) and not a subagent/skill file (`---` frontmatter line 1)
has_file() { # has_file <dir> <name>
	[ -f "$1/$2" ] && [ -n "$(find "$1" -mindepth 1 -maxdepth 1 -type f -name "$2" 2>/dev/null)" ]
}
is_session_file() { # is_session_file <dir> <name>
	local first=""
	has_file "$1" "$2" || return 1
	IFS= read -r first <"$1/$2" || [ -n "$first" ] || return 0
	[ "${first%$'\r'}" != "---" ]
}
is_legacy_dir() { # is_legacy_dir <dir>
	local d="$1" f has=0
	[ -d "$d" ] || return 1
	for f in ACTIVE SESSION LOG BACKLOG MEMORY safe-refactor-code; do
		is_session_file "$d" "$f.md" && has=1
	done
	[ "$has" -eq 1 ] || return 1
	for f in ACTIVE SESSION safe-refactor-code; do
		is_session_file "$d" "$f.md" && return 0
	done
	[ "$PROJECT_MARKER" -eq 1 ]
}
for legacy in .codex/agents .claude/agents .cursor/agents .windsurf/agents \
	.codex/memory .claude/memory .cursor/memory .windsurf/memory .agents; do
	if is_legacy_dir "$legacy"; then
		warn "legacy safe-code session files in '$legacy/' — run 'bash $SCRIPT_DIR/migrate.sh --apply' (moves only safe-code's files)"
	fi
done
# root context/ is v3 safe-code only with the v3 .gitignore entry, or with
# progress-tracker.md plus a project-level marker (same rule as migrate.sh)
if [ -d context ] && { [ "$V3_GITIGNORE" -eq 1 ] ||
	{ has_file context progress-tracker.md && [ "$PROJECT_MARKER" -eq 1 ]; }; }; then
	warn "legacy v3 root context/ found — run 'bash $SCRIPT_DIR/migrate.sh --apply' (moves only safe-code's context files)"
fi
echo

# ---- 4. current-issues.md must stay local (HARD) ----------------------------
echo "current-issues.md (local-only, gitignored)"
HARD=$((HARD + 1))
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
# brain tracking (advisory) — same detection as SKILL.md (Local-Only Brain):
# .gitignore patterns name .safe-code/ or its context/ (--no-index, so a still-
# tracked brain counts too; a .safe-code/* pattern catches both); a still-tracked
# one also needs git rm -r --cached. Ignoring only the per-developer session files
# is team mode (section 4e), not a local-only brain.
LOCAL_ONLY=0
if [ -d .safe-code ] && is_git; then
	if git check-ignore -q --no-index .safe-code/ 2>/dev/null ||
		git check-ignore -q --no-index .safe-code/context/ 2>/dev/null; then
		LOCAL_ONLY=1
		info "Brain: local-only (gitignored) — --save commits code and scaffold changes only"
		if [ -n "$(git ls-files .safe-code 2>/dev/null)" ]; then
			info ".gitignore names .safe-code/ but files under it are still tracked — to finish making the brain local-only run: git rm -r --cached .safe-code"
		fi
	fi
fi
# local-only paths (advisory): dated pre-rewrite backups and the save stamp
# (git keeps no mtimes, so a committed .last-save carries nothing)
if [ -d .safe-code ] && is_git; then
	for p in .safe-code/backups/ .safe-code/.last-save; do
		if [ -n "$(git ls-files "$p" 2>/dev/null)" ]; then
			warn "$p is tracked by git — it is local-only; add '/$p' to .gitignore and git rm -r --cached it"
		elif [ -e "$p" ] && ! git check-ignore -q "$p" 2>/dev/null; then
			warn "add '/$p' to .gitignore (local-only)"
		fi
	done
fi
echo

# ---- 4b. provider bridges (advisory) ----------------------------------------
echo "Provider bridges (auto-load context in other hosts)"
if [ -f AGENTS.md ]; then
	# AGENTS.md is the only required output. Claude Code reads it natively unless a
	# CLAUDE.md / CLAUDE.local.md exists here or in ANY parent, so safe-code writes a
	# CLAUDE.md bridge when it runs under Claude Code. Every other host reads AGENTS.md
	# natively (Gemini CLI via a printed .gemini/settings.json snippet) — no other bridge
	# is expected, so an absent one is never a warning.
	if [ ! -f CLAUDE.md ] && [ -f CLAUDE.local.md ]; then
		if grep -qE 'safe-code:bridge|AGENTS\.md|\.safe-code' CLAUDE.local.md 2>/dev/null; then
			pass "CLAUDE.local.md points at AGENTS.md/.safe-code"
		else
			warn "CLAUDE.local.md exists without CLAUDE.md — Claude Code then skips AGENTS.md; add '@AGENTS.md' to it"
		fi
	fi
	if [ -f CLAUDE.md ]; then
		if grep -qE 'safe-code:bridge|AGENTS\.md|\.safe-code' CLAUDE.md 2>/dev/null; then
			pass "CLAUDE.md points at AGENTS.md/.safe-code"
		else
			warn "CLAUDE.md exists but does not import AGENTS.md — Claude Code skips AGENTS.md when a CLAUDE.md exists; add '@AGENTS.md'"
		fi
	else
		info "CLAUDE.md not present (written only when safe-code runs under Claude Code; needed when a CLAUDE.md exists above the project)"
	fi
	# bridges written by earlier versions: recognised when present, never expected
	for b in "GEMINI.md" ".github/copilot-instructions.md" ".cursor/rules/safe-code.mdc" ".clinerules/safe-code.md"; do
		if [ -f "$b" ] && grep -qE 'safe-code:bridge|AGENTS\.md|\.safe-code' "$b" 2>/dev/null; then
			pass "$b points at AGENTS.md/.safe-code (older bridge, left in place)"
		fi
	done
	if [ -f GEMINI.md ] && ! grep -qs 'AGENTS\.md' .gemini/settings.json; then
		if ! grep -qE 'safe-code:bridge|AGENTS\.md|\.safe-code' GEMINI.md 2>/dev/null; then
			info "GEMINI.md does not point at AGENTS.md — for Gemini CLI add {\"context\":{\"fileName\":[\"AGENTS.md\",\"GEMINI.md\"]}} to .gemini/settings.json"
		fi
	fi
else
	info "AGENTS.md missing — skipping bridge checks"
fi
echo

# ---- 4c. brain size budget (advisory) ----------------------------------------
# The project brain can itself become the bloat: every session reads AGENTS.md and
# the context docs, so they carry a budget (references/agents-md-authoring.md,
# Brain Budget). Over budget -> the next --save prunes stale/superseded facts into
# LOG history. current-issues.md (local, read on request) and feature specs are
# not part of the always-read budget.
echo "Brain size budget (advisory)"
BLOAT=0
if [ -d .safe-code/context ]; then
	BRAIN_LINES=0
	BIGGEST=""
	BIGGEST_N=0
	for f in .safe-code/context/*.md; do
		[ -f "$f" ] || continue
		[ "$f" = ".safe-code/context/current-issues.md" ] && continue
		[ "$f" = ".safe-code/context/user-preferences.local.md" ] && continue
		n=$(wc -l <"$f" | tr -d ' ')
		BRAIN_LINES=$((BRAIN_LINES + n))
		if [ "$n" -gt "$BIGGEST_N" ]; then
			BIGGEST_N=$n
			BIGGEST=$f
		fi
	done
	if [ "$BRAIN_LINES" -gt 300 ]; then
		warn "Brain: $BRAIN_LINES lines (budget 300) in .safe-code/context/*.md — largest $BIGGEST ($BIGGEST_N); next --save prunes stale/superseded facts into LOG history"
		BLOAT=1
	else
		pass "Brain: $BRAIN_LINES lines (budget 300)"
	fi
fi
if [ -f AGENTS.md ]; then
	n=$(wc -l <AGENTS.md | tr -d ' ')
	if [ "$n" -gt 120 ]; then
		warn "AGENTS.md is $n lines (budget 120) — move detail into .safe-code/context/ or a nested package AGENTS.md"
		BLOAT=1
	fi
fi
if [ -f .safe-code/LOG.md ]; then
	lines=$(wc -l <.safe-code/LOG.md | tr -d ' ')
	if [ "$lines" -gt 300 ]; then
		warn ".safe-code/LOG.md is $lines lines (>300) — LOG Trim Rule should compress on next --save"
		BLOAT=1
	fi
fi
[ "$BLOAT" -eq 0 ] && pass "AGENTS.md and LOG within size budget"
echo

# ---- 4e. team mode (advisory) ------------------------------------------------
# references/team-mode.md: >1 human author in 90 days (bots excluded), or
# `team: on|off` in user-preferences.md, switches team mode. In team mode the
# brain (AGENTS.md, context/, BACKLOG.md) is committed and the per-developer
# session files are gitignored. safe-code never runs git rm --cached; it prints it.
if [ -d .safe-code ] && is_git; then
	echo "Team mode (advisory)"
	if [ "$LOCAL_ONLY" -eq 1 ]; then
		info "Team: n/a (brain is local-only — nothing of it is committed)"
	else
		AUTHORS="$(git log --since=90.days --format='%ae' 2>/dev/null | tr '[:upper:]' '[:lower:]' |
			grep -vE '\[bot\]|^(noreply|action|actions)@github\.com$' | sort -u | grep -c .)"
		TEAM_PREF="$(sed -nE 's/^[[:space:]]*[-*]?[[:space:]]*team:[[:space:]]*(on|off)([^[:alnum:]].*)?$/\1/p' \
			.safe-code/context/user-preferences.md 2>/dev/null | head -n 1)"
		if [ -n "$TEAM_PREF" ]; then
			TEAM="$TEAM_PREF"
			info "Team: $TEAM ($AUTHORS authors, 90d; set by user-preferences.md)"
		elif [ "$AUTHORS" -gt 1 ]; then
			TEAM=on
			info "Team: on ($AUTHORS authors, 90d)"
		else
			TEAM=off
			info "Team: off ($AUTHORS author, 90d)"
		fi
		TEAM_ISSUES=0
		for f in ACTIVE SESSION LOG MEMORY safe-refactor-code; do
			p=".safe-code/$f.md"
			if [ "$TEAM" = on ]; then
				if git_tracked "$p"; then
					if git check-ignore -q --no-index "$p" 2>/dev/null; then
						warn "$p is still committed (team mode: per-developer file) — run: git rm --cached $p"
					else
						warn "$p is committed (team mode: per-developer file) — add '/$p' to .gitignore, then run: git rm --cached $p"
					fi
					TEAM_ISSUES=1
				elif [ -e "$p" ] && ! git check-ignore -q "$p" 2>/dev/null; then
					warn "add '/$p' to .gitignore (team mode: per-developer session file)"
					TEAM_ISSUES=1
				fi
			elif [ -e "$p" ] && git check-ignore -q "$p" 2>/dev/null; then
				info "$p is gitignored while team mode is off — fine if intended (set 'team: on' to make it explicit)"
				TEAM_ISSUES=1
			fi
		done
		# per-developer preferences (references/team-mode.md): user-preferences.local.md
		# holds one developer's Git Identity / diary_path and is never committed.
		LP=".safe-code/context/user-preferences.local.md"
		if [ -e "$LP" ]; then
			if git_tracked "$LP"; then
				warn "$LP is committed (per-developer values) — add '/$LP' to .gitignore, then run: git rm --cached $LP"
				TEAM_ISSUES=1
			elif ! git check-ignore -q "$LP" 2>/dev/null; then
				warn "add '/$LP' to .gitignore (per-developer preferences)"
				TEAM_ISSUES=1
			fi
		fi
		if [ "$TEAM" = on ] && [ -f .safe-code/context/user-preferences.md ]; then
			# field names only — never print the value (an email or a home path)
			PERSONAL="$(awk '/^## /{sec=$0}
				(sec=="## Git Identity" || sec=="## Save Bridge") &&
				/^[[:space:]]*[-*][[:space:]]*(name|email|diary_path):[[:space:]]*[^-<[:space:]]/ {
					sub(/^[[:space:]]*[-*][[:space:]]*/, ""); sub(/:.*/, ""); printf "%s ", $0 }' \
				.safe-code/context/user-preferences.md 2>/dev/null)"
			if [ -n "$PERSONAL" ]; then
				warn "team mode: user-preferences.md sets personal field(s) ${PERSONAL% } — move them to $LP (gitignored)"
				TEAM_ISSUES=1
			fi
		fi
		if [ "$TEAM" = on ] && [ -d .safe-code/context ] && [ -z "$(git ls-files .safe-code/context 2>/dev/null)" ]; then
			info "team mode: .safe-code/context/ is not committed yet — the next --save commits it so teammates share the brain"
			TEAM_ISSUES=1
		fi
		[ "$TEAM_ISSUES" -eq 0 ] && pass "session files match team mode ($TEAM)"
	fi
	echo
fi

# ---- 4f. nested AGENTS.md (monorepo packages, advisory) ---------------------
# references/monorepo.md: a package may carry its own AGENTS.md (<= 40 lines,
# package-local commands + gotchas), linked from the root AGENTS.md.
NESTED="$(find . -mindepth 1 -maxdepth 5 \( -name .git -o -name node_modules -o -name .safe-code \
	-o -name vendor -o -name target -o -name dist -o -name build -o -name .venv \) -prune -o \
	-type f -name AGENTS.md -print 2>/dev/null | sed 's|^\./||' | grep '/' | sort | head -n 50)"
if [ -n "$NESTED" ]; then
	echo "Nested AGENTS.md (advisory)"
	while IFS= read -r nf; do
		[ -n "$nf" ] || continue
		n=$(wc -l <"$nf" | tr -d ' ')
		if [ "$n" -gt 40 ]; then
			warn "$nf is $n lines (budget 40) — keep package-local commands and gotchas only"
		else
			pass "$nf ($n lines)"
		fi
		if [ -f AGENTS.md ] && ! grep -qF "$(dirname "$nf")/" AGENTS.md 2>/dev/null; then
			warn "root AGENTS.md does not link $nf"
		fi
	done <<NESTED_EOF
$NESTED
NESTED_EOF
	echo
fi

# ---- 4d. codegraph index (advisory) -----------------------------------------
# .codegraph/ is a local index; it self-gitignores ('*' + '!.gitignore') and only
# its .gitignore may ever be tracked. Older graph dirs are unused now: report, never delete.
if [ -d .codegraph ] || [ -d .code-review-graph ] || [ -d graphify-out ]; then
	echo "Graph index (advisory)"
	if [ -d .codegraph ]; then
		if command -v git >/dev/null 2>&1 && [ -n "$(git ls-files .codegraph 2>/dev/null | grep -v '^\.codegraph/\.gitignore$')" ]; then
			warn ".codegraph/ index files are tracked by git — keep '.codegraph/.gitignore' (it ignores the rest) and git rm --cached the others"
		else
			pass ".codegraph/ present and not tracked"
		fi
	fi
	for d in .code-review-graph graphify-out; do
		[ -d "$d" ] && info "$d/ is a legacy graph dir, unused now (safe-code uses codegraph) — left in place; delete it yourself if you like"
	done
	echo
fi

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
	printf "%s%d hard check(s) passed%s, %s%d warning(s)%s\n" "$C_OK" "$HARD" "$C_RST" "$C_WARN" "$WARNS" "$C_RST"
	printf "%sResult: OK%s\n" "$C_OK" "$C_RST"
	exit 0
else
	printf "%s%d failure(s)%s, %s%d warning(s)%s\n" "$C_ERR" "$FAILS" "$C_RST" "$C_WARN" "$WARNS" "$C_RST"
	printf "%sResult: FAILED%s\n" "$C_ERR" "$C_RST"
	exit 1
fi
