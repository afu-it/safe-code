---
name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, initializes continuity doc structure inside the current project only, audits and removes dead code, refactors in safe slices, and keeps all docs in sync. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go."
metadata:
  version: "1.4"
---

# Safe Code

Run a complete hygiene pass on the repo in the correct order. Always initialize docs first, then scan, then show the plan, then wait for user approval before deleting anything.

## Scope Rule (Read This First)

**Everything in this skill operates inside the current project root only.**

- Never read from or write to the user's home directory (`~/`, `~/.codex/`, `~/.claude/`, etc.)
- Never read from or write to any path outside the current project root
- All file paths are relative to the project root
- The project root is the directory where the agent was invoked

```
CORRECT paths (inside project):
  <project-root>/.codex/memory/MEMORY.md
  <project-root>/.claude/memory/MEMORY.md
  <project-root>/AGENTS.md

WRONG paths (outside project — never use these):
  ~/.codex/memory/MEMORY.md
  ~/.claude/memory/MEMORY.md
  ~/AGENTS.md
```

---

## Step 0: Detect Active Agent

Inside the **project root**, check which agent folder exists:

```
if <project-root>/.codex/ exists    → doc folder = <project-root>/.codex/memory/
if <project-root>/.claude/ exists   → doc folder = <project-root>/.claude/memory/
if <project-root>/.cursor/ exists   → doc folder = <project-root>/.cursor/memory/
if <project-root>/.windsurf/ exists → doc folder = <project-root>/.windsurf/memory/
if none detected                    → create <project-root>/.codex/memory/ and use it
```

**Never fall back to the project root itself as the doc folder.**
**Never use any path outside the project root.**

If no agent folder is detected, create `<project-root>/.codex/memory/` and continue. Do not ask the user — just proceed.

If multiple agent folders exist, prefer the one matching the current running agent.

---

## Step 1: Initialize Doc Structure

Create the doc folder and all required files **before reading the codebase or making any changes**.

### 1a. Create the memory folder

Create `<project-root>/<agent-folder>/memory/` if it does not exist.

### 1b. Check and create each doc file

For each file — check if it exists first. If it exists, **leave it completely untouched**. If it does not exist, create it with the template below.

---

**`<project-root>/AGENTS.md`** — project root only. Do not create this anywhere else.

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

**`<project-root>/<agent-folder>/memory/MEMORY.md`**

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

**`<project-root>/<agent-folder>/memory/CHANGELOG.md`**

```md
# CHANGELOG.md

<!-- Record meaningful code changes by date. Format:  -->
<!--                                                   -->
<!-- ## [YYYY-MM-DD]                                   -->
<!-- ### Added                                         -->
<!-- ### Changed                                       -->
<!-- ### Fixed                                         -->
<!-- ### Removed                                       -->
```

---

**`<project-root>/<agent-folder>/memory/safe-refactor-code.md`**

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

Report before proceeding:

```
Project root: <absolute path to project root>
Agent detected: <agent>
Doc folder: <project-root>/<agent-folder>/memory/

Files:
  AGENTS.md (project root)        — <created | already exists>
  MEMORY.md                       — <created | already exists>
  CHANGELOG.md                    — <created | already exists>
  safe-refactor-code.md           — <created | already exists>

All paths are inside the project. Ready to scan.
```

---

## Step 2: Read Existing Docs

Read all four docs from inside the project to load context from previous sessions:

- `<project-root>/AGENTS.md`
- `<project-root>/<agent-folder>/memory/MEMORY.md`
- `<project-root>/<agent-folder>/memory/CHANGELOG.md`
- `<project-root>/<agent-folder>/memory/safe-refactor-code.md`

Do not read any file from outside the project root.

Use this context to inform all decisions below.

---

## Step 3: Audit Dead Code

Invoke `$codebase-pruner` in `Audit` mode.

- Map all live entrypoints inside the project.
- Build the reference graph from imports, config files, and runtime wiring.
- Produce a dead code inventory with confidence and blast radius for each candidate.
- Cross-reference with candidates already flagged in `safe-refactor-code.md`.
- Do not delete or modify any file in this step.

---

## Step 4: Show Plan and Wait for Approval

**Mandatory. Do not skip. Do not proceed to Step 5 without explicit user approval.**

Invoke `$codebase-pruner` in `Dry-Run` mode and show the plan:

```
=== Dead Code Removal Plan ===

Project root: <path>
Agent: <agent>
Doc folder: <project-root>/<agent-folder>/memory/

Proposed removals:
  Slice 1 — <description>
    Files: <list>
    Confidence: High
    Verification: <command>
    Rollback: git checkout -- <files>

  Slice 2 — ...

Flagged but NOT in plan (manual review needed):
  - <file:function> — <reason>

Reply "yes" or "approve" to execute, or tell me what to skip.
```

Wait for explicit user approval before continuing.

---

## Step 5: Execute Dead Code Removal

Only after user approval in Step 4.

Invoke `$codebase-pruner` in `Execute` mode.

- Delete only approved slices, one at a time.
- Verify after each slice.
- Roll back on failure — do not continue past a failing slice.
- Save newly flagged candidates to `<project-root>/<agent-folder>/memory/safe-refactor-code.md`.

---

## Step 6: Refactor and Sync Docs

Invoke `$safe-refactor-code` on affected areas only.

Update all four docs inside the project:

| File | What to update |
|---|---|
| `<project-root>/AGENTS.md` | Current state, decisions, where to start next |
| `<project-root>/<agent-folder>/memory/MEMORY.md` | Architecture snapshot, follow-up items |
| `<project-root>/<agent-folder>/memory/CHANGELOG.md` | Today's dated section |
| `<project-root>/<agent-folder>/memory/safe-refactor-code.md` | Flagged candidates, rules, pitfalls |

---

## Step 7: Final Summary

```
=== safe-code session complete ===

Project root: <path>
Agent: <agent>
Doc folder: <project-root>/<agent-folder>/memory/

Initialization:
  AGENTS.md             — <created | already existed>
  MEMORY.md             — <created | already existed>
  CHANGELOG.md          — <created | already existed>
  safe-refactor-code.md — <created | already existed>

Dead code removed:
  <list>

Dead code flagged (not removed):
  <list — saved to safe-refactor-code.md>

Refactors applied:
  <summary>

Docs updated:
  All paths inside <project-root>/<agent-folder>/memory/

Follow-up items:
  <list>
```
