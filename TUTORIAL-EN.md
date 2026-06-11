# safe-code Tutorial

safe-code gives any project one root agent entry point, long-term context files, feature specs, and safe session memory.

## 1. Install

```bash
npx skills add afu-it/safe-code
```

Optional global install:

```bash
npx skills add afu-it/safe-code -g
```

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
  CHANGELOG.md
  context/
    project-overview.md
    architecture.md
    user-preferences.md
    code-standards.md
    ai-workflow-rules.md
    ui-context.md
    progress-tracker.md
    current-issues.md
    feature-specs/00-template.md
```

`AGENTS.md` is the canonical entry point and `.safe-code/` holds all continuity (it is agent-agnostic and shared across Codex, Claude, Cursor, and Windsurf). Because not every host auto-reads `AGENTS.md`, safe-code also writes thin pointer files — `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc` — that redirect each host to the same brain.

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

safe-code writes `AGENTS.md` plus a thin pointer file for the host you're running in — `CLAUDE.md` (Claude), `GEMINI.md` (Gemini), `.github/copilot-instructions.md` (Copilot), or `.cursor/rules/safe-code.mdc` (Cursor). The other hosts' pointers are added lazily the first time you run safe-code under each, so you only ever carry bridges for tools you actually use. Open a fresh chat in a host that already has its bridge and it loads the same `.safe-code/context/` brain automatically, without you running anything. On each run safe-code also checks whether the context is stale (deps, folders, or scripts changed since it was last synced) and refreshes it, so a new chat never reads an outdated brain. After writing context it also self-tests it — a context-only check that it can answer the project basics — and fills any gaps it finds.

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

## 7. Old safe-code Projects

If a project already used an old layout, every safe-code command (`/safe-code`, `--continue`, `--save`) migrates safely:

- auto-detects old layouts: pre-v3 `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, and v3 `.agents/` + root `context/` + root `CHANGELOG.md`
- moves the files into `.safe-code/`
- patches old config to the new version (`.gitignore` entry, `AGENTS.md` path references)
- removes the emptied legacy folders
- never overwrites existing destination files — conflicts are reported for manual merge

You can also run the same migration deterministically with `bash scripts/migrate.sh --apply` (dry-run by default without `--apply`).

After migration, `.safe-code/context/` becomes the canonical project brain.

## 8. Resume Work

Use:

```text
/safe-code --continue
```

If you forget and type `/safe-code`, safe-code auto-detects saved unfinished work and resumes anyway.

## 9. Save Work

End a session with:

```text
/safe-code --save
```

Save applies drafted context/doc updates, writes resume state, appends safe logs, wipes temporary session memory, and splits the session into atomic conventional commits — local only. It never pushes.

Six-File Save Rule: every `/safe-code --save` updates all six session files in `.safe-code/`; files with no new content get a fresh date stamp.

## 10. Explain Your Project (read-only)

Forgot what your own project does? Ask for a plain-language briefing:

```text
/safe-code --explain
```

Plain phrases like "explain my project" work too. safe-code reads the project brain and tells you, in plain words, what the app does, the stack, where it's at, what's in progress, and any open questions. It makes no changes and no commits.

## 11. Helper Skills

You normally call only `/safe-code`.

safe-code internally uses helper skills when needed:

- `senior-dev`
- `build-graph`
- `explore-codebase`
- `codebase-pruner`
- `safe-refactor-code`
- `review-changes`
- `debug-issue`

Helper skills analyze first. Cleanup/refactor runs only when scoped and evidence-backed.
