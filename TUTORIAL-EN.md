# safe-code Tutorial

safe-code gives any project one root agent entry point, long-term context files, feature specs, and safe session memory.

## 1. Install

```bash
npx skills add afu-it/safe-code
```

Optional global install:

```bash
npx skills add afu-it/safe-code -g

# update later (keep the -g for a global install)
npx skills update -g
```

A global install lives in `~/.agents/skills/safe-code/`. A project install goes into your agent's project skills folder, for example `.agents/skills/safe-code/`. The bundled scripts sit in the `scripts/` folder inside it.

### What you need

- An agent that loads skills. No API key or account for safe-code itself.
- **bash** for the bundled scripts and the session hook: macOS and Linux out of the box, Windows through Git Bash or WSL.
- **git** is optional. Without it there is no rollback, so safe-code sets up the brain and runs plan-only: findings and drafts, no cleanup unless you approve it, and no commits.
- Any chat language works.
- **codegraph** is optional (section 10b); installing it needs Node (`npm`) or its official installer.

### Privacy

safe-code makes no network calls and sends nothing anywhere. Its scripts run offline. The only optional tool, codegraph (section 10b), sends anonymous usage stats; turn them off with `codegraph telemetry off` or `DO_NOT_TRACK=1`. When codegraph or the GitHub CLI is installed, safe-code may run their read-only checks (`codegraph upgrade --check`, `gh auth status`), which contact those services.

## 2. First Run

Inside a project, ask your agent:

```text
/safe-code
```

safe-code creates or reconciles only two artifacts at the repo root:

```text
AGENTS.md
.safe-code/
  ACTIVE.md
  SESSION.md
  LOG.md
  BACKLOG.md
  MEMORY.md
  safe-refactor-code.md
  CHANGELOG.md          (created on the first releasable change)
  .last-save            (save stamp for the session hook; gitignored)
  backups/              (copies taken before in-place rewrites; gitignored)
  context/
    project-overview.md
    architecture.md
    user-preferences.md
    code-standards.md
    ai-workflow-rules.md
    ui-context.md       (created when UI work starts)
    progress-tracker.md
    current-issues.md
    feature-specs/00-template.md
```

Setup also adds three lines to `.gitignore`: `/.safe-code/context/current-issues.md`, `/.safe-code/backups/`, and `/.safe-code/.last-save`.

A first run is a **setup** run: it fills the context from what it can prove in the repo, self-tests it, and does a findings-only audit (nothing is removed on a first run). A new or nearly empty project gets a **fresh** setup; an existing project with real history gets an **adopt** setup (section 6).

The first line of the reply tells you the state of the brain: `[safe-code: no project brain — initializing now]` on a first run, and `[safe-code: brain loaded @ <commit>]` in later sessions. Seeing it means the agent is working from the brain rather than improvising.

`AGENTS.md` is the canonical entry point and `.safe-code/` holds all continuity (it is agent-agnostic and shared across Codex, Claude, Cursor, Windsurf, and others). Most hosts read `AGENTS.md` on their own; under Claude Code, safe-code adds a thin pointer file (a "bridge") that redirects it to the same brain — see "Works in any host" below.

## 3. Read Order

Agents read `AGENTS.md` first. `AGENTS.md` points them to:

1. `.safe-code/context/project-overview.md`
2. `.safe-code/context/architecture.md`
3. `.safe-code/context/user-preferences.md`
4. `.safe-code/context/code-standards.md`
5. `.safe-code/context/ai-workflow-rules.md`
6. `.safe-code/context/ui-context.md` for UI work
7. `.safe-code/context/progress-tracker.md`
8. active spec in `.safe-code/context/feature-specs/`

Agents do not read `.safe-code/context/current-issues.md` during normal work — only on an issue trigger (you say "fix this", "failed", "got error", or paste a stack trace) or when you reference it.

Preference capture:

- If you say `I don't want`, `I prefer`, `please remove`, `always`, or `never`, safe-code treats it as a preference candidate.
- Durable preferences are drafted in `SESSION.md` and saved into `.safe-code/context/user-preferences.md` on `/safe-code --save`.

