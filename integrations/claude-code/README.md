# Claude Code integration — session brief + never-lose-context reminder (opt-in)

`/safe-code --save` saves your session, but it only runs when **you** ask. The biggest
context-loss risk is forgetting it; the second is a fresh session that starts cold. This
optional `SessionStart` hook handles both:

- **Brief (to the agent)** — a short (at most 15 lines) summary of the project brain is
  added to Claude's context at session start: the project one-liner, the last session's next
  action, open questions, and a warning when commits landed since the brain was last synced.
- **Reminder (to you)** — a one-line notice when the previous session left safe-code work
  unsaved.

> `/safe-code` offers to install this hook for you on any run under Claude Code until it is
> installed or you decline (project-local `.claude/settings.local.json`; say you already have
> a global hook and it stops asking). The manual setup below works everywhere, including
> non-git projects and other hosts.

**It only reads and reminds — it never commits, saves, blocks, or touches the network.**

## Install

1. Make sure `save-reminder.sh` is reachable. It ships inside the skill at
   `<install>/safe-code/scripts/save-reminder.sh`. The hook command in
   `hooks.example.json` points at a global install:

   ```bash
   f="$HOME/.agents/skills/safe-code/scripts/save-reminder.sh"; [ -f "$f" ] && bash "$f" || true
   ```

   For a project install, swap the path for
   `$CLAUDE_PROJECT_DIR/.claude/skills/safe-code/scripts/save-reminder.sh` and keep the
   guard; for a skill installed anywhere else, use the directory it actually loads from
   (`<skill-dir>/scripts/save-reminder.sh`). The `[ -f ]` check and `|| true` keep the hook at exit 0 even if the skill is
   later removed.
2. Copy the `SessionStart` block from [`hooks.example.json`](./hooks.example.json) into
   your Claude Code settings — `~/.claude/settings.json` (all projects) or
   `.claude/settings.local.json` (this project only). Merge it with any existing `hooks`.
   Wired it under `Stop` with an older version? Move that entry to `SessionStart`
   (the script now ignores any hook event other than `SessionStart`, so a leftover
   `Stop` entry stays silent).
3. Want the reminder without the brief? Add `--no-brief` after the script path
   (`bash "$f" --no-brief`).
4. Done. Every new or resumed session in a project with a `.safe-code/` brain starts with the
   brief in Claude's context. When the last session left `.safe-code/` unsaved, Claude Code
   also shows you this notice:
   `safe-code: the last session left unsaved work in .safe-code/ - run /safe-code --save to keep it, or /safe-code --continue to resume.`

## How it works

- Wired as a `SessionStart` hook with matcher `startup|resume`, so it runs once when a
  session starts (not on every turn, and not after `/clear` or compaction).
- It prints one JSON object on stdout and exits 0:
  `hookSpecificOutput.additionalContext` carries the brief (Claude Code adds it to Claude's
  context before the first prompt), and a top-level `systemMessage` carries the reminder
  (shown to you as a notice) — present only when work is
  unsaved. Plain-text stdout from a `SessionStart` hook would go to Claude's context only,
  which is why the script prints JSON.
- The brief reads only a few headings: the `AGENTS.md` project line, `ACTIVE.md`
  `next_action:`, `progress-tracker.md` Open Questions and its sync stamp, and git history.
  It never reads `current-issues.md` or `SESSION.md` content, so it carries no secrets.
- No `.safe-code/` folder: it prints nothing. It always exits 0 and runs in well under a second.
- It reads the hook payload on stdin; when `hook_event_name` is anything other than
  `SessionStart` it exits silently. It starts looking for the project from the payload's
  `cwd`: the nearest folder with `.safe-code/` (never above the git toplevel), else the git
  toplevel — so it works from a monorepo package folder too.

## How it decides "unsaved"

`SESSION.md` **holds work** when it has an in-progress `[~]` item, a done `[x]` task
annotated `files:`, or content under `## Drafts`. A session that only rewrote the task list
did not leave anything to save.

- **Local-only brain** (`.gitignore` names `.safe-code/` or `.safe-code/context/` — even if
  its files are still tracked) or no git: a `[~]` item, or `SESSION.md` is newer than the stamp file
  `.safe-code/.last-save` that `--save` touches and holds work. Without that stamp only
  `[~]` counts.
- **Tracked brain** (`.safe-code/` committed in git): any uncommitted change under
  `.safe-code/` (`git status --porcelain -- .safe-code/`), since `--save` commits — except a
  change to `SESSION.md` alone, which counts only when it holds work.
- **Team mode** (only the per-developer session files are gitignored, the brain is
  committed): the local-only test above, plus any uncommitted change to the committed part of
  `.safe-code/` (context, backlog). When `.safe-code/` is wholly untracked and `.last-save` is
  newer than every session file — a save that committed nothing on the default branch (team
  adopt, branch declined) — the reminder suggests `git switch -c safe-code/adopt` and
  committing there instead of "run /safe-code --save".
- No `.safe-code/` folder: silent (the project doesn't use safe-code).

Full contract: the skill's `references/save-reminder-hook.md`.

## Other hosts

`save-reminder.sh` is host-agnostic. Pass `--plain` to get plain text (the brief, with the
reminder line when work is unsaved) instead of JSON, and wire it into your tool's
session-start hook (or run it by hand). Add `--no-brief` for the reminder line alone:

```bash
bash <install>/safe-code/scripts/save-reminder.sh --plain [--no-brief] [project-root]
```
