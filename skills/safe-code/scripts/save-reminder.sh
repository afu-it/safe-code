#!/usr/bin/env bash
#
# safe-code session hook — brief + save reminder. At session start it (1) hands
# the agent a short brief of the project brain (<= 15 lines) and (2) tells the
# user (does NOT save) when the previous session left safe-code work unsaved,
# so context is never lost by forgetting `/safe-code --save`.
#
# Designed for a host "session start" hook (opt-in). In Claude Code wire it as a
# SessionStart hook: it prints one JSON object on stdout —
#   hookSpecificOutput.additionalContext  the brief (added to the agent's context)
#   systemMessage                         the unsaved notice (shown to the user;
#                                         present only when work is unsaved)
# See integrations/claude-code/. It never commits, never saves, never blocks,
# never touches the network: exit code is always 0, and it prints nothing at all
# when there is no .safe-code/ brain (or, with --no-brief, nothing to report).
#
# The brief reads only: the AGENTS.md project line (or the project-overview.md
# Overview line), ACTIVE.md Last Session `next_action:`/`saved_at:`,
# progress-tracker.md Open Questions + `last_synced_commit:`, and git history
# names. Never current-issues.md, never SESSION.md content (only its markers).
#
# "Unsaved" means:
#   - local-only brain  (.gitignore names .safe-code/ or .safe-code/context/ —
#                       even while still tracked — or no git): SESSION.md has an
#                       in-progress `[~]` item, or is newer than the stamp file
#                       .safe-code/.last-save and holds work (`--save` touches
#                       that stamp; no stamp -> `[~]` only)
#   - per-developer session files ignored (team mode): the local-only test
#                       above, plus any uncommitted change to the committed part
#                       of .safe-code/ (context/, BACKLOG.md, ...). Special case:
#                       .safe-code/ wholly untracked and .last-save not older
#                       than any session file = a save that committed nothing
#                       (team adopt on the default branch) -> the message
#                       suggests the safe-code/adopt branch instead of --save
#   - tracked brain:    `git status --porcelain -- .safe-code/` is non-empty,
#                       except a change to SESSION.md alone, which counts only
#                       when SESSION.md holds work
#   SESSION.md "holds work": a `[~]` item, a done `[x]` task annotated `files:`,
#   or any content under `## Drafts`.
#
# Project root: the argument; else the nearest directory (from the hook's cwd,
# then the shell's) that holds .safe-code/, not walking above the git toplevel;
# else the git toplevel; else the current directory.
#
# Usage:
#   bash save-reminder.sh [--plain] [--no-brief] [project-root]
#     --plain     print plain text instead of JSON (hosts without a JSON hook
#                 contract, or a terminal): the brief, or the reminder line
#     --no-brief  reminder only (pre-brief behaviour)
#   Hook payload on stdin naming an event other than SessionStart (e.g. an
#   older `Stop` wiring) -> silent exit 0.
set -u

PLAIN=0
BRIEF=1
ROOT_ARG=""
for arg in "$@"; do
	case "$arg" in
	--plain) PLAIN=1 ;;
	--no-brief) BRIEF=0 ;;
	-h | --help)
		sed -n '2,51p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) ROOT_ARG="$arg" ;;
	esac
done

# ---- hook input (stdin JSON) ------------------------------------------------
# Hosts pass the hook payload on stdin. An older install wired this script as a
# `Stop` hook; there it would nag after every turn, so any hook event other than
# SessionStart exits silently. Read stdin only when it is not a terminal, with a
# per-line timeout and a line cap so an open-but-idle pipe never hangs the hook.
# Manual runs (terminal, or no stdin) skip this and behave as before.
HOOK_CWD=""
if [ ! -t 0 ]; then
	HOOK_INPUT=""
	n=0
	line=""
	while [ "$n" -lt 200 ] && IFS= read -r -t 2 line 2>/dev/null; do
		HOOK_INPUT="${HOOK_INPUT}${line}
