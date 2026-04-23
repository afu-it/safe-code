---
name: safe-refactor-code
description: "Refactor code safely in small verified slices while keeping repo continuity docs in sync inside the active agent's own folder. Use when an agent is asked to refactor, restructure, clean up, remove or replace code, modernize modules, or do follow-up hygiene in a repo."
metadata:
  version: "1.2"
---

# Safe Refactor Code

Refactor code in small verified slices, then update the repo's continuity files so future agents can resume without rereading the whole session.

## Core Rules

- Treat `AGENTS.md` at repo root as the main long-term repo memory. Preserve existing content and update it carefully instead of rewriting blindly.
- Keep agent-local `MEMORY.md` short. It is a working summary for the repo, not a replacement for any shared or tool-managed memory system.
- Keep `safe-refactor-code.md` focused on the repo's refactor rules, guardrails, and recurring cleanup workflow.
- Update `CHANGELOG.md` on real code changes using today's section: `## [YYYY-MM-DD]`.
- Prefer additive or scoped edits to docs. Do not wipe user-written history unless the user explicitly asks.
- After refactors, scan for obvious dead code, unused imports, stale helpers, and outdated doc references before finishing.

## Agent Compatibility

- Write this skill so any AI agent can follow it, not only one product or runtime.
- Prefer generic terms such as "agent", "current repo", and "available verification tools".
- If the host environment has its own global or shared memory system, treat that as separate from repo-local docs.
- If the current repo uses different handoff files, adapt carefully but preserve the same responsibilities.

## Step 0: Detect Active Agent and Doc Folder

Before editing code or docs, detect which agent is running:

```
if .codex/ exists    → agent = codex,     doc folder = .codex/memory/
if .claude/ exists   → agent = claude,    doc folder = .claude/memory/
if .cursor/ exists   → agent = cursor,    doc folder = .cursor/memory/
if .windsurf/ exists → agent = windsurf,  doc folder = .windsurf/memory/
if none found        → doc folder = repo root
```

If multiple agent folders exist, prefer the one matching the current running agent.

Create `<agent-folder>/memory/` if it does not exist yet.

Doc file locations:

| File | Path |
|---|---|
| `AGENTS.md` | repo root (always) |
| `MEMORY.md` | `<agent-folder>/memory/MEMORY.md` |
| `CHANGELOG.md` | `<agent-folder>/memory/CHANGELOG.md` |
| `safe-refactor-code.md` | `<agent-folder>/memory/safe-refactor-code.md` |

## Workflow

### 1. Read Continuity Files First

Before editing code, inspect these files when present:

- `AGENTS.md` at repo root
- `<agent-folder>/memory/safe-refactor-code.md`
- `<agent-folder>/memory/MEMORY.md`
- `<agent-folder>/memory/CHANGELOG.md`

If one is missing, create it only if the refactor work makes it useful.

Fallback for missing `AGENTS.md`:

- Prefer an existing equivalent file such as `CLAUDE.md`, `GEMINI.md`, or another repo handoff guide at root.
- If an equivalent exists, treat it as the main continuity document for this run.
- If no equivalent exists, create `AGENTS.md` only when the refactor changes architecture or handoff risk enough that future agents would benefit.

### 2. Refactor in Safe Slices

- Prefer one subsystem or concern at a time.
- Preserve behavior unless the user asked for a behavior change.
- Verify each slice with the narrowest useful checks available: lint, type-check, tests, build, or targeted probe.
- If a refactor exposes dead code, remove obvious leftovers in the same area when confidence is high.
- If cleanup risk is non-trivial or the repo has many stale modules, map blast radius before deleting and flag low-confidence candidates instead of auto-removing.

If widespread dead code is detected beyond the immediate refactor area, invoke the `codebase-pruner` skill for a full repo dead code audit.

### 3. Sync Docs Before Finishing

After real code changes, update the continuity files in the detected doc folder:

- `AGENTS.md` (repo root) — current state, key decisions, blockers, handoff notes
- `safe-refactor-code.md` — repo-specific refactor constraints and recurring cleanup rules
- `MEMORY.md` — short current snapshot, active caveats, important paths
- `CHANGELOG.md` — today's dated section with Added, Changed, Fixed, Removed

### 4. Keep Changelog Shape Stable

Use this structure:

```md
## [YYYY-MM-DD]

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...
```

- Reuse today's section if it already exists.
- Omit empty subsections when nothing belongs there.
- Do not add a changelog entry for read-only review or analysis turns.

### 5. Finish With a Hygiene Pass

Before closing:

- Remove unused imports introduced by the refactor.
- Remove helpers, exports, or files made dead by the refactor when confidence is high.
- Update stale file/path references in docs.
- Note any flagged but unremoved dead code in `safe-refactor-code.md` or `AGENTS.md`.

## What To Write

### `AGENTS.md` (repo root)

Update only the sections affected by the refactor. Prefer:

- Current repo state
- Important architectural decisions
- Known blockers or caveats
- Where future agents should start

### `safe-refactor-code.md`

Use this file for repo-specific refactor instructions such as:

- Safe areas to touch
- Dangerous files or generated outputs
- Required verification commands
- Cleanup conventions
- Recurring migration or sync pitfalls

### `MEMORY.md`

Keep this concise. Good contents:

- Active architecture snapshot
- Current source-of-truth files
- Known temporary workarounds
- Top follow-up items

### `CHANGELOG.md`

Record only meaningful repo changes. Keep entries user-facing and concise.

## Triggers

Typical requests that activate this skill:

- "safe refactor this repo"
- "clean up after this refactor"
- "update agents and changelog too"
- "remove dead code after changing this flow"
- "keep repo memory in sync while refactoring"
- "make this refactor safer for future agents"