### Works in any host

safe-code writes `AGENTS.md`, and by default nothing else at the root. Two hosts need a little extra, and only when you run safe-code in that host:

- **Claude Code** gets a small `CLAUDE.md` with an `@AGENTS.md` import (added to your existing `CLAUDE.md` if you have one). Newer versions can read `AGENTS.md` by themselves, but only when no `CLAUDE.md` exists in the folder or any folder above it, so under Claude Code the bridge is always written.
- **Gemini CLI** reads only `GEMINI.md` by default. safe-code writes no file for it; it prints a snippet for you to add to `.gemini/settings.json`: `{"context":{"fileName":["AGENTS.md","GEMINI.md"]}}`.

Open a fresh chat in a host that can see the brain and it loads the same `.safe-code/context/` automatically, without you running anything. On each run safe-code also checks whether the context is stale (deps, folders, or scripts changed since it was last synced) and refreshes it, so a new chat never reads an outdated brain. After writing context it also self-tests it — a context-only check that it can answer the project basics — and fills any gaps it finds.

The generated `AGENTS.md` also carries **Grounding Rules**: in every session the agent must answer from your context files or the code itself (not from generic memory), verify a file or function exists before referencing it, and record unknowns as Open Questions instead of guessing.

Its `## Commands` section lists the commands an agent should run, each with its proof: `verified: <commit> · <date>` once it has run green (tests also record `known total: N`, the number of tests that run reported), or `unverified` when it was only found in config. A later test run with far fewer tests is treated as a warning, not a pass.