"
		line=""
		n=$((n + 1))
	done
	# last line without a trailing newline
	[ -n "$line" ] && HOOK_INPUT="${HOOK_INPUT}${line}"
	EVENT="$(printf '%s' "$HOOK_INPUT" |
		sed -nE 's/.*"hook_event_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -n 1)"
	if [ -n "$EVENT" ] && [ "$EVENT" != "SessionStart" ]; then
		exit 0
	fi
	HOOK_CWD="$(printf '%s' "$HOOK_INPUT" |
		sed -nE 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"\\]*)".*/\1/p' | head -n 1)"
fi

# ---- locate project root ----------------------------------------------------
# Unified rule (same as check.sh): nearest dir holding .safe-code/, never above
# the git toplevel; else the git toplevel; else the start dir.
find_root() { # find_root <start-dir>
	local start top dir
	start="$(cd "$1" 2>/dev/null && pwd -P)" || start="$(pwd -P)"
	top=""
	command -v git >/dev/null 2>&1 && top="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null)"
	dir="$start"
	while :; do
		[ -d "$dir/.safe-code" ] && {
			printf '%s\n' "$dir"
			return
		}
		[ -n "$top" ] && [ "$dir" = "$top" ] && break
		[ "$dir" = "/" ] && break
		dir="$(dirname "$dir")"
	done
	if [ -n "$top" ]; then printf '%s\n' "$top"; else printf '%s\n' "$start"; fi
}

if [ -n "$ROOT_ARG" ] && [ -d "$ROOT_ARG" ]; then
	ROOT="$(cd "$ROOT_ARG" && pwd)"
elif [ -n "$HOOK_CWD" ] && [ -d "$HOOK_CWD" ]; then
	ROOT="$(find_root "$HOOK_CWD")"
else
	ROOT="$(find_root "$(pwd)")"
fi

# Project does not use safe-code -> nothing to brief or remind about.
[ -d "$ROOT/.safe-code" ] || exit 0

SESSION="$ROOT/.safe-code/SESSION.md"
STAMP="$ROOT/.safe-code/.last-save"
unsaved=0

# In-progress marker. `[~]` only — a saved SESSION.md may still carry empty
# `[ ]` template items, and setup items are ticked `[x]` on any run.
in_progress() {
	[ -f "$SESSION" ] && grep -qE '^[[:space:]]*-[[:space:]]*\[~\]' "$SESSION" 2>/dev/null
}

# SESSION.md holds work a save must keep: `[~]`, a done task annotated `files:`, or
# any non-comment line under `## Drafts`. Task-list scaffolding alone is not work.
holds_work() {
	[ -f "$SESSION" ] || return 1
	in_progress && return 0
	grep -qE '^[[:space:]]*-[[:space:]]*\[[xX]\].*files:[[:space:]]*[^[:space:]<]' "$SESSION" 2>/dev/null && return 0
	awk '
		/^## / { in_d = ($0 ~ /^## Drafts[[:space:]]*$/); next }
		!in_d { next }
		c { if ($0 ~ /-->/) c = 0; next }
		/^[[:space:]]*<!--/ { if ($0 !~ /-->/) c = 1; next }
		/[^[:space:]]/ { found = 1; exit }
		END { exit !found }
	' "$SESSION" 2>/dev/null
}

# Local-only check: in-progress marker, or work in SESSION.md after the last save.
local_unsaved() {
	in_progress && return 0
	[ -f "$STAMP" ] && [ "$SESSION" -nt "$STAMP" ] && holds_work && return 0
	return 1
}

# A save ran (stamp exists, no session file is newer than it) but nothing of
# .safe-code/ is tracked: team adopt on the default branch commits nothing until
# the user creates the safe-code/adopt branch (references/adopt.md, Branch).
saved_uncommitted() {
	[ -f "$STAMP" ] || return 1
	[ -z "$(git -C "$ROOT" ls-files -- .safe-code 2>/dev/null)" ] || return 1
	local f
	for f in ACTIVE SESSION LOG BACKLOG MEMORY safe-refactor-code; do
		[ -f "$ROOT/.safe-code/$f.md" ] || continue
		[ "$ROOT/.safe-code/$f.md" -nt "$STAMP" ] && return 1
	done
	return 0
}

