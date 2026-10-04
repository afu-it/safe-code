# safe-code reference: session hook — brief + save reminder (Claude Code)

> Loaded (Layer 3) only when the Session Hook Offer, or the `Stop` replacement, can actually be
> answered — an interactive session. A non-interactive run makes no offer, records nothing, and
> does not load this file. The binding rules (opt-in, never blocking, project-local personal
> settings only, never the user's global config) live in SKILL.md (Step 1, Session Hook Offer).
> The script keeps its name, `scripts/save-reminder.sh`, so existing installs keep working.

## What the hook does (for the offer text)

A `SessionStart` hook (matcher `startup|resume`) runs the shipped `scripts/save-reminder.sh`.
Read-only, always exit 0, no network, well under 300 ms; never commits, saves, or blocks.

- **Brief** (when `.safe-code/` exists, ≤ 15 lines, each ≤ 180 chars) into the agent's context:
  the `AGENTS.md` one-liner, `ACTIVE.md` `next_action:`, the Open Questions count + top 2, and a
  freshness warning when `HEAD` moved past `last_synced_commit:` with non-`Safe-Code:` commits.
  It never reads `current-issues.md` or `SESSION.md` content (only its markers). A pointer, not
  the source of truth.
- **Save reminder** to the user when the previous session left work unsaved. `SESSION.md`
  **holds work** when it has an `[~]` item, a done task annotated `files:`, or content under
  `## Drafts` (the same definition `--continue` merges by). Per brain layout: local-only or no
  git -> `[~]`, or `SESSION.md` newer than `.safe-code/.last-save` and holding work; team mode ->
  that test, plus any uncommitted change to the shared part of `.safe-code/` — except a wholly
  untracked `.safe-code/` whose `.last-save` is newer than every session file (a save that
  committed nothing on the default branch): then the message suggests
  `git switch -c safe-code/adopt` and committing there; tracked brain -> any
  `git status --porcelain -- .safe-code/` change (a `SESSION.md`-only change counts only when it
  holds work).
- Output: one JSON line — the brief in `hookSpecificOutput.additionalContext`, the reminder in
  top-level `systemMessage` only when unsaved. `--no-brief` = reminder only; `--plain` = text for
  hosts without a JSON hook contract; no `.safe-code/` or a non-`SessionStart` event -> silent.
  Full contract: the script header.

## Command per install type

The command points at the installed script and is guarded, so a missing script is silent:

- **Global install** — `f="$HOME/.agents/skills/safe-code/scripts/save-reminder.sh"; [ -f "$f" ] && bash "$f" || true`.
  One entry in the user's own global settings covers every project (the script finds the root
  itself): print that entry for the user — safe-code never edits global config.
- **Project install** — `f="$CLAUDE_PROJECT_DIR/.claude/skills/safe-code/scripts/save-reminder.sh"; [ -f "$f" ] && bash "$f" || true`.
- **Custom path** — the same shape with the absolute directory this skill was actually loaded
  from (`f="<skill-dir>/scripts/save-reminder.sh"; …`); never a guessed default.
- **Reminder only** — append `--no-brief` (`bash "$f" --no-brief`). Offer this in the same
  question; never ask twice.

## Hook JSON (merge into `hooks`, never replace the user's settings)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "f=\"$HOME/.agents/skills/safe-code/scripts/save-reminder.sh\"; [ -f \"$f\" ] && bash \"$f\" || true"
          }
        ]
      }
    ]
  }
}
```

## Merge steps

1. Target `<project-root>/.claude/settings.local.json` — personal and uncommitted, so one
   machine's hook path never lands in the team's `.claude/settings.json`. Create it only if the
   user accepted and it is missing; if `git check-ignore -q .claude/settings.local.json` fails,
   gitignore it at creation.
2. Add the `SessionStart` block above to `hooks`, keeping every existing hook and key.
3. No clean merge (invalid JSON, conflicting structure) -> print the block for the user to
   paste; never rewrite the file.

## Old `Stop` wiring (every run)

Where `.claude/settings.json` or `.claude/settings.local.json` exists, look for a safe-code
entry (a command naming `save-reminder.sh`) under `Stop`. Offers before 5.0 wired it there; the
script now ignores non-`SessionStart` events, so it silently never reminds. Found -> report it
and offer the replacement: remove that one `Stop` entry (leave every other hook) and add the
`SessionStart` block as above. Same opt-in rules; a declined replacement is recorded like a
declined offer.

## When to offer, and the answers

Offer on any interactive run under Claude Code in a git project while **neither** exists: a
safe-code entry in `.claude/settings.local.json`, or `save-reminder hook: declined` in
`user-preferences.md`. Not limited to the first run.

- Accepted -> merge; report `Save reminder: installed (SessionStart)`.
- Declined -> draft `save-reminder hook: declined (<date>)` into `user-preferences.md` (applied on
  `--save`); never re-offer.
- A global hook already covers it (the user says so) -> draft `save-reminder hook: declined
  (global hook exists)`; never re-offer (safe-code cannot see global config).
- Non-git project -> skip the offer; point at `integrations/claude-code/` in the skill source.
