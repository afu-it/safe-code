#!/usr/bin/env bash
#
# Deterministic fixture tests for the scripts shipped with the skill:
#   skills/safe-code/scripts/{check.sh,migrate.sh,save-reminder.sh}
# plus the root shims in scripts/.
#
# - bash 3.2 compatible (macOS /bin/bash) and Linux bash; no network
# - every fixture is a throwaway git repo under ${TMPDIR:-/tmp} (mktemp), removed on exit
# - git runs with an isolated HOME/config and a local test identity, so the
#   developer's global gitignore, hooks, or signing setup never leak in
# - each case prints PASS/FAIL <name>; exit 1 on any FAIL
#
# The scripts under test run with the same bash that runs this file, so
#   /bin/bash tests/scripts/run.sh
# exercises bash 3.2 on macOS. The root shims re-exec `bash` from PATH.
#
# Usage: bash tests/scripts/run.sh [-v]     (-v prints the output of failed cases)
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
SK="$REPO/skills/safe-code/scripts"
CHECK="$SK/check.sh"
MIGRATE="$SK/migrate.sh"
HOOK="$SK/save-reminder.sh"
SH="${BASH:-bash}"
VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

WORK="$(mktemp -d "${TMPDIR:-/tmp}/safe-code-tests.XXXXXX")" || exit 1
WORK="$(cd "$WORK" && pwd -P)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT INT TERM

# isolate git from the developer's machine
export HOME="$WORK/home"
export XDG_CONFIG_HOME="$HOME/.config"
export GIT_CONFIG_NOSYSTEM=1
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
mkdir -p "$XDG_CONFIG_HOME/git"
: >"$HOME/.gitconfig"

g() { git -c user.name=test -c user.email=test@example.com -c commit.gpgsign=false \
	-c init.defaultBranch=main -c core.hooksPath=/dev/null "$@"; }

PASSN=0
FAILN=0
LAST_OUT=""
pass() {
	PASSN=$((PASSN + 1))
	printf 'PASS %s\n' "$1"
}
fail() {
	FAILN=$((FAILN + 1))
	printf 'FAIL %s\n' "$1"
	if [ "$VERBOSE" -eq 1 ] && [ -n "$LAST_OUT" ]; then
		printf '%s\n' "$LAST_OUT" | sed 's/^/     | /'
	fi
}
# t <name> <command...>: PASS when the command succeeds
t() {
	local name="$1"
	shift
	if "$@"; then pass "$name"; else fail "$name"; fi
}
has() { printf '%s\n' "$1" | grep -qE -- "$2"; }
hasnt() { ! printf '%s\n' "$1" | grep -qE -- "$2"; }
same() { [ "$1" = "$2" ]; }
not() { ! "$@"; }

# ---- JSON helpers (jq, else python3) ----------------------------------------
if command -v jq >/dev/null 2>&1; then
	JSON=jq
elif command -v python3 >/dev/null 2>&1; then
	JSON=py
else
	echo "need jq or python3 for the JSON cases" >&2
	exit 2
fi
json_ok() { # json_ok <text>: exactly one valid JSON object
	[ -n "$1" ] || return 1
	if [ "$JSON" = jq ]; then
		printf '%s' "$1" | jq -e 'type == "object"' >/dev/null 2>&1
	else
		printf '%s' "$1" | python3 -c 'import json,sys; o=json.load(sys.stdin); sys.exit(0 if isinstance(o, dict) else 1)' 2>/dev/null
	fi
}
json_has() { # json_has <text> <top-level key>
	if [ "$JSON" = jq ]; then
		printf '%s' "$1" | jq -e --arg k "$2" 'has($k)' >/dev/null 2>&1
	else
		printf '%s' "$1" | python3 -c 'import json,sys; sys.exit(0 if sys.argv[1] in json.load(sys.stdin) else 1)' "$2" 2>/dev/null
	fi
}
json_ctx() { # json_ctx <text>: prints hookSpecificOutput.additionalContext
	if [ "$JSON" = jq ]; then
		printf '%s' "$1" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null
	else
		printf '%s' "$1" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("hookSpecificOutput",{}).get("additionalContext",""))' 2>/dev/null
	fi
}
json_event() {
	if [ "$JSON" = jq ]; then
		printf '%s' "$1" | jq -r '.hookSpecificOutput.hookEventName // empty' 2>/dev/null
	else
		printf '%s' "$1" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("hookSpecificOutput",{}).get("hookEventName",""))' 2>/dev/null
	fi
}
lines_le() { [ "$(printf '%s\n' "$1" | grep -c '')" -le "$2" ]; }