# porcelain paths are repo-root relative, so match by suffix (the brain may sit
# in a subfolder of the repo). Per-developer files never count as "committed part".
PER_DEV_RE='\.safe-code/(ACTIVE|SESSION|LOG|MEMORY|safe-refactor-code)\.md$|\.safe-code/\.last-save$|\.safe-code/backups/'

IS_GIT=0
SETUP_UNCOMMITTED=0
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
	IS_GIT=1
fi

if [ "$IS_GIT" -eq 1 ]; then
	# Local-only brain first: .gitignore names .safe-code/ or its context/ (a
	# .safe-code/* pattern catches both). --no-index also matches a brain that is
	# ignored but still tracked: --save makes no docs commit there, so porcelain
	# would stay dirty and nag every session.
	# one check-ignore call for all three paths (it prints each ignored one)
	IGNORED="$(git -C "$ROOT" check-ignore --no-index .safe-code/ .safe-code/context/ .safe-code/SESSION.md 2>/dev/null)"
	NL='
'
	IGN="${NL}${IGNORED}${NL}"
	case "$IGN" in *"${NL}.safe-code/${NL}"* | *"${NL}.safe-code/context/${NL}"*) IGN_BRAIN=1 ;; *) IGN_BRAIN=0 ;; esac
	case "$IGN" in *"${NL}.safe-code/SESSION.md${NL}"*) IGN_SESSION=1 ;; *) IGN_SESSION=0 ;; esac
	if [ "$IGN_BRAIN" -eq 1 ]; then
		local_unsaved && unsaved=1
	elif [ "$IGN_SESSION" -eq 1 ]; then
		# Team mode (per-developer session files ignored, brain committed).
		local_unsaved && unsaved=1
		if [ "$unsaved" -eq 0 ]; then
			shared="$(git -C "$ROOT" status --porcelain -- .safe-code/ 2>/dev/null | grep -vE "$PER_DEV_RE")"
			if [ -n "$shared" ]; then
				unsaved=1
				saved_uncommitted && SETUP_UNCOMMITTED=1
			fi
		fi
	else
		# Tracked brain: `--save` commits, so a pending change under .safe-code/
		# means the session was not saved (ignored files are not listed here) —
		# unless the only change is SESSION.md and it holds no work.
		dirty="$(git -C "$ROOT" status --porcelain -- .safe-code/ 2>/dev/null)"
		if [ -n "$dirty" ]; then
			others="$(printf '%s\n' "$dirty" | grep -vE '\.safe-code/SESSION\.md$')"
			if [ -n "$others" ] || holds_work; then
				unsaved=1
			fi
		fi
	fi
else
	local_unsaved && unsaved=1
fi

# Keep the message free of double quotes and backslashes: it is embedded in JSON
# as-is.
MSG='safe-code: the last session left unsaved work in .safe-code/ - run /safe-code --save to keep it, or /safe-code --continue to resume.'
UNSAVED_CTX='Unsaved: the last session left work in .safe-code/ - tell the user; save only when they ask (/safe-code --save), or resume with /safe-code --continue.'
if [ "$SETUP_UNCOMMITTED" -eq 1 ]; then
	MSG='safe-code: .safe-code/ is saved on disk but was never committed (team mode, default branch) - create the setup branch with git switch -c safe-code/adopt and commit it there; open the PR yourself.'
	UNSAVED_CTX='Unsaved: .safe-code/ was saved on disk but never committed (team mode, default branch) - tell the user; suggest git switch -c safe-code/adopt and committing there, never on the default branch.'
fi

# ---- reminder only (--no-brief) ---------------------------------------------
if [ "$BRIEF" -eq 0 ]; then
	[ "$unsaved" -eq 1 ] || exit 0
	if [ "$PLAIN" -eq 1 ]; then
		printf '%s\n' "$MSG"
	else
		printf '{"systemMessage":"%s"}\n' "$MSG"
	fi
	exit 0
fi

