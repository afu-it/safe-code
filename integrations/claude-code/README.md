# Claude Code integration — never-lose-context reminder (opt-in)

`/safe-code --save` saves your session, but it only runs when **you** ask. A vibe
coder's biggest context-loss risk is forgetting it. This optional hook prints a nudge
when a session ends with unsaved safe-code work.

> Since v4.6, `/safe-code` offers to install a self-contained version of this hook for
> you on the first run under Claude Code (project-local `.claude/settings.json`, git
> repos only). The manual setup below still works everywhere, including non-git projects
> and other hosts.

**It only reminds — it never commits, saves, or blocks anything.**

## Install

1. Make sure `scripts/save-reminder.sh` is reachable. Either:
   - copy it into your project at `scripts/save-reminder.sh`, or
   - edit the path in `hooks.example.json` to point at your safe-code install.
2. Copy the `Stop` block from [`hooks.example.json`](./hooks.example.json) into your
   Claude Code settings — `~/.claude/settings.json` (all projects) or
   `.claude/settings.json` (this project). Merge it with any existing `hooks`.
3. That's it. When you end a session with uncommitted `.safe-code/` work, you'll see:
   `⚠️  safe-code: you have unsaved session work — run /safe-code --save before ending.`

## How it decides "unsaved"

- In a git repo: uncommitted changes under `.safe-code/` (since `--save` commits).
- No git repo: an in-progress task marker (`[~]`) in `.safe-code/SESSION.md`.
- No `.safe-code/` folder: silent (the project doesn't use safe-code).

## Other hosts

`save-reminder.sh` is host-agnostic. Wire it into the equivalent session-end hook for
your tool (Codex, Cursor, etc.); only the config wrapper differs, not the script.
