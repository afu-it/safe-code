---
name: safe-refactor-code
description: "Refactor code safely in small verified slices while keeping repo continuity docs in sync. Use when an agent is asked to refactor, restructure, clean up, remove or replace code, modernize modules, or do follow-up hygiene in a repo that maintains AGENTS.md as main memory plus repo-local safe-refactor-code.md, MEMORY.md, and CHANGELOG.md."
metadata:
  version: "1.1"
---


# Safe Refactor Code


Refactor code in small verified slices, then update the repo's continuity files so future agents can resume without rereading the whole session.


## Core Rules


- Treat `AGENTS.md` as the main long-term repo memory. Preserve existing content and update it carefully instead of rewriting blindly.
- Keep repo-local `MEMORY.md` short. It is a working summary for the repo, not a replacement for any shared or tool-managed memory system.
- Keep `safe-refactor-code.md` focused on the repo's refactor rules, guardrails, and recurring cleanup workflow.
- Update `CHANGELOG.md` on real code changes using today's section: `## [YYYY-MM-DD]`.
- Prefer additive or scoped edits to docs. Do not wipe user-written history unless the user explicitly asks.
- After refactors, scan for obvious dead code, unused imports, stale helpers, and outdated doc references before finishing.


## Agent Compatibility


- Write this skill so any AI agent can follow it, not only one product or runtime.
- Prefer generic terms such as "agent", "current repo", and "available verification tools".
- Keep file conventions explicit: `AGENTS.md`, `safe-refactor-code.md`, `MEMORY.md`, `CHANGELOG.md`.
- If a host environment also has its own global/shared memory system, treat that as separate from repo-local `MEMORY.md`.
- If the current repo uses different handoff files, adapt carefully but preserve the same responsibilities.
- If `AGENTS.md` does not exist, use the nearest equivalent handoff file already present, such as `CLAUDE.md`, `GEMINI.md`, or a repo-level operations guide. If no equivalent exists, create `AGENTS.md` only when the refactor introduces enough continuity value to justify it.
- If `MEMORY.md` does not exist, create it only when a short repo-local snapshot will materially help future agents resume work.
- If `CHANGELOG.md` does not exist, create it only when the repo is actually tracking meaningful code changes in changelog form.


## Workflow


### 1. Read local continuity files first


Before editing code, inspect these files when present:


- `AGENTS.md`
- `safe-refactor-code.md`
- `MEMORY.md`
- `CHANGELOG.md`


If one is missing, create it only if the refactor work makes it useful.


Fallback for missing `AGENTS.md`:


- Prefer an existing equivalent file such as `CLAUDE.md`, `GEMINI.md`, or another repo handoff guide.
- If an equivalent file exists, treat it as the main continuity document for this run.
- If no equivalent exists, create `AGENTS.md` only when the refactor changes architecture, workflow, or handoff risk enough that future agents would benefit from it.


Fallback for missing `MEMORY.md`:


- If a repo-local working snapshot would help, create `MEMORY.md` with only current truths, key caveats, and likely next steps.
- If the repo already has enough continuity in `AGENTS.md` or an equivalent handoff file, do not create `MEMORY.md` just for symmetry.


Fallback for missing `CHANGELOG.md`:


- If the repo already uses a changelog, preserve its existing format.
- If no changelog exists, create `CHANGELOG.md` only when the repo benefits from dated change tracking for ongoing work.
- If the repo does not use changelog-style documentation, put important continuity notes in `AGENTS.md` or the equivalent handoff file instead of forcing a new changelog habit.


### 2. Refactor in safe slices


- Prefer one subsystem or concern at a time.
- Preserve behavior unless the user asked for a behavior change.
- Verify each slice with the narrowest useful checks available: lint, type-check, tests, build, or targeted probe.
- If a refactor exposes dead code, remove the obvious leftovers in the same area when confidence is high.
- If cleanup risk is non-trivial or the repo has many stale modules, map blast radius before deleting and flag low-confidence candidates instead of auto-removing.

If widespread dead code is detected beyond the immediate refactor area, invoke the `codebase-pruner` skill for a full repo dead code audit.


### 3. Sync repo docs before finishing


After real code changes, update the continuity files:


- `AGENTS.md`: current state, key decisions, blockers, handoff notes
- `safe-refactor-code.md`: repo-specific refactor constraints and recurring cleanup rules
- `MEMORY.md`: short current snapshot, active caveats, important paths
- `CHANGELOG.md`: today's dated section with `Added`, `Changed`, `Fixed`, `Removed`


### 4. Keep changelog shape stable


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


### 5. Finish with a hygiene pass


Before closing:


- remove unused imports introduced by the refactor
- remove helpers, exports, or files made dead by the refactor when confidence is high
- update stale file/path references in docs
- note any flagged but unremoved dead code in `safe-refactor-code.md` or `AGENTS.md`


## What To Write


### `AGENTS.md`


Update only the sections affected by the refactor. Prefer:


- current repo state
- important architectural decisions
- known blockers or caveats
- where future agents should start


### `safe-refactor-code.md`


Use this file for repo-specific refactor instructions such as:


- safe areas to touch
- dangerous files or generated outputs
- required verification commands
- cleanup conventions
- recurring migration or sync pitfalls


### `MEMORY.md`


Keep this concise. Good contents:


- active architecture snapshot
- current source-of-truth files
- known temporary workarounds
- top follow-up items


### `CHANGELOG.md`


Record only meaningful repo changes. Keep entries user-facing and concise.


## Triggers


Typical requests that should use this skill:


- "safe refactor this repo"
- "clean up after this refactor"
- "update agents and changelog too"
- "remove dead code after changing this flow"
- "keep repo memory in sync while refactoring"
- "make this refactor safer for future agents"