# ---- fixture helpers ------------------------------------------------------------
N=0
# mkrepo: fresh git repo in a new temp dir; cd into it; prints nothing
mkrepo() {
	N=$((N + 1))
	D="$WORK/r$N"
	mkdir -p "$D" && cd "$D" || exit 2
	g init -q .
}
commit() { g add -A && g commit -qm "${1:-init}"; }
# brain: minimal safe-code brain (tracked layout) in cwd
brain() {
	mkdir -p .safe-code/context/feature-specs
	printf '# AGENTS.md\n\n> Small API for tests.\n\n## Read First\n- .safe-code/ACTIVE.md\n' >AGENTS.md
	printf '# ACTIVE.md\n## Last Session\nnext_action: none\n' >.safe-code/ACTIVE.md
	printf '# SESSION.md\n## Task List\n- [ ] x\n' >.safe-code/SESSION.md
	printf '# Progress Tracker\nlast_synced_commit: none\n## Open Questions\n- None yet.\n' >.safe-code/context/progress-tracker.md
	printf '# User Preferences\n' >.safe-code/context/user-preferences.md
	for f in project-overview architecture code-standards ai-workflow-rules; do
		printf '# %s\n' "$f" >".safe-code/context/$f.md"
	done
	printf '# spec template\n' >.safe-code/context/feature-specs/00-template.md
	for f in LOG BACKLOG MEMORY safe-refactor-code; do printf '# %s\n' "$f" >".safe-code/$f.md"; done
	printf '/.safe-code/context/current-issues.md\n/.safe-code/.last-save\n/.safe-code/backups/\n' >.gitignore
}
# run <script> [args...]: LAST_OUT = combined output, RC = exit code
RC=0
run() {
	LAST_OUT="$("$SH" "$@" 2>&1 </dev/null)"
	RC=$?
}
# hook: run save-reminder.sh with a stdin payload in $PAYLOAD (default SessionStart)
START_PAYLOAD='{"hook_event_name":"SessionStart","source":"startup"}'
hook() {
	LAST_OUT="$(printf '%s\n' "${PAYLOAD:-$START_PAYLOAD}" | "$SH" "$HOOK" 2>&1)"
	RC=$?
}
sha() { git hash-object "$1" 2>/dev/null; }
section() { printf '\n== %s\n' "$1"; }

START=$(date +%s)

# =============================================================================
section "migrate.sh"

# M1: a stranger's root context/ + CHANGELOG.md (no safe-code marker) never moves
mkrepo
mkdir context
printf '# tracker\n' >context/progress-tracker.md
printf 'notes\n' >context/notes.md
printf '# Changelog\n' >CHANGELOG.md
commit
run "$MIGRATE" --apply
t "migrate: stranger context/ + CHANGELOG -> nothing to migrate" has "$LAST_OUT" 'nothing to migrate'
t "migrate: stranger context/progress-tracker.md stays" test -f context/progress-tracker.md
t "migrate: stranger CHANGELOG.md stays" test -f CHANGELOG.md
t "migrate: no .safe-code/ created" test ! -e .safe-code

# M2: real subagent memory.md (lowercase) next to a .safe-code/ marker never moves
mkrepo
mkdir -p .claude/agents .safe-code
printf -- '---\nname: memory\n---\nbody\n' >.claude/agents/memory.md
printf 'x\n' >.safe-code/.keep
commit
h0="$(sha .claude/agents/memory.md)"
run "$MIGRATE" --apply
t "migrate: lowercase memory.md subagent -> nothing to migrate (case-insensitive FS safe)" has "$LAST_OUT" 'nothing to migrate'
t "migrate: memory.md untouched" same "$(sha .claude/agents/memory.md)" "$h0"
t "migrate: no MEMORY.md invented in .safe-code/" test ! -e .safe-code/MEMORY.md