Every other host (Codex, Cursor, GitHub Copilot, Windsurf, Cline, Warp, Zed, Amp, RooCode, Kilo, and more) reads `AGENTS.md` natively, so it needs no pointer file at all; Copilot in VS Code does it through the `chat.useAgentsMdFile` setting. For Aider safe-code prints a one-line config suggestion you can apply yourself. Bridge files from an older safe-code version (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md`) are left in place, never deleted.

## 4. Feature Work

Ask for a feature:

```text
/safe-code build email login with verification
```

safe-code should draft an active spec first:

```text
.safe-code/context/feature-specs/01-email-login.md
```

Then it implements only that spec, verifies, and drafts progress updates in `SESSION.md`.

Every spec carries a `status:` field (`suggested` / `approved` / `in-progress` / `done` / `rejected`). New feature ideas are saved as `status: suggested` even if you do not build them yet — so they become referrable history. Approve one to build it; reject one and the spec is kept so the idea is not suggested again.

## 5. Current Issues

`.safe-code/context/current-issues.md` is a shared issue tracker. It is gitignored (`/.safe-code/context/current-issues.md`) and local only — never committed.

You can paste errors, reproduction steps, logs, or screenshot notes. The agent also writes here: whenever you report a problem ("fix this", "failed", "got error", or a pasted stack trace) it appends an entry, then flips it to resolved (with root cause + fix) once solved. Because the file may hold secrets, the agent never copies its raw content into committed files — a sanitized summary of each fix goes to `LOG.md` instead.

For a careful, plan-first pass, ask:

```text
Explore the current-issues.md file and deeply analyze the problem. Only when you have the analysis, give it back to me with the idea of how you're planning to solve it, and then wait for me to give you the green light to execute it.
```

The agent analyzes first and waits before fixing.

## 6. Existing Projects

For in-progress or finished projects, safe-code does not assume a blank slate.

It inspects repo evidence first:

- README files
- package manifests and lockfiles
- routes and entrypoints
- schemas and migrations
- tests and configs
- existing instruction files

Then it backfills context files from proven facts only. Unknowns go into `.safe-code/context/progress-tracker.md` Open Questions.

### Adding safe-code to an existing project

A project with 20 or more commits, or 30 or more source files, that never ran safe-code gets an **adopt** setup. A new project starts **fresh** instead. On top of the normal setup, adopt:

- **Reads your existing agent notes:** `CLAUDE.md`, `.cursorrules`, `.cursor/rules/`, `.windsurfrules`, `.github/copilot-instructions.md`, `GEMINI.md`, `memory-bank/`, ADRs and architecture docs under `docs/`, `CONTRIBUTING.md`, and `README.md`. Facts it can confirm in the code go into the brain tagged with their source (`[extracted: CLAUDE.md:12]`); the rest become Open Questions. Long documents are linked, not copied.
- **Reads the last 200 commits, read-only:** the most-changed files, decision-like commits (revert, migrate, replace, deprecate), branches active in the last 30 days, and how many people contribute. The top 10 `TODO` / `FIXME` / `HACK` comments become BACKLOG candidates, not promises.
- **Never changes those files.** Nothing is modified, moved, or deleted. Under Claude Code, the only addition is the marked bridge block at the end of `CLAUDE.md`. `CLAUDE.local.md` and `.env` files are never read.
- **Starts small on large repos.** Over ~300 source files (or ~50k lines), the first run reads manifests, configs, entry points, the most-changed files, and the top-level layout; the rest is listed under "Not Yet Specified" and read when your work reaches it. The banner shows the share it read: `Run: setup (adopt) · Coverage: ~40%`.
- **Suggests a branch.** In a team repo, or on the default branch of a repo with a remote, it suggests `git switch -c safe-code/adopt` before the first commit, so you can open a PR yourself. It never pushes. With no answer it creates no branch, and in team mode it commits nothing on the default branch.
- **Asks about your uncommitted work, once:** "Are these uncommitted changes your work in progress?" Yes, and they become the active task (still never committed for you). No, and they are left alone.

## 7. Old safe-code Projects

If a project already used an old layout, every safe-code command (`/safe-code`, `--continue`, `--save`) migrates safely:

- auto-detects old layouts: pre-v3 `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, and v3 `.agents/` + root `context/` + root `CHANGELOG.md` — but only when those folders hold safe-code's own session files
- moves only safe-code's own files into `.safe-code/` — your real subagents (`.claude/agents/*.md`) and skills (`.agents/skills/`) stay where they are
- patches old config to the new version (`.gitignore` entry, `AGENTS.md` path references)
- removes the emptied legacy folders
- never overwrites existing destination files — conflicts are reported for manual merge

You can also run the same migration deterministically with the script that ships inside the skill. From inside your project (global install shown; for a project install use your agent's project skills folder, e.g. `.agents/skills/safe-code/scripts/`):

```bash
bash ~/.agents/skills/safe-code/scripts/migrate.sh           # dry-run: shows what would move
bash ~/.agents/skills/safe-code/scripts/migrate.sh --apply   # move the files
bash ~/.agents/skills/safe-code/scripts/check.sh             # check the result (advisory warnings)
```

After migration, `.safe-code/context/` becomes the canonical project brain.

## 8. Resume Work

Use:

```text
/safe-code --continue
```

If you forget and type `/safe-code`, safe-code auto-detects saved unfinished work and resumes anyway.

If the last session ended without `--save`, its work is still in `SESSION.md`. `--continue` says so (`Unsaved work from the last session found in SESSION.md — merged into this run`) and merges those tasks and drafts into the new list — it never overwrites them. Run `/safe-code --save` when you want them kept for good.

## 8b. Light Runs and `--audit`

Once a project has a brain, a plain `/safe-code` is a **light run**: it loads the brain, checks it against the latest commit, resumes saved work or does what you asked, and stops there. It does not hunt for dead code, audit agent config, or sweep for refactors. The final banner says `hygiene pass skipped (light run; /safe-code --audit runs it)`.

When you want the full hygiene pass, ask for it:

```text
/safe-code --audit
```

Asking in your own words works too, in any language ("clean up the repo", "find dead code", "audit this project"). An audit run does everything a light run does, plus a dead-code audit, the agent config trust audit, and a refactor sweep. What actually changes still depends on the execution mode: **A** runs a safe plan, **B** shows the plan and waits for you, **C** reports findings only. Removals happen one verified slice at a time, each with a restore pointer. A targeted ask ("fix this bug", "rename X") is your task, not a sweep, so it stays a light run.

The first line of the final banner names the run: `Run: setup (fresh)`, `Run: setup (adopt) · Coverage: ~N%`, `Run: light`, or `Run: audit`.

## 9. Save Work

End a session with:

```text
/safe-code --save
```

Save applies the context/doc updates drafted during the session (kept under `SESSION.md ## Drafts`), writes resume state, appends safe logs, wipes temporary session memory, and splits the session into atomic conventional commits — local only. It never pushes.

Six-File Save Rule: every `/safe-code --save` updates all six session files in `.safe-code/`; files with no new content get a fresh date stamp.

Save also keeps the brain small. The context files have a budget of about 300 lines in total (`AGENTS.md` about 120): facts that went stale or were replaced by a newer entry move into `LOG.md` history, one line each, never deleted silently. The banner shows `Brain: N lines (budget 300)`. Commands that ran green this session get a fresh `verified:` stamp in `AGENTS.md`.

Every commit safe-code makes ends with a `Safe-Code: <version>` trailer. That is how the next run tells safe-code's own commits apart from new work when it checks whether the brain has drifted.

Save commits only the files this session touched. If something else changed in your working tree (another agent, another terminal, you), safe-code lists it as `foreign` and leaves it alone — it never reverts or commits changes it didn't make.

### Keep the brain out of git (local-only)

Prefer not to commit `.safe-code/`? Add `.safe-code/` (or `.safe-code/context/`) to `.gitignore`. safe-code detects either one on its own: `--save` still updates the six files on disk (it makes a backup first and checks nothing shrank by accident), commits only your code and setup changes, and the banner's `Brain:` line adds `local-only (gitignored)`. Ignoring only the session files (such as `SESSION.md`) is not a local-only brain; that is team mode (section 9b). The trade-off: the brain then lives only on this machine. Already committed it before? Git keeps tracking the files until you run `git rm -r --cached .safe-code` — safe-code prints that command for you but never runs it.

Save also runs a short **retro** — anything that made the agent slower or wronger this run (a file that was hard to find, a check that would have caught a mistake, a steering line that did nothing) lands in `BACKLOG.md` as a `retro:` item. Nothing found, nothing written.

Keep a personal journal outside the repo? Put its absolute path in `.safe-code/context/user-preferences.md` under `## Save Bridge` → `diary_path:` and every save appends one dated block there (plain recap, commits, next action). Append-only; safe-code never creates or commits that file. Prefer to keep the path out of the shared file? Put it in `.safe-code/context/user-preferences.local.md` instead: it overrides `user-preferences.md`, is never committed, and is gitignored when created (the place for it in team mode, section 9b).

### Session brief and save reminder (Claude Code)

Forgetting `--save` is the one real failure mode, and a new chat should not start blind. safe-code ships one optional hook for Claude Code that runs when a session starts:

- **Brief:** it hands the agent a short brief (at most 15 lines): what the project is, the next action from your last session, the open questions, and a warning when the brain is out of date. The agent starts oriented before it reads anything. The brief reads only those few lines, never `current-issues.md` or draft content.
- **Save reminder:** when the previous session left `.safe-code/` work unsaved, you see a one-line message telling you to run `/safe-code --save`. Nothing is shown otherwise.

It never commits, never blocks, and makes no network calls. `/safe-code` offers to install it on any run under Claude Code until you say yes or no. Yes writes it into `.claude/settings.local.json` for this project (not committed). If you already run it from a global hook, say so and safe-code stops offering. If the skill lives somewhere other than the usual folders, the offer uses the path it was loaded from. To cover every project, add it once yourself (global install):

```jsonc
// ~/.claude/settings.json
{"hooks":{"SessionStart":[{"matcher":"startup|resume","hooks":[{"type":"command","command":"f=\"$HOME/.agents/skills/safe-code/scripts/save-reminder.sh\"; [ -f \"$f\" ] && bash \"$f\" || true"}]}]}}
```

If the script is missing, the command just does nothing. Project install: use `f="$CLAUDE_PROJECT_DIR/.claude/skills/safe-code/scripts/save-reminder.sh"; [ -f "$f" ] && bash "$f" || true` in `.claude/settings.local.json` instead (escape the quotes as in the snippet above). Reminder only, no brief: add `--no-brief` after the script (`bash "$f" --no-brief`). On a host without JSON hooks, `--plain` prints plain text. Wired it under `Stop` with an older version? It stays silent there now; safe-code spots that entry on any run and offers to move it to `SessionStart`.

### Commit identity

Before the first commit of a run, safe-code checks `git config user.name` / `user.email`. Record the identity you want under `## Git Identity` in `.safe-code/context/user-preferences.local.md` (personal, never committed, overrides the shared file; the right place in team mode) or in `user-preferences.md`, and a mismatch stops the commit with the fix printed; leave it empty and safe-code still warns about `you@YourMachine.local` style emails (git derived them from your OS account) and, on GitHub, about a `gh` account that is not the repo owner. It never edits global git config and never pushes.

## 9b. Working in a Team

When more than one person has committed to the repo in the last 90 days (bots don't count; one person with several email addresses counts once, and one-off identities are ignored), safe-code switches to **team mode** on its own. You can also set it in `.safe-code/context/user-preferences.md` under `## Team Mode` with `team: on` or `team: off`. The banner shows `Team: on (N authors, 90d)`.

In team mode, the shared brain is committed so everyone gets it: `AGENTS.md`, `.safe-code/context/`, feature specs, and `BACKLOG.md`. Each developer's own session files (`ACTIVE.md`, `SESSION.md`, `LOG.md`, `MEMORY.md`, `safe-refactor-code.md`) stay on their machine. Personal values such as your git identity or a journal path go into `.safe-code/context/user-preferences.local.md`, which is never committed and overrides the shared file. The `team:` switch itself is read from the shared `user-preferences.md` only.

On the first team run, safe-code prints the `.gitignore` lines for the per-developer files and asks before adding them. If those files were committed earlier, it prints the `git rm --cached` command for you and never runs it. Context is written one fact per line, with new entries added at the end of a section, so two branches rarely conflict.

## 9c. Monorepos

A monorepo gets **one brain at the root**. safe-code finds it from anywhere inside the repo (the nearest folder holding `.safe-code/`, else the git top level), so running it from `packages/api/src/` uses the same brain.

A package with its own commands or gotchas can get a short `AGENTS.md` of its own (at most about 40 lines: package commands and gotchas only, no copies of the root rules). The root `AGENTS.md` links each one under `## Packages`. Agents that read `AGENTS.md` pick up the nearest one when they work in that folder; under Claude Code, safe-code adds a thin `CLAUDE.md` bridge next to it.

## 10. Explain Your Project (read-only)

Forgot what your own project does? Ask for a plain-language briefing:

```text
/safe-code --explain
```

Plain phrases like "explain my project" work too. safe-code reads the project brain and tells you, in plain words, what the app does, the stack, where it's at, what's in progress, and any open questions. It makes no changes and no commits.

## 10b. Knowledge Graph (optional)

Map your whole project into a queryable code graph (powered by the external [codegraph](https://github.com/colbymchenry/codegraph) tool, if installed):

```text
/safe-code --codegraph                       # build the graph + refresh the brain's navigation map
/safe-code --codegraph "how does auth work?"  # ask the graph a question (read-only)
```

If codegraph is not installed, safe-code asks once and remembers your answer. Say yes (under Claude Code this also auto-allows codegraph's read-only tools) and it runs, in order: `npm i -g @colbymchenry/codegraph` (no Node -> it prints the official installer for you), `codegraph install --target <this agent> --location global --yes` (wires the MCP server into only the agent you are using — a write outside your project, made only with your yes; an unknown agent gets the command printed instead), and `codegraph init`. Say no, or run headless, and it prints those commands and continues without the graph — an optional accelerator, never a requirement. The index lives in `.codegraph/` and is never committed. codegraph sends anonymous usage stats; turn them off with `codegraph telemetry off` or `DO_NOT_TRACK=1`. The old `--graphify` flag still works as an alias.

Build it once — after that it stays current: with the MCP server wired, the graph re-syncs on every file change; without it, every `/safe-code` run starts with `codegraph sync` (under a second). No manual rebuilds. The same graph powers dead-code audits, impact checks, and picking which tests to run.

## 11. Helper Skills

You normally call only `/safe-code`.

safe-code internally uses helper skills when needed:

- `senior-dev`
- `build-graph`
- `explore-codebase`
- `codebase-pruner`
- `safe-refactor-code`
- `review-changes` — reviews on two axes, Standards (your `code-standards.md` + a code-smell baseline) and Spec (did it do what the active spec asked: missing, scope creep, wrong), reported separately
- `debug-issue` — builds a command that reproduces the bug *before* forming any theory, shrinks the repro, ranks 3–5 falsifiable hypotheses, probes one variable at a time, writes the regression test at the right seam, and cleans up its tagged logs

Helper skills analyze first. Cleanup and refactor sweeps run only in an audit run (`--audit` or a cleanup ask), scoped and backed by evidence; a refactor you ask for directly runs in any run.

## 12. How safe-code knows it is done

Every task in a run carries its closing check before the work starts (`check: <command> · expect: <token>`) and closes only on an observed effect — never on "exit code 0" or a tool saying "success". If you asked for several things, safe-code lists each one in `SESSION.md ## Requested` and walks the list at the end; an unobserved item blocks the "complete" claim. A task that turns out impossible is marked `[!] abandoned` with a reason and shows up in the final banner — it is never quietly dropped. A task waiting on an approval the session cannot get (say, a cleanup plan in a headless run) is `[p] parked: needs approval`: still open, counted separately in the banner (`session ended · … parked …`), and carried into the next session. Every number in that banner is re-measured at report time, not copied from mid-run notes.

The banner opens with the run line (`Run: light · …`) and a `Brain:` line with the size of the context against its budget (plus `Team: on …` in team mode). It also tells you two things about git: `unpushed: N` when you have local commits not on the remote yet (left out when there are none; `no upstream` when the branch has no remote), and any `foreign` changes — files changed during the run that no task explains. safe-code reports those and leaves them as they are; it never reverts them. If another agent session is working in the same folder, safe-code says so at the start and suggests a separate worktree for longer work.

## 13. Uninstall

1. Remove the skill: `npx skills remove safe-code` (add `-g` for a global install). Remove any helper skills you installed with it the same way, e.g. `npx skills remove senior-dev build-graph explore-codebase codebase-pruner safe-refactor-code review-changes debug-issue`.
2. Remove the session hook, if you added it: delete the `SessionStart` entry whose command names `save-reminder.sh` (and any old `Stop` entry naming it) from `.claude/settings.local.json` (project) or `~/.claude/settings.json` (global). Leaving it is harmless; it goes silent once the script is gone.
3. In each project, remove the brain: `git rm -r .safe-code` when it is committed (it stays in git history), otherwise move `.safe-code/` to the trash.
4. Clean up the root files: delete `AGENTS.md` (and any nested package `AGENTS.md`) if safe-code created it (if you had your own, remove only the sections safe-code added); in `CLAUDE.md`, delete the block between `<!-- safe-code:bridge … -->` and `<!-- /safe-code:bridge -->`, or the whole file if safe-code created it. Bridges from older versions (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md`) can go too.
5. Remove the `.gitignore` lines `/.safe-code/context/current-issues.md`, `/.safe-code/backups/`, and `/.safe-code/.last-save`, any team-mode lines under `/.safe-code/`, and `.safe-code/` if you added it. If you built a code graph, run `codegraph uninit` in the project; `codegraph uninstall` removes the MCP wiring and `npm uninstall -g @colbymchenry/codegraph` removes the CLI.
