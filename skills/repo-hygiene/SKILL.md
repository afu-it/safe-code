---
name: repo-hygiene
description: "Full repo hygiene in one pass. Audits and removes dead code, refactors in safe slices, and keeps AGENTS.md, MEMORY.md, CHANGELOG.md, and safe-refactor-code.md in sync. Use when asked to do a full cleanup, full hygiene pass, or maintain a repo in one go."
metadata:
  version: "1.0"
---


# Repo Hygiene


Run a complete hygiene pass on the repo in the correct order. This skill orchestrates `codebase-pruner` and `safe-refactor-code` so both dead code removal and doc sync happen in a single controlled session.


## When to Use


Use this skill when the user wants to:


- do a full cleanup pass on a repo
- remove dead code and keep docs in sync in one go
- maintain a repo after a workflow or architecture change
- run "safe-code" on a project from start to finish


## Workflow


### 1. Audit dead code first


Invoke `$codebase-pruner` in `Audit` mode.


- Map entrypoints and build the reference graph.
- Produce the dead code inventory with confidence and blast radius scores.
- Do not delete anything yet.


### 2. Review and plan removal


Invoke `$codebase-pruner` in `Dry-Run` mode.


- Generate the ordered removal plan with rollback points and verification commands.
- Flag Medium and Low confidence candidates for user review.
- Stop here if the user wants to review the plan before execution.


### 3. Execute dead code removal


Invoke `$codebase-pruner` in `Execute` mode.


- Delete High confidence candidates only, slice by slice.
- Verify after each slice.
- Roll back and report on failure — do not continue past a failing slice.


### 4. Refactor and sync docs


Invoke `$safe-refactor-code` on the affected areas.


- Refactor any code made messy by the removal.
- Sync `AGENTS.md`, `MEMORY.md`, `CHANGELOG.md`, and `safe-refactor-code.md`.
- Run a final hygiene pass to catch stale imports or doc references.


### 5. Final summary


Report:


- dead code removed
- refactors applied
- docs updated
- candidates flagged but not removed and why
- follow-up items for the next session
