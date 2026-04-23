---
name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, audits and removes dead code, refactors in safe slices, and keeps continuity docs in sync inside the agent's own folder. Use when asked to do a full cleanup, full hygiene pass, safe-code, or maintain a repo in one go."
metadata:
  version: "1.1"
---

# Safe Code

Run a complete hygiene pass on the repo in the correct order. This skill orchestrates `codebase-pruner` and `safe-refactor-code` so dead code removal and doc sync happen in a single controlled session.

## When to Use

Use this skill when the user wants to:

- run `/safe-code` for a full cleanup
- remove dead code and keep docs in sync in one go
- maintain a repo after a workflow or architecture change
- do a full hygiene pass from start to finish

## Step 0: Detect Active Agent

Before doing anything, detect which agent is running by checking which agent folder exists in the repo root:

```
if .codex/ exists   → agent = codex,    doc folder = .codex/memory/
if .claude/ exists  → agent = claude,   doc folder = .claude/memory/
if .cursor/ exists  → agent = cursor,   doc folder = .cursor/memory/
if .windsurf/ exists → agent = windsurf, doc folder = .windsurf/memory/
if none found       → doc folder = repo root
```

If multiple agent folders exist, prefer the one matching the current running agent.

Create the `memory/` subfolder inside the detected agent folder if it does not exist yet.

`AGENTS.md` always stays at the repo root — it is agent-agnostic and readable by all agents.

## Step 1: Audit Dead Code

Invoke `$codebase-pruner` in `Audit` mode.

- Map entrypoints and build the reference graph.
- Produce the dead code inventory with confidence and blast radius scores.
- Do not delete anything yet.

## Step 2: Review and Plan Removal

Invoke `$codebase-pruner` in `Dry-Run` mode.

- Generate the ordered removal plan with rollback points and verification commands.
- Flag Medium and Low confidence candidates for user review.
- Stop here if the user wants to review the plan before execution.

## Step 3: Execute Dead Code Removal

Invoke `$codebase-pruner` in `Execute` mode.

- Delete High confidence candidates only, slice by slice.
- Verify after each slice.
- Roll back and report on failure — do not continue past a failing slice.

## Step 4: Refactor and Sync Docs

Invoke `$safe-refactor-code` on the affected areas.

- Refactor any code made messy by the removal.
- Sync continuity docs into the detected agent folder:
  - `<agent-folder>/memory/MEMORY.md`
  - `<agent-folder>/memory/CHANGELOG.md`
  - `<agent-folder>/memory/safe-refactor-code.md`
  - `AGENTS.md` at repo root
- Run a final hygiene pass to catch stale imports or doc references.

## Step 5: Final Summary

Report:

- active agent detected and doc folder used
- dead code removed
- refactors applied
- docs updated and their paths
- candidates flagged but not removed and why
- follow-up items for the next session
