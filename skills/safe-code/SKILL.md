---
name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, initializes continuity doc structure, audits and removes dead code, refactors in safe slices, and keeps all docs in sync inside the agent's own folder. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go."
metadata:
  version: "1.2"
---

# Safe Code

Run a complete hygiene pass on the repo in the correct order. Always initialize docs first, then scan, then clean.

## Step 0: Detect Active Agent

Check which agent folder exists in the repo root:

```
if .codex/ exists    → agent = codex,     doc folder = .codex/memory/
if .claude/ exists   → agent = claude,    doc folder = .claude/memory/
if .cursor/ exists   → agent = cursor,    doc folder = .cursor/memory/
if .windsurf/ exists → agent = windsurf,  doc folder = .windsurf/memory/
if none found        → doc folder = repo root
```

If multiple agent folders exist, prefer the one matching the current running agent.

Record the detected agent and doc folder path — use it for all subsequent steps.

---

## Step 1: Initialize Doc Structure

Create the doc folder and all required files **before scanning the codebase**. Do this even if the repo is brand new and has no existing docs.

### 1a. Create the memory folder

```
<agent-folder>/memory/
```

Create this folder if it does not exist.

### 1b. Check and create each doc file

For each file below, check if it exists. If it does, leave it untouched. If it does not exist, create it using the template provided.

---

**`AGENTS.md`** — always at repo root

```md
# AGENTS.md

## Repo Overview
<!-- Brief description of what this repo does -->

## Current State
<!-- What is working, what is in progress -->

## Architecture
<!-- Key modules, folders, and how they connect -->

## Important Files
<!-- List the most important files and what they do -->

## Known Issues / Blockers
<!-- Anything future agents should know before starting -->

## Where to Start
<!-- Point future agents to the right entry file or module -->

## Last Updated
<!-- Date and summary of last agent session -->
```

---

**`<agent-folder>/memory/MEMORY.md`**

```md
# MEMORY.md

## Active Architecture Snapshot
<!-- Current structure of the codebase -->

## Source of Truth Files
<!-- Files that define the core behavior -->

## Active Workarounds
<!-- Temporary fixes or hacks that are still in place -->

## Follow-up Items
<!-- Things that still need to be done -->

## Last Updated
<!-- Date -->
```

---

**`<agent-folder>/memory/CHANGELOG.md`**

```md
# CHANGELOG.md

<!-- Record meaningful code changes by date. Format: -->
<!--                                                  -->
<!-- ## [YYYY-MM-DD]                                  -->
<!-- ### Added                                        -->
<!-- ### Changed                                      -->
<!-- ### Fixed                                        -->
<!-- ### Removed                                      -->
```

---

**`<agent-folder>/memory/safe-refactor-code.md`**

```md
# safe-refactor-code.md

## Safe Areas to Touch
<!-- Modules or files that are safe to refactor freely -->

## Dangerous Files / Generated Outputs
<!-- Files that should not be edited directly -->

## Required Verification Commands
<!-- Commands to run after each change, e.g. npm run lint, npm test -->

## Cleanup Conventions
<!-- Naming conventions, import order, file structure rules -->

## Flagged Dead Code (not yet removed)
<!-- Candidates that were found but not deleted due to uncertainty -->
<!-- Format: [date] path/to/file:functionName — reason for flagging -->

## Recurring Pitfalls
<!-- Things that broke before or are easy to get wrong -->
```

---

### 1c. Confirm initialization

Before proceeding, report:

```
Agent detected: <agent>
Doc folder: <agent-folder>/memory/
Files initialized:
  ✓ AGENTS.md (repo root)
  ✓ MEMORY.md
  ✓ CHANGELOG.md
  ✓ safe-refactor-code.md
```

Mark each file as either `created` (new) or `exists` (already present).

---

## Step 2: Read Existing Docs

Read all four docs to load context from previous sessions before touching any code:

- `AGENTS.md` — understand repo state and known blockers
- `MEMORY.md` — load current architecture snapshot
- `CHANGELOG.md` — understand what changed recently
- `safe-refactor-code.md` — load repo rules, flagged dead code, and pitfalls

If any doc has content, use it to inform the scan and refactor decisions in the steps below.

---

## Step 3: Audit Dead Code

Invoke `$codebase-pruner` in `Audit` mode.

- Map all live entrypoints.
- Build the reference graph.
- Produce a dead code inventory with confidence and blast radius for each candidate.
- Cross-reference with any candidates already flagged in `safe-refactor-code.md` — do not re-flag what is already known unless status has changed.
- Do not delete anything yet.

---

## Step 4: Review and Plan Removal

Invoke `$codebase-pruner` in `Dry-Run` mode.

- Generate the ordered removal plan with rollback points and verification commands.
- Flag Medium and Low confidence candidates — do not auto-delete them.
- Stop here and show the plan to the user if they want to review before execution.

---

## Step 5: Execute Dead Code Removal

Invoke `$codebase-pruner` in `Execute` mode.

- Delete High confidence candidates only, one slice at a time.
- Verify after each slice with the narrowest available check.
- Roll back and report on failure — do not continue past a failing slice.
- After execution, update `safe-refactor-code.md` with any newly flagged candidates that were not removed.

---

## Step 6: Refactor and Sync Docs

Invoke `$safe-refactor-code` on the affected areas.

- Refactor any code made messy by the removal.
- Run a final hygiene pass: unused imports, stale helpers, outdated doc references.
- Update all four docs with the results of this session:

| File | What to update |
|---|---|
| `AGENTS.md` | Current state, decisions made, where to start next session |
| `MEMORY.md` | Updated architecture snapshot, new workarounds, follow-up items |
| `CHANGELOG.md` | Add today's dated section with Added / Changed / Fixed / Removed |
| `safe-refactor-code.md` | New flagged candidates, updated rules, new pitfalls discovered |

---

## Step 7: Final Summary

Report everything that happened in this session:

```
=== safe-code session complete ===

Agent: <agent>
Doc folder: <agent-folder>/memory/

Initialization:
  AGENTS.md         — <created / already existed>
  MEMORY.md         — <created / already existed>
  CHANGELOG.md      — <created / already existed>
  safe-refactor-code.md — <created / already existed>

Dead code removed:
  <list of files/functions removed>

Dead code flagged (not removed):
  <list with reasons>

Refactors applied:
  <summary>

Docs updated:
  AGENTS.md, MEMORY.md, CHANGELOG.md, safe-refactor-code.md

Follow-up items for next session:
  <list>
```