# M2b: same, without frontmatter: only the exact-case name test protects it on a
#      case-insensitive filesystem (macOS default); trivially safe on Linux
mkrepo
mkdir -p .claude/agents .safe-code
printf 'agent memory notes\n' >.claude/agents/memory.md
printf 'x\n' >.safe-code/.keep
commit
run "$MIGRATE" --apply
t "migrate: plain lowercase memory.md never matches MEMORY.md" test -f .claude/agents/memory.md -a ! -e .safe-code/MEMORY.md

# M3: a subagent literally named MEMORY.md (frontmatter) never moves
mkrepo
mkdir -p .claude/agents .safe-code
printf -- '---\nname: MEMORY\n---\n' >.claude/agents/MEMORY.md
printf 'x\n' >.safe-code/.keep
commit
run "$MIGRATE" --apply
t "migrate: MEMORY.md with frontmatter is a subagent -> stays" test -f .claude/agents/MEMORY.md
t "migrate: frontmatter MEMORY.md -> nothing to migrate" has "$LAST_OUT" 'nothing to migrate'

# M4: legacy session files beside a real subagent: only safe-code's files move
mkrepo
mkdir -p .claude/agents
printf '# ACTIVE\n' >.claude/agents/ACTIVE.md
printf '# LOG\n' >.claude/agents/LOG.md
printf -- '---\nname: reviewer\n---\nReview diffs.\n' >.claude/agents/reviewer.md
commit
h0="$(sha .claude/agents/reviewer.md)"
run "$MIGRATE"
t "migrate: dry-run is the default (nothing moved)" test -f .claude/agents/ACTIVE.md
t "migrate: dry-run reports the other item left untouched" has "$LAST_OUT" 'leaving 1 other item'
run "$MIGRATE" --apply
t "migrate: --apply moves ACTIVE.md into .safe-code/" test -f .safe-code/ACTIVE.md
t "migrate: --apply moves LOG.md into .safe-code/" test -f .safe-code/LOG.md
t "migrate: real subagent reviewer.md never moves" same "$(sha .claude/agents/reviewer.md)" "$h0"
t "migrate: tracked files moved with git mv (staged rename)" has "$(g status --porcelain)" '^R  \.claude/agents/ACTIVE\.md -> \.safe-code/ACTIVE\.md'

# M5: v3 layout (root context/ + v3 .gitignore + root CHANGELOG), no legacy dirs:
#     the empty FOUND array must not trip `set -u` on bash 3.2
mkrepo
mkdir -p context/feature-specs
for f in project-overview architecture progress-tracker; do printf '# %s\n' "$f" >"context/$f.md"; done
printf '# tpl\n' >context/feature-specs/00-template.md
printf 'mine\n' >context/notes.md
printf '# Changelog\n' >CHANGELOG.md
printf '/context/current-issues.md\n' >.gitignore
printf 'Read `context/architecture.md` and `context/notes.md` and `context/`\n' >AGENTS.md
commit
run "$MIGRATE" --apply
t "migrate: v3 layout with no legacy dirs -> exit 0 (bash 3.2 empty array)" same "$RC" 0
t "migrate: no 'unbound variable' under set -u" hasnt "$LAST_OUT" 'unbound variable'
t "migrate: v3 context files moved" test -f .safe-code/context/architecture.md -a -f .safe-code/context/feature-specs/00-template.md
t "migrate: stranger context/notes.md left in place" test -f context/notes.md
t "migrate: v3 root CHANGELOG.md moved (v3 .gitignore entry present)" test -f .safe-code/CHANGELOG.md
t "migrate: .gitignore entry patched to /.safe-code/" grep -qx '/.safe-code/context/current-issues.md' .gitignore
t "migrate: AGENTS.md safe-code refs rewritten, stranger ref kept" grep -q '`.safe-code/context/architecture.md` and `context/notes.md` and `.safe-code/context/`' AGENTS.md

