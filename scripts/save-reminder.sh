#!/usr/bin/env bash
#
# safe-code save-reminder — warn (do NOT save) when a session has unsaved
# safe-code work, so you never lose context by forgetting `/safe-code --save`.
#
# Designed to be wired into a host "session end" / Stop hook (opt-in). It never
# commits, never saves, never blocks — it only prints a one-line nudge. See
# integrations/claude-code/hooks.example.json for Claude Code wiring.
#
# Exit code is always 0: a reminder must never fail or block ending a session.
#
# Usage:
#   bash scripts/save-reminder.sh [project-root]
set -u

# ---- locate project root (git toplevel, then arg, then cwd) -----------------
if [ "${1:-}" != "" ] && [ -d "$1" ]; then
	ROOT="$(cd "$1" && pwd)"
elif command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
	ROOT="$(git rev-parse --show-toplevel)"
else
	ROOT="$(pwd)"
fi

# Project does not use safe-code → nothing to remind about.
[ -d "$ROOT/.safe-code" ] || exit 0

unsaved=0

if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
	# Primary signal: uncommitted changes under .safe-code/ — `--save` commits,
	# so anything pending here means the session was not saved.
	if [ -n "$(git -C "$ROOT" status --porcelain -- .safe-code/ 2>/dev/null)" ]; then
		unsaved=1
	fi
else
	# No git: fall back to an actively-in-progress task marker in SESSION.md.
	# Use `[~]` (in progress) only — a clean saved SESSION.md may still carry
	# empty `[ ]` template items, so those would false-positive.
	if [ -f "$ROOT/.safe-code/SESSION.md" ] &&
		grep -qE '^\s*-\s*\[~\]' "$ROOT/.safe-code/SESSION.md" 2>/dev/null; then
		unsaved=1
	fi
fi

if [ "$unsaved" -eq 1 ]; then
	printf '⚠️  safe-code: you have unsaved session work — run `/safe-code --save` before ending.\n' >&2
fi

exit 0