# ---- brief (<= 15 lines; repo-derived headings only, no secrets) ------------
# clip <text>: sets CLIPPED to its first line, control characters turned into
# spaces, capped at 180 characters. In-shell (no subprocess) unless it has to cut:
# then iconv drops a multi-byte character split by a byte-wise cut.
CLIPPED=""
clip() {
	local v="${1%%$'\n'*}"
	v="${v//[[:cntrl:]]/ }"
	if [ "${#v}" -gt 180 ]; then
		v="${v:0:180}"
		v="$(printf '%s' "$v" | { iconv -c -f UTF-8 -t UTF-8 2>/dev/null || cat; })"
	fi
	CLIPPED="$v"
}

# project one-liner: first prose line of AGENTS.md before its first `## `
# (a `> ` quote line counts), else the first line under project-overview `## Overview`
first_prose() { # first_prose <file> <section-regex-or-empty>
	awk -v sec="$2" '
		sec == "" && /^## / { exit }
		sec != "" && /^## / { if (in_s) exit; in_s = ($0 ~ sec); next }
		sec != "" && !in_s { next }
		c { if ($0 ~ /-->/) c = 0; next }
		/^[[:space:]]*<!--/ { if ($0 !~ /-->/) c = 1; next }
		/^#/ || /^@/ || /^[[:space:]]*$/ { next }
		{ sub(/^>[[:space:]]*/, ""); sub(/^[-*][[:space:]]+/, ""); if ($0 ~ /[^[:space:]]/) { print; exit } }
	' "$1" 2>/dev/null
}

PROJECT_LINE=""
if [ -f "$ROOT/AGENTS.md" ]; then
	clip "$(first_prose "$ROOT/AGENTS.md" "")"
	PROJECT_LINE="$CLIPPED"
fi
if [ -z "$PROJECT_LINE" ] && [ -f "$ROOT/.safe-code/context/project-overview.md" ]; then
	clip "$(first_prose "$ROOT/.safe-code/context/project-overview.md" '^## Overview')"
	PROJECT_LINE="$CLIPPED"
fi

ACTIVE="$ROOT/.safe-code/ACTIVE.md"
NEXT=""
SAVED_AT=""
if [ -f "$ACTIVE" ]; then
	# Last Session sits at the bottom of ACTIVE.md: the last match wins.
	# One awk prints two lines: next_action, then saved_at.
	A_OUT="$(awk '
		/^next_action:/ { n = $0; sub(/^next_action:[[:space:]]*/, "", n) }
		/^saved_at:/ { a = $0; sub(/^saved_at:[[:space:]]*/, "", a) }
		END { print n; print a }
	' "$ACTIVE" 2>/dev/null)"
	clip "${A_OUT%%$'\n'*}"
	NEXT="$CLIPPED"
	case "$A_OUT" in *$'\n'*) clip "${A_OUT#*$'\n'}" ;; *) CLIPPED="" ;; esac
	SAVED_AT="$CLIPPED"
fi
case "$NEXT" in "" | none | - | "<"*) NEXT="" ;; esac
case "$SAVED_AT" in "" | - | none | "<"*) SAVED_AT="" ;; esac

TRACKER="$ROOT/.safe-code/context/progress-tracker.md"
OQ_COUNT=0
OQ1=""
OQ2=""
SYNC=""
if [ -f "$TRACKER" ]; then
	# One awk: line 1 = sync stamp (or empty), line 2 = open-question count,
	# lines 3-4 = the top two open questions.
	T_OUT="$(awk '
		/^last_synced_commit:/ && sync == "" { sync = $2; if (sync == "") sync = "-" }
		/^## / { in_s = ($0 ~ /^## Open Questions[[:space:]]*$/); next }
		!in_s { next }
		c { if ($0 ~ /-->/) c = 0; next }
		/^[[:space:]]*<!--/ { if ($0 !~ /-->/) c = 1; next }
		/^[[:space:]]*[-*][[:space:]]+/ {
			t = $0; sub(/^[[:space:]]*[-*][[:space:]]+/, "", t)
			if (t ~ /^(None|none)/ || t ~ /^~~/ || t ~ /^\[[xX]\]/ || t ~ /^<!--/) next
			n++; if (n <= 2) top[n] = t
		}
		END { print sync; print n + 0; if (n >= 1) print top[1]; if (n >= 2) print top[2] }
	' "$TRACKER" 2>/dev/null)"
	{
		IFS= read -r SYNC
		IFS= read -r OQ_COUNT
		IFS= read -r OQ1
		IFS= read -r OQ2
	} <<T_EOF