# M6: v3 .agents/ session files + project skills in .agents/skills/
mkrepo
mkdir -p .agents/skills/x
printf '# ACTIVE\n' >.agents/ACTIVE.md
printf '# MEMORY\n' >.agents/MEMORY.md
printf 's\n' >.agents/skills/x/SKILL.md
printf 'See `.agents/ACTIVE.md` and `.agents/skills/x/SKILL.md`\n' >AGENTS.md
commit
run "$MIGRATE" --apply
t "migrate: .agents/ session files moved" test -f .safe-code/ACTIVE.md -a -f .safe-code/MEMORY.md
t "migrate: .agents/skills/ untouched" test -f .agents/skills/x/SKILL.md
t "migrate: AGENTS.md .agents/ACTIVE.md rewritten, .agents/skills kept" grep -q '`.safe-code/ACTIVE.md` and `.agents/skills/x/SKILL.md`' AGENTS.md

# M7: conflict -> skip, keep source, exit 1
mkrepo
mkdir -p .agents .safe-code
printf '# old\n' >.agents/ACTIVE.md
printf '# new\n' >.safe-code/ACTIVE.md
commit
run "$MIGRATE" --apply
t "migrate: conflict -> exit 1" same "$RC" 1
t "migrate: conflict never overwrites .safe-code/ACTIVE.md" grep -qx '# new' .safe-code/ACTIVE.md
t "migrate: conflicting source left in place" test -f .agents/ACTIVE.md

# M8: root shim + explicit root argument (run from elsewhere)
mkrepo
mkdir -p .codex/agents
printf '# SESSION\n' >.codex/agents/SESSION.md
commit
M8="$D"
LAST_OUT="$(cd "$WORK" && bash "$REPO/scripts/migrate.sh" "$M8" 2>&1)"
RC=$?
t "shim migrate.sh: previews the move for an explicit root" has "$LAST_OUT" 'would move \.codex/agents/SESSION\.md -> \.safe-code/SESSION\.md'

# =============================================================================
section "check.sh"

# C1: complete tracked brain -> OK
mkrepo
brain
commit
run "$CHECK"
t "check: complete brain -> exit 0" same "$RC" 0
t "check: complete brain -> Result: OK" has "$LAST_OUT" '^Result: OK'
t "check: hard checks counted in summary" has "$LAST_OUT" 'Summary: 1 hard check\(s\) passed'

# C2: committed current-issues.md -> exit 1
printf '# issues\n' >.safe-code/context/current-issues.md
g add -f .safe-code/context/current-issues.md && g commit -qm issues
run "$CHECK"
t "check: committed current-issues.md -> exit 1" same "$RC" 1
t "check: committed current-issues.md -> [FAIL] with git rm --cached hint" has "$LAST_OUT" '\[FAIL\].*current-issues\.md is COMMITTED.*git rm --cached'
g rm -q --cached .safe-code/context/current-issues.md && g commit -qm untrack
run "$CHECK"
t "check: untracked + ignored current-issues.md -> exit 0" same "$RC" 0

# C3: local-only paths
touch .safe-code/.last-save
g add -f .safe-code/.last-save && g commit -qm stamp
run "$CHECK"
t "check: tracked .last-save -> warn" has "$LAST_OUT" '\[warn\] \.safe-code/\.last-save is tracked by git'

# C4: legacy rules
mkrepo
brain
mkdir -p .claude/agents .agents/skills/x
printf -- '---\nname: reviewer\n---\n' >.claude/agents/reviewer.md
printf 's\n' >.agents/skills/x/SKILL.md
commit
run "$CHECK"
t "check: subagent + .agents/skills only -> no legacy warning" hasnt "$LAST_OUT" 'legacy safe-code session files'
printf '# ACTIVE\n' >.agents/ACTIVE.md
run "$CHECK"
t "check: .agents/ACTIVE.md -> legacy warning naming migrate.sh" has "$LAST_OUT" "legacy safe-code session files in '\.agents/'.*migrate\.sh --apply"
mkrepo
mkdir context
printf '# tracker\n' >context/progress-tracker.md
commit
run "$CHECK"
t "check: stranger root context/progress-tracker.md -> no v3 warning" hasnt "$LAST_OUT" 'legacy v3 root context'
printf '/context/current-issues.md\n' >.gitignore
run "$CHECK"
t "check: root context/ + v3 .gitignore entry -> v3 warning" has "$LAST_OUT" 'legacy v3 root context/ found'

