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

safe-code creates or reconciles:

```text
AGENTS.md
CHANGELOG.md
context/
  project-overview.md
  architecture.md
  code-standards.md
  ai-workflow-rules.md
  ui-context.md
  progress-tracker.md
  current-issues.md
  feature-specs/00-template.md
.agents/
  ACTIVE.md
  SESSION.md
  LOG.md
  BACKLOG.md
  MEMORY.md
  safe-refactor-code.md
```

The `.agents/` folder is agent-agnostic and shared across Codex, Claude, Cursor, and Windsurf, so session continuity stays with the project.

## 3. Read Order

Agents read `AGENTS.md` first. `AGENTS.md` points them to:

1. `context/project-overview.md`
2. `context/architecture.md`
3. `context/user-preferences.md`
4. `context/code-standards.md`
5. `context/ai-workflow-rules.md`
6. `context/ui-context.md` for UI work
7. `context/progress-tracker.md`
8. active spec in `context/feature-specs/`

Agents do not read `context/current-issues.md` unless you explicitly ask for issue/debug analysis.

Preference capture:

- If you say `I don't want`, `I prefer`, `please remove`, `always`, or `never`, safe-code treats it as a preference candidate.
- Durable preferences are drafted in `SESSION.md` and saved into `context/user-preferences.md` on `/safe-code --save`.

## 4. Feature Work

Ask for a feature:

```text
/safe-code build email login with verification
```

safe-code should draft an active spec first:

```text
context/feature-specs/01-email-login.md
```

Then it implements only that spec, verifies, and drafts progress updates in `SESSION.md`.

## 5. Current Issues

`context/current-issues.md` is for you to write manually. It is gitignored and local only.

Use it for errors, reproduction steps, logs, or screenshots notes.

When ready, ask:

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

Then it backfills context files from proven facts only. Unknowns go into `context/progress-tracker.md` Open Questions.

## 7. Old safe-code Projects

If a project already used the old continuity-only method, `/safe-code` migrates safely:

- keeps old `.codex/agents/*` or `.agents/*` files
- drafts new `context/` files from old docs and repo evidence
- writes final context updates only on `/safe-code --save`

After save, `context/` becomes the canonical project brain.

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

Save applies drafted context/doc updates, writes resume state, appends safe logs, wipes temporary session memory, and creates a local commit only. It never pushes.

## 10. Helper Skills

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