$T_OUT
T_EOF
	case "$OQ_COUNT" in "" | *[!0-9]*) OQ_COUNT=0 ;; esac
fi

FRESH=""
if [ "$IS_GIT" -eq 1 ]; then
	case "$SYNC" in
	"" | none | -)
		git -C "$ROOT" rev-parse -q --verify HEAD >/dev/null 2>&1 &&
			FRESH="Brain freshness: never synced (no last_synced_commit) - run /safe-code to populate and stamp it."
		;;
	*[!0-9a-fA-F]*)
		# repo-controlled text: never hand a non-hex value to git as a revision
		FRESH="Brain freshness: last_synced_commit is not a commit hash - treat context as possibly stale."
		;;
	*)
		if drift="$(git -C "$ROOT" rev-list --count --invert-grep --grep='^Safe-Code: ' "${SYNC}..HEAD" -- 2>/dev/null)"; then
			if [ "${drift:-0}" -gt 0 ] 2>/dev/null; then
				FRESH="Brain freshness: STALE - ${drift} commit(s) since last sync ${SYNC} were not made by safe-code; re-check facts against the repo before relying on them."
			fi
		elif git -C "$ROOT" rev-parse -q --verify HEAD >/dev/null 2>&1; then
			FRESH="Brain freshness: sync stamp ${SYNC} is not in this history (rebased or shallow?) - treat context as possibly stale."
		fi
		;;
	esac
fi

BRIEF_TEXT="safe-code brief (auto, session start) - a pointer, not the source of truth"
[ -n "$PROJECT_LINE" ] && BRIEF_TEXT="${BRIEF_TEXT}
Project: ${PROJECT_LINE}"
if [ -n "$NEXT" ]; then
	if [ -n "$SAVED_AT" ]; then
		BRIEF_TEXT="${BRIEF_TEXT}
Last session (${SAVED_AT}) next action: ${NEXT}"
	else
		BRIEF_TEXT="${BRIEF_TEXT}
Last session next action: ${NEXT}"
	fi
fi
if [ "$OQ_COUNT" -gt 0 ]; then
	BRIEF_TEXT="${BRIEF_TEXT}
Open questions: ${OQ_COUNT} (progress-tracker.md)"
	for q in "$OQ1" "$OQ2"; do
		[ -n "$q" ] || continue
		clip "$q"
		BRIEF_TEXT="${BRIEF_TEXT}
  - ${CLIPPED}"
	done
fi
[ -n "$FRESH" ] && BRIEF_TEXT="${BRIEF_TEXT}
${FRESH}"
# plain text goes to whoever reads stdout, so it carries the user-facing line
if [ "$unsaved" -eq 1 ]; then
	if [ "$PLAIN" -eq 1 ]; then
		BRIEF_TEXT="${BRIEF_TEXT}
${MSG}"
	else
		BRIEF_TEXT="${BRIEF_TEXT}
${UNSAVED_CTX}"
	fi
fi
BRIEF_TEXT="${BRIEF_TEXT}
Full context: AGENTS.md (Read First list) and .safe-code/ACTIVE.md."
# at most 8 lines by construction (header, project, next action, open questions
# + top 2, freshness, unsaved, footer) — inside the 15-line contract

if [ "$PLAIN" -eq 1 ]; then
	printf '%s\n' "$BRIEF_TEXT"
	exit 0
fi

# JSON string, in-shell: escape backslash, then quote, then join lines with \n
# (clip already turned every other control character into a space)
CTX="${BRIEF_TEXT//\\/\\\\}"
CTX="${CTX//\"/\\\"}"
CTX="${CTX//$'\n'/\\n}"
if [ "$unsaved" -eq 1 ]; then
	printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$MSG" "$CTX"
else
	printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$CTX"
fi
exit 0