# C5: brain + AGENTS.md budgets
mkrepo
brain
i=0
while [ $i -lt 320 ]; do
	echo "- fact $i" >>.safe-code/context/architecture.md
	i=$((i + 1))
done
i=0
while [ $i -lt 125 ]; do
	echo "line $i" >>AGENTS.md
	i=$((i + 1))
done
commit
run "$CHECK"
t "check: brain over 300 lines -> budget warning" has "$LAST_OUT" '\[warn\] Brain: [0-9]+ lines \(budget 300\)'
t "check: AGENTS.md over 120 lines -> budget warning" has "$LAST_OUT" '\[warn\] AGENTS\.md is [0-9]+ lines \(budget 120\)'
t "check: budget is advisory (exit 0)" same "$RC" 0

# C6: team mode
mkrepo
brain
commit
GIT_AUTHOR_EMAIL='41898282+github-actions[bot]@users.noreply.github.com' g commit -q --allow-empty -m bot
GIT_AUTHOR_EMAIL='noreply@github.com' g commit -q --allow-empty -m web
run "$CHECK"
t "check: 1 human + bots -> Team: off (1 author)" has "$LAST_OUT" 'Team: off \(1 author, 90d\)'
GIT_AUTHOR_EMAIL='dev2@example.com' g commit -q --allow-empty -m second
run "$CHECK"
t "check: 2 humans -> Team: on (2 authors)" has "$LAST_OUT" 'Team: on \(2 authors, 90d\)'
t "check: team on + committed SESSION.md -> warn with git rm --cached" has "$LAST_OUT" 'SESSION\.md is committed.*git rm --cached'
printf -- '- team: off\n' >>.safe-code/context/user-preferences.md
run "$CHECK"
t "check: 'team: off' override wins" has "$LAST_OUT" 'Team: off \(2 authors, 90d; set by user-preferences\.md\)'
printf '# User Preferences\n## Git Identity\n- email: dev2@example.com\n' >.safe-code/context/user-preferences.md
printf '/.safe-code/%s\n' ACTIVE.md SESSION.md LOG.md MEMORY.md safe-refactor-code.md .last-save backups/ context/current-issues.md context/user-preferences.local.md >.gitignore
g rm -q --cached .safe-code/ACTIVE.md .safe-code/SESSION.md .safe-code/LOG.md .safe-code/MEMORY.md .safe-code/safe-refactor-code.md
commit "chore: team mode"
run "$CHECK"
t "check: team mode personal field named, value never printed" has "$LAST_OUT" 'personal field\(s\) email'
t "check: team mode never prints the email value" hasnt "$LAST_OUT" 'dev2@example\.com'
printf '# User Preferences\n' >.safe-code/context/user-preferences.md
commit "chore: prefs"
run "$CHECK"
t "check: team gitignore consistent -> session files match team mode" has "$LAST_OUT" 'session files match team mode \(on\)'
t "check: SESSION.md-only ignore is team mode, not local-only" hasnt "$LAST_OUT" 'Brain: local-only'
printf '/.safe-code/\n' >.gitignore
run "$CHECK"
t "check: /.safe-code/ ignored -> Brain: local-only" has "$LAST_OUT" 'Brain: local-only'
t "check: local-only brain -> Team: n/a" has "$LAST_OUT" 'Team: n/a'
t "check: ignored-but-tracked brain -> git rm -r --cached hint" has "$LAST_OUT" 'still tracked.*git rm -r --cached \.safe-code'

# C7: monorepo root + nested AGENTS.md
mkrepo
brain
C7="$D"
mkdir -p packages/api/src packages/web
printf '{"workspaces":["packages/*"]}\n' >package.json
printf '# AGENTS.md (api)\n- test: pnpm --filter api test\n' >packages/api/AGENTS.md
i=0
while [ $i -lt 45 ]; do
	echo "line $i" >>packages/web/AGENTS.md
	i=$((i + 1))
