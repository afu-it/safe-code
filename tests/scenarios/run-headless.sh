#!/usr/bin/env bash
#
# OPTIONAL: run one scenario prompt headless with Claude Code (`claude -p`).
# Costs tokens on your own account. Never run in CI. You can always run the
# scenarios by hand in an interactive session instead (see README.md).
#
# Usage:
#   bash tests/scenarios/run-headless.sh [--install-skill] <base> "<prompt>" [-- <claude args>]
#
#   <base>           the dir build-fixture.sh printed
#   "<prompt>"       the exact prompt from scenarios.md, e.g. "/safe-code"
#   --install-skill  copy this repo's working-tree skills/ into <base>/repo/.claude/skills/
#                    (hidden from git via .git/info/exclude) so the run tests the
#                    unreleased version; do it before the first scenario and before
#                    any `assert.sh --snapshot`. Without it, the installed skill is used.
#   -- <args>        replace the default claude flags below
#
# Default flags: --permission-mode acceptEdits, an allow-list of read/edit tools and
# git/bash/ls/grep/find shell commands, JSON output. `git push` is NOT blocked on
# purpose: origin.git is a local bare repo, so a push is harmless and assert.sh A4
# catches it. The transcript lands in <base>/logs/. Then run assert.sh.
set -u

HERE="$(cd "$(dirname "$0")" && pwd -P)"
INSTALL=0
if [ "${1:-}" = "--install-skill" ]; then
	INSTALL=1
	shift
fi
BASE="${1:-}"
PROMPT="${2:-}"
[ -n "$BASE" ] && [ -f "$BASE/baseline.vars" ] && [ -n "$PROMPT" ] || {
	sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
	exit 2
}
shift 2
if ! command -v claude >/dev/null 2>&1; then
	echo "claude CLI not found on PATH - run the scenario by hand instead (README.md)" >&2
	exit 2
fi
BASE="$(cd "$BASE" && pwd -P)"
R="$BASE/repo"

if [ "$INSTALL" -eq 1 ]; then
	mkdir -p "$R/.claude/skills"
	cp -R "$HERE/../../skills/." "$R/.claude/skills/"
	grep -qx '/.claude/skills/' "$R/.git/info/exclude" 2>/dev/null ||
		printf '/.claude/skills/\n' >>"$R/.git/info/exclude"
	echo "installed working-tree skills into $R/.claude/skills/ (git-excluded)"
fi

if [ "${1:-}" = "--" ]; then
	shift
else
	set -- --permission-mode acceptEdits \
		--allowedTools "Read Edit Write Glob Grep Bash(git:*) Bash(bash:*) Bash(ls:*) Bash(grep:*) Bash(find:*) Bash(cat:*) Bash(wc:*)" \
		--output-format json
fi

mkdir -p "$BASE/logs"
slug="$(printf '%s' "$PROMPT" | tr -c 'A-Za-z0-9' '-' | sed 's/--*/-/g; s/^-//; s/-$//' | cut -c1-40)"
LOG="$BASE/logs/$(date +%Y%m%d-%H%M%S)-${slug:-run}.json"

echo "running in $R: claude -p \"$PROMPT\" $*"
(cd "$R" && claude -p "$PROMPT" "$@") >"$LOG" 2>&1
rc=$?
echo "claude exit $rc; transcript: $LOG"
echo "next: bash $HERE/assert.sh $BASE <flags from scenarios.md>"
exit "$rc"
