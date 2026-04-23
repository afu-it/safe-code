---
name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, initializes continuity doc structure inside the current project only, audits and removes dead code, refactors in safe slices, and keeps all docs in sync. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go."
metadata:
  version: "1.5"
---

# Safe Code

Run a complete repo hygiene pass autonomously. Think before acting. Make decisions independently. Only ask the user when a decision cannot be reversed or when intent is genuinely unclear.

## Scope Rule (Read This First)

**Everything operates inside the current project root only.**

- Never read from or write to paths outside the current project root
- Never use `~/`, `~/.codex/`, `~/.claude/`, or any home directory path
- All paths are relative to the project root
- The project root is the directory where the agent was invoked

```
CORRECT: <project-root>/.codex/memory/MEMORY.md
WRONG:   ~/.codex/memory/MEMORY.md
```

---

## How to Make Decisions (Read Before Every Step)

Before taking any action, reason through it explicitly. Do not guess. Do not skip this.

### Decision Framework

For every decision in this skill, ask:

1. **What are the 2-3 options here?**
2. **What does each option risk or preserve?**
3. **Which option is safest given what I know?**
4. **Can this be undone if I'm wrong?**

If the answer to (4) is "no" — stop and show the user the options before acting.
If the answer to (4) is "yes" — proceed with the safest option and log your reasoning.

### When to Act Autonomously

Act without asking when:
- The action is reversible (git tracked, or file can be restored)
- Confidence is High (zero references, no dynamic risk)
- The decision is technical, not about user intent
- The answer is discoverable from the codebase itself

### When to Stop and Ask

Stop and ask the user when:
- The action is irreversible (no git, no backup)
- Confidence is Medium or Low
- Two options have equal trade-offs and the choice depends on user preference
- Something unexpected is found that changes the scope significantly

### Reasoning Format

Before each significant action, write a short reasoning block:

```
Reasoning:
  Options considered: <list>
  Risk of each: <list>
  Decision: <chosen option>
  Why: <one sentence>
  Reversible: yes/no
```

This keeps decisions transparent and auditable without requiring user input for every step.

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

Never fall back to the project root itself as the doc folder.
Never use any path outside the project root.

If multiple agent folders exist — reason through which one matches the current running agent. Do not ask the user.

---

## Step 1: Initialize Doc Structure

Create the memory folder and all required files **before reading the codebase**.

### 1a. Create the memory folder

```
<project-root>/<agent-folder>/memory/
```

Create if it does not exist.

### 1b. Check and create each doc file

For each file — if it exists, leave it completely untouched. If it does not exist, create it with the template below.

---

**`<project-root>/AGENTS.md`** — project root only.

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

```
Project root: <absolute path>
Agent: <agent>
Doc folder: <project-root>/<agent-folder>/memory/

Files:
  AGENTS.md (project root)        — <created | already exists>
  MEMORY.md                       — <created | already exists>
  CHANGELOG.md                    — <created | already exists>
  safe-refactor-code.md           — <created | already exists>

All paths confirmed inside project root. Proceeding.
```

---

## Step 2: Read Existing Docs

Read all four docs to load context from previous sessions:

- `<project-root>/AGENTS.md`
- `<project-root>/<agent-folder>/memory/MEMORY.md`
- `<project-root>/<agent-folder>/memory/CHANGELOG.md`
- `<project-root>/<agent-folder>/memory/safe-refactor-code.md`

Do not read any file from outside the project root.

Apply the context — if previous sessions flagged dead code candidates or noted pitfalls, carry that forward into this session's decisions.

---

## Step 3: Assess Repo State and Check Git

Before scanning, assess risk level:

```
Check git status:
  if git repo exists AND has commits → rollback available → proceed to Execute mode after plan
  if git repo exists BUT no commits  → no rollback → plan only, warn user before executing
  if no git repo                     → no rollback → plan only, require explicit user approval

Check worktree:
  if dirty (uncommitted changes) → note this, do not overwrite user changes
  if clean → safe to proceed
```

Reasoning:

```
Reasoning:
  Git state: <found | not found | found but no commits>
  Rollback available: yes/no
  Decision: <proceed to auto-execute | require manual approval>
  Why: <one sentence>
```

---

## Step 4: Audit Dead Code

Invoke `$codebase-pruner` in `Audit` mode.

During audit, apply the decision framework actively:

- When classifying a candidate as High vs Medium confidence — reason through it explicitly
- When blast radius is unclear — widen the scan before classifying, do not guess
- Cross-reference with candidates already flagged in `safe-refactor-code.md`
- Do not delete or modify any file in this step

---

## Step 5: Plan and Decide Execution Mode

After audit, reason through the execution approach:

```
Reasoning:
  High confidence candidates found: <count>
  Rollback available: yes/no
  Risk level: low/medium/high
  Options:
    A) Auto-execute High confidence slices, show results after
    B) Show full plan, wait for approval, then execute
    C) Show plan only (Dry-Run), no execution this session
  Decision: <A | B | C>
  Why: <one sentence>
```

**Choose A** when: git is clean, rollback available, all candidates are High confidence, no surprises found in audit.

**Choose B** when: git is dirty, or some candidates are borderline, or scope is larger than expected.

**Choose C** when: no git, no rollback, or user explicitly asked for plan only.

If choosing B or C, show the plan:

```
=== Dead Code Removal Plan ===

Project root: <path>
Agent: <agent>
Execution mode: <A | B | C> — <reason>

Proposed removals:
  Slice 1 — <description>
    Files: <list>
    Confidence: High
    Verification: <command>
    Rollback: <git command or manual note>

  Slice 2 — ...

Flagged but NOT in plan:
  - <file:function> — <reason>
```

If B: append `Reply "yes" to execute, or tell me what to skip.` and wait.
If C: append `Plan only — no files will be changed this session.`

---

## Step 6: Execute Dead Code Removal

Run `$codebase-pruner` in `Execute` mode.

For each slice:
- Delete only approved candidates
- Verify with the narrowest available check
- If verification fails — reason through whether it is a false alarm or a real breakage before rolling back
- Roll back only the failing slice, not the whole session
- Save newly flagged candidates to `safe-refactor-code.md`

---

## Step 7: Refactor and Sync Docs

Run `$safe-refactor-code` on affected areas.

Update all four docs:

| File | What to update |
|---|---|
| `<project-root>/AGENTS.md` | Current state, decisions made this session, where to start next |
| `<project-root>/<agent-folder>/memory/MEMORY.md` | Updated architecture snapshot, follow-up items |
| `<project-root>/<agent-folder>/memory/CHANGELOG.md` | Today's dated section |
| `<project-root>/<agent-folder>/memory/safe-refactor-code.md` | Flagged candidates, new rules, pitfalls discovered |

---

## Step 8: Final Summary

```
=== safe-code session complete ===

Project root: <path>
Agent: <agent>
Doc folder: <project-root>/<agent-folder>/memory/
Execution mode used: <A | B | C>

Initialization:
  AGENTS.md             — <created | already existed>
  MEMORY.md             — <created | already existed>
  CHANGELOG.md          — <created | already existed>
  safe-refactor-code.md — <created | already existed>

Decisions made this session:
  <list of key decisions with brief reasoning>

Dead code removed:
  <list>

Dead code flagged (not removed):
  <list — saved to safe-refactor-code.md>

Refactors applied:
  <summary>

Docs updated:
  All inside <project-root>/<agent-folder>/memory/

Follow-up items:
  <list>
```