done
printf '\n- packages/api/ - see packages/api/AGENTS.md\n' >>AGENTS.md
commit
LAST_OUT="$(cd packages/api/src && "$SH" "$CHECK" 2>&1)"
t "check: run from a subfolder -> repo root" has "$LAST_OUT" "project root: $C7\$"
t "check: nested AGENTS.md over 40 lines -> warning" has "$LAST_OUT" 'packages/web/AGENTS\.md is 45 lines \(budget 40\)'
t "check: nested AGENTS.md not linked from root -> warning" has "$LAST_OUT" 'root AGENTS\.md does not link packages/web/AGENTS\.md'
t "check: linked nested AGENTS.md -> no link warning" hasnt "$LAST_OUT" 'does not link packages/api/AGENTS\.md'
mkdir -p packages/web/.safe-code
LAST_OUT="$(cd packages/web && "$SH" "$CHECK" 2>&1)"
t "check: nearest .safe-code/ (package brain) wins" has "$LAST_OUT" "project root: $C7/packages/web\$"

# C8: root shim, explicit root, from outside the repo
LAST_OUT="$(cd "$WORK" && bash "$REPO/scripts/check.sh" "$C7" 2>&1)"
RC=$?
t "shim check.sh: explicit root from outside -> exit 0" same "$RC" 0
t "shim check.sh: names the explicit root" has "$LAST_OUT" "project root: $C7\$"

# =============================================================================
section "save-reminder.sh"

# S1: brief + unsaved detection on a tracked brain
mkrepo
brain
commit
PAYLOAD='{"hook_event_name":"Stop"}' hook
t "hook: Stop event -> silent" same "$LAST_OUT" ""
t "hook: always exit 0" same "$RC" 0
hook
t "hook: SessionStart -> valid JSON" json_ok "$LAST_OUT"
t "hook: one line of output" same "$(printf '%s\n' "$LAST_OUT" | grep -c '')" 1
t "hook: hookEventName is SessionStart" same "$(json_event "$LAST_OUT")" SessionStart
t "hook: brief <= 15 lines" lines_le "$(json_ctx "$LAST_OUT")" 15
t "hook: brief carries the AGENTS.md project line" has "$(json_ctx "$LAST_OUT")" '^Project: Small API for tests\.'
t "hook: saved -> no systemMessage" not json_has "$LAST_OUT" systemMessage
t "hook: no last_synced_commit -> never-synced line" has "$(json_ctx "$LAST_OUT")" 'never synced'

printf -- '- [ ] y\n' >>.safe-code/SESSION.md
hook
t "hook: SESSION-only scaffold change -> no systemMessage" not json_has "$LAST_OUT" systemMessage
printf -- '- [x] wire login files: src/login.ts\n' >>.safe-code/SESSION.md
hook
t "hook: SESSION.md done task with files: -> systemMessage" json_has "$LAST_OUT" systemMessage
g checkout -q .safe-code
printf '## Drafts\n- draft fact\n' >>.safe-code/SESSION.md
hook
t "hook: SESSION.md ## Drafts content -> systemMessage" json_has "$LAST_OUT" systemMessage
g checkout -q .safe-code
printf -- '- [~] half done\n' >>.safe-code/SESSION.md
hook
t "hook: [~] in progress -> valid JSON" json_ok "$LAST_OUT"
t "hook: [~] in progress -> systemMessage names --save" has "$LAST_OUT" '"systemMessage":"[^"]*--save'
t "hook: unsaved -> brief has Unsaved: line" has "$(json_ctx "$LAST_OUT")" '^Unsaved:'
LAST_OUT="$("$SH" "$HOOK" --plain </dev/null 2>&1)"
t "hook --plain: not JSON" hasnt "$(printf '%s\n' "$LAST_OUT" | head -n 1)" '^\{'
t "hook --plain: carries the reminder" has "$LAST_OUT" 'run /safe-code --save'
LAST_OUT="$("$SH" "$HOOK" --no-brief </dev/null 2>&1)"
t "hook --no-brief: reminder-only JSON" json_ok "$LAST_OUT"
t "hook --no-brief: no brief" not json_has "$LAST_OUT" hookSpecificOutput
g checkout -q .safe-code
printf 'other\n' >>.safe-code/context/architecture.md
hook
t "hook: tracked brain, context change -> systemMessage" json_has "$LAST_OUT" systemMessage
g checkout -q .safe-code
LAST_OUT="$("$SH" "$HOOK" --no-brief </dev/null 2>&1)"
t "hook --no-brief: clean -> silent" same "$LAST_OUT" ""

# S2: 30 open questions + quotes/backslashes still give valid, short JSON
{
	printf '# Progress Tracker\nlast_synced_commit: none\n## Open Questions\n'
	i=0
	while [ $i -lt 30 ]; do
		printf -- '- q%d with "quotes" and \\ slash\n' $i
		i=$((i + 1))
	done
} >.safe-code/context/progress-tracker.md
printf '# AGENTS.md\n\n> A "quoted" \\ project\ttab\n' >AGENTS.md
hook
t "hook: quotes, backslash, tab -> valid JSON" json_ok "$LAST_OUT"
t "hook: 30 questions -> count + top 2 only" has "$(json_ctx "$LAST_OUT")" '^Open questions: 30'
t "hook: only 2 questions listed" same "$(json_ctx "$LAST_OUT" | grep -c '^  - ')" 2
t "hook: 30 questions -> brief still <= 15 lines" lines_le "$(json_ctx "$LAST_OUT")" 15
g checkout -q .

# S3: no brain -> silent
mkrepo
LAST_OUT="$(printf '{"hook_event_name":"SessionStart"}\n' | "$SH" "$HOOK" 2>&1)"
t "hook: no .safe-code/ -> silent" same "$LAST_OUT" ""

# S4: ignored-but-tracked brain + local-only stamp logic
mkrepo
brain
commit
printf '/.safe-code/\n' >>.gitignore
commit "chore: brain local-only"
printf 'edit\n' >>.safe-code/ACTIVE.md
hook
t "hook: ignored-but-tracked brain, ACTIVE edit -> silent" not json_has "$LAST_OUT" systemMessage
printf -- '- [x] done files: src/a.ts\n' >>.safe-code/SESSION.md
touch .safe-code/.last-save
hook
t "hook: local-only, SESSION older than stamp -> silent" not json_has "$LAST_OUT" systemMessage
# make SESSION.md strictly newer than the stamp (portable: touch -t)
touch -t 202001010000 .safe-code/.last-save
hook
t "hook: local-only, SESSION newer than stamp with work -> systemMessage" json_has "$LAST_OUT" systemMessage

# S5: team mode (per-developer files ignored, brain committed)
mkrepo
brain
commit
printf '/.safe-code/%s\n' ACTIVE.md SESSION.md LOG.md MEMORY.md safe-refactor-code.md .last-save backups/ context/current-issues.md >.gitignore
g rm -q --cached .safe-code/ACTIVE.md .safe-code/SESSION.md .safe-code/LOG.md .safe-code/MEMORY.md .safe-code/safe-refactor-code.md
commit "chore: team mode"
hook
t "hook: team mode clean -> no systemMessage" not json_has "$LAST_OUT" systemMessage
printf 'edit\n' >>.safe-code/ACTIVE.md
hook
t "hook: team mode per-dev file change alone -> silent" not json_has "$LAST_OUT" systemMessage
printf -- '- shared fact\n' >>.safe-code/context/architecture.md
hook
t "hook: team mode uncommitted shared context -> systemMessage" json_has "$LAST_OUT" systemMessage

# S5b: team adopt on the default branch: a save wrote .safe-code/ but committed nothing
mkrepo
printf 'x\n' >a.txt
commit "feat: a"
brain
printf '/.safe-code/%s\n' ACTIVE.md SESSION.md LOG.md MEMORY.md safe-refactor-code.md .last-save backups/ context/current-issues.md >.gitignore
for f in ACTIVE SESSION LOG BACKLOG MEMORY safe-refactor-code; do touch -t 202001010000 ".safe-code/$f.md"; done
touch -t 202101010000 .safe-code/.last-save
hook
t "hook: team, untracked brain saved but uncommitted -> systemMessage" json_has "$LAST_OUT" systemMessage
t "hook: team, untracked brain saved -> suggests safe-code/adopt branch" has "$LAST_OUT" '"systemMessage":"[^"]*git switch -c safe-code/adopt'
t "hook: team, untracked brain saved -> not 'run /safe-code --save'" hasnt "$LAST_OUT" '"systemMessage":"[^"]*run /safe-code --save'
t "hook: team, untracked brain saved -> brief names the branch" has "$(json_ctx "$LAST_OUT")" '^Unsaved: .*safe-code/adopt'
printf 'note\n' >>.safe-code/SESSION.md
hook
t "hook: team, untracked brain, SESSION newer than stamp -> plain --save reminder" has "$LAST_OUT" '"systemMessage":"[^"]*run /safe-code --save'

# S6: freshness via the Safe-Code: trailer
mkrepo
brain
commit
stamp="$(g rev-parse --short HEAD)"
printf '# Progress Tracker\nlast_synced_commit: %s\n## Open Questions\n- None yet.\n' "$stamp" >.safe-code/context/progress-tracker.md
g commit -qam "docs: sync .safe-code session files" -m "Safe-Code: 5.0"
hook
t "hook: only Safe-Code: trailer commits since stamp -> fresh" hasnt "$(json_ctx "$LAST_OUT")" 'Brain freshness'
printf 'x\n' >a.txt
commit "feat: a"
hook
t "hook: one foreign commit -> STALE 1" has "$(json_ctx "$LAST_OUT")" 'STALE - 1 commit'
printf '# Progress Tracker\nlast_synced_commit: deadbeef\n' >.safe-code/context/progress-tracker.md
hook
t "hook: stamp not in history -> possibly stale" has "$(json_ctx "$LAST_OUT")" 'not in this history'
printf '# Progress Tracker\nlast_synced_commit: --output=%s/pwned\n' "$WORK" >.safe-code/context/progress-tracker.md
hook
t "hook: non-hex stamp -> 'not a commit hash'" has "$(json_ctx "$LAST_OUT")" 'not a commit hash'
t "hook: non-hex stamp never reaches git (no file written)" test ! -e "$WORK/pwned" -a ! -e "$WORK/pwned..HEAD"

# S7: monorepo root from a subfolder (hook payload cwd) + root shim
cd "$C7" || exit 2
LAST_OUT="$(printf '{"hook_event_name":"SessionStart","cwd":"%s/packages/api/src"}\n' "$C7" | (cd / && "$SH" "$HOOK") 2>&1)"
t "hook: payload cwd in a subfolder -> root brain brief" has "$(json_ctx "$LAST_OUT")" 'Small API for tests'
LAST_OUT="$(cd "$C7/packages/api/src" && printf '{"hook_event_name":"SessionStart"}\n' | bash "$REPO/scripts/save-reminder.sh" 2>&1)"
t "shim save-reminder.sh: subfolder shell cwd -> valid JSON" json_ok "$LAST_OUT"

# S8: brain outside git (no freshness line, still a brief)
N=$((N + 1))
D="$WORK/r$N"
mkdir -p "$D/.safe-code" && cd "$D" || exit 2
printf '# AGENTS.md\n\n> No git here.\n' >AGENTS.md
printf -- '- [~] wip\n' >.safe-code/SESSION.md
hook
t "hook: no git -> valid JSON" json_ok "$LAST_OUT"
t "hook: no git, [~] -> systemMessage" json_has "$LAST_OUT" systemMessage
t "hook: no git -> no freshness line" hasnt "$(json_ctx "$LAST_OUT")" 'Brain freshness'

# =============================================================================
END=$(date +%s)
printf '\n%d passed, %d failed (%ss, bash %s)\n' "$PASSN" "$FAILN" "$((END - START))" "${BASH_VERSION:-?}"
[ "$FAILN" -eq 0 ]
