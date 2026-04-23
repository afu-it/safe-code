name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, auto-detects saved sessions from ACTIVE.md, initializes all 7 continuity docs inside the current project only, audits and removes dead code, refactors in safe slices, and keeps all docs in sync. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go. Use /safe-code save to checkpoint and commit the current session."
metadata:
  version: "1.8"
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
CORRECT: <project-root>/.codex/agents/ACTIVE.md
WRONG:   ~/.codex/agents/ACTIVE.md
```

---

## Doc Structure

```
<project-root>/
├── AGENTS.md           <- Rules for AI (set once, update rarely)
├── CHANGELOG.md        <- Release history (update on release only)
└── .codex/
    └── agents/
        ├── MEMORY.md            <- Architecture snapshot
        ├── safe-refactor-code.md <- Refactor rules & flagged code
        ├── ACTIVE.md            <- What is happening RIGHT NOW + session state
        ├── BACKLOG.md           <- What is coming next
        └── LOG.md               <- Append-only diary
```

**Same structure applies for other agents:**
- `.claude/agents/` for Claude Code
- `.cursor/agents/` for Cursor
- `.windsurf/agents/` for Windsurf

---

## Command: `/safe-code`

Run a full hygiene pass. Auto-detects if a previous saved session exists in `ACTIVE.md` and resumes from it.

## Command: `/safe-code save`

Checkpoint the current session. Updates all docs with a session summary, then commits everything:

```
1. Update ACTIVE.md with ## Last Session block
2. Update MEMORY.md, LOG.md, safe-refactor-code.md
3. Update root CHANGELOG.md if any releasable changes were made
4. Run: git add -A
5. Run: git commit -m "safe-code: <YYYY-MM-DD> - <one-line summary of what was done>"
6. Report: commit hash + what was saved
```

This does NOT end the session - work can continue after saving.

---

## How to Make Decisions (Read Before Every Step)

Before taking any action, reason through it explicitly. Do not guess. Do not skip this.

### Decision Framework

For every decision in this skill, ask:

1. **What are the 2-3 options here?**
2. **What does each option risk or preserve?**
3. **Which option is safest given what I know?**
4. **Can this be undone if I'm wrong?**

If the answer to (4) is "no" - stop and show the user the options before acting.
If the answer to (4) is "yes" - proceed with the safest option and log your reasoning.

### When to Act Autonomously

Act without asking when:
- The action is reversible (git tracked, or file can be restored)
- Confidence is High (zero references, no dynamic risk)
- The decision is technical, not about user intent
- The answer is discoverable from the codebase itself

### When to Stop and Ask

Stop and ask the user when:
- The action is irreversible (no git, no backup)
- Confidence is Low
- Something unexpected is found that changes the scope significantly (new subsystem affected, blast radius > 10 files)

**Do NOT ask the user about Medium confidence candidates** - apply the auto-promotion rule below instead.

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

---

## Step 0: Detect Active Agent

Inside the **project root**, check which agent folder exists:

```
if <project-root>/.codex/ exists    -> agents folder = <project-root>/.codex/agents/
if <project-root>/.claude/ exists   -> agents folder = <project-root>/.claude/agents/
if <project-root>/.cursor/ exists   -> agents folder = <project-root>/.cursor/agents/
if <project-root>/.windsurf/ exists -> agents folder = <project-root>/.windsurf/agents/
if none detected                    -> create <project-root>/.codex/agents/ and use it
```

Never fall back to the project root itself as the agents folder.
Never use any path outside the project root.

If multiple agent folders exist - reason through which one matches the current running agent. Do not ask the user.

---

## Step 1: Initialize Doc Structure

Create the agents folder and all required files **before reading the codebase**.

### 1a. Create the agents folder

```
<project-root>/<agent-folder>/agents/
```

Create if it does not exist.

### 1b. Check and create each file

For each file - **if it exists, leave it completely untouched.** If it does not exist, create it with the template below.

---

**`<project-root>/AGENTS.md`** - project root, auto-read by agent on load.

```md
# AGENTS.md

## Project Overview
<!-- One paragraph: what this project does, its purpose, and target users -->

## Tech Stack
- Runtime:
- Framework:
- Database:
- Other:

## Coding Standards
- Style: <!-- e.g. 2-space indent, single quotes, semicolons -->
- Naming: <!-- e.g. camelCase for vars, PascalCase for classes -->
- Comments: English only, inline for complex logic only

## Project Structure
<!-- Brief folder tree or key modules -->

## Key Rules for AI
- Always read ACTIVE.md before starting any task
- Always update ACTIVE.md and LOG.md after completing any significant change
- Do NOT modify CHANGELOG.md unless explicitly asked to release
- Never read or write files outside the project root
- When in doubt, ask - do not assume

## Environment
- Node version:
- Package manager: <!-- npm / yarn / pnpm / bun -->
- Dev command:
- Build command:
- Test command:
```

---

**`<project-root>/CHANGELOG.md`** - project root, public release history.

```md
# CHANGELOG.md

All notable changes to this project will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]
### Added
- Project initialized

---
<!-- Add new versions above this line -->
<!-- ## [X.Y.Z] - YYYY-MM-DD -->
<!-- ### Added / Changed / Deprecated / Removed / Fixed / Security -->
```

---

**`<project-root>/<agent-folder>/agents/ACTIVE.md`** - current session state.

```md
# ACTIVE.md

_Last updated: <!-- DATE -->_

## Current Task
<!-- One sentence: what is actively being built or fixed right now -->

## In Progress
- [ ] <!-- subtask -->

## Context / Notes
<!-- Important context the AI needs for this session -->

## Blockers
<!-- Anything blocking progress -->

## Next Steps
<!-- 2-3 bullet points of what comes after current task -->

---

## Last Session
status: none
saved_at: -
completed: []
pending: []
next_action: none
```

---

**`<project-root>/<agent-folder>/agents/BACKLOG.md`** - future tasks queue.

```md
# BACKLOG.md

_Last updated: <!-- DATE -->_

## Priority: High
- [ ] <!-- task -->

## Priority: Medium
- [ ] <!-- task -->

## Priority: Low / Nice to Have
- [ ] <!-- task -->

## Ideas / Exploration
- <!-- not yet committed, just capturing -->

---
> Move items to ACTIVE.md when starting them. Mark done items with [x] and date.
```

---

**`<project-root>/<agent-folder>/agents/LOG.md`** - append-only diary.

```md
# LOG.md

> Append-only. Never delete entries. Newest at top.

---

## <!-- DATE TIME -->
### Session: Project initialized
- Created doc scaffold (AGENTS.md, CHANGELOG.md, ACTIVE.md, BACKLOG.md, LOG.md, MEMORY.md, safe-refactor-code.md)

---
```

---

**`<project-root>/<agent-folder>/agents/MEMORY.md`** - architecture snapshot.

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

**`<project-root>/<agent-folder>/agents/safe-refactor-code.md`** - refactor rules.

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
<!-- Format: [date] path/to/file:functionName - reason for flagging -->

## Recurring Pitfalls
<!-- Things that broke before or are easy to get wrong -->
```

---

### 1c. Confirm initialization

```
Project root: <absolute path>
Agent: <agent>
Agents folder: <project-root>/<agent-folder>/agents/

Root files:
  AGENTS.md             - <created | already exists>
  CHANGELOG.md          - <created | already exists>

Agent files:
  ACTIVE.md             - <created | already exists>
  BACKLOG.md            - <created | already exists>
  LOG.md                - <created | already exists>
  MEMORY.md             - <created | already exists>
  safe-refactor-code.md - <created | already exists>

All paths confirmed inside project root. Proceeding.
```

---

## Step 2: Read Context + Auto-Detect Saved Session

### 2a. Read AGENTS.md

Read `<project-root>/AGENTS.md` to load project rules, tech stack, coding standards, and AI instructions. Apply these rules for the rest of the session.

### 2b. Read ACTIVE.md and detect saved session

Read `<project-root>/<agent-folder>/agents/ACTIVE.md` and check the `## Last Session` block:

```
if status = "saved":
  -> Print: "Resuming saved session from <saved_at>"
  -> Print: "Completed: <completed>"
  -> Print: "Pending: <pending>"
  -> Print: "Next action: <next_action>"
  -> Skip audit for already-completed slices
  -> Resume from <next_action> directly

if status = "none" or block missing:
  -> Print: "No saved session found. Starting fresh."
  -> Continue to Step 3
```

Do not ask the user whether to resume or start fresh - auto-detect and decide.

### Last Session block format (written by `/safe-code save`)

```md
## Last Session
status: saved
saved_at: <ISO timestamp>
completed:
  - <slice description>
pending:
  - <slice description>
next_action: <what to do when resuming>
```

When all pending slices are done, reset the block:

```md
## Last Session
status: completed
saved_at: <ISO timestamp>
completed: all
pending: []
next_action: none
```

---

## Step 3: Assess Repo State and Check Git

```
Check git status:
  if git repo exists AND has commits -> rollback available -> proceed to Execute mode after plan
  if git repo exists BUT no commits  -> no rollback -> plan only, warn user before executing
  if no git repo                     -> no rollback -> plan only, require explicit user approval

Check worktree:
  if dirty (uncommitted changes) -> note this, do not overwrite user changes
  if clean -> safe to proceed
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

- Reason through every High vs Medium classification explicitly
- Cross-reference with candidates already flagged in `safe-refactor-code.md`
- Do not delete or modify any file in this step

### Medium Confidence Auto-Promotion Rule

```
if ALL of these are true:
  1. Same subsystem as a confirmed High candidate
  2. Zero static references outside that subsystem
  3. Subsystem is confirmed dead (no live route or config points to it)
THEN:
  -> promote to High, include in auto-execute plan
  -> log: "Promoted to High: shares orphaned subsystem with <High candidate>"

if ANY condition is false:
  -> keep as Medium, flag in safe-refactor-code.md, skip silently
```

---

## Step 5: Plan and Decide Execution Mode

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

**Choose A** when: git clean, rollback available, all High confidence, no surprises.
**Choose B** when: git dirty, borderline candidates, or larger scope than expected.
**Choose C** when: no git, no rollback, or user asked for plan only.

If B or C, show the plan and wait/stop accordingly.

---

## Step 6: Execute Dead Code Removal

Run `$codebase-pruner` in `Execute` mode.

- Delete only approved candidates
- Verify after each slice
- Roll back only the failing slice if verification fails
- Save newly flagged candidates to `safe-refactor-code.md`

---

## Step 7: Refactor and Sync Docs

Run `$safe-refactor-code` on affected areas.

Update docs:

| File | What to update |
|---|---|
| `AGENTS.md` | Only if project rules or stack changed |
| `CHANGELOG.md` | Only if changes are releasable to users |
| `ACTIVE.md` | Current task, progress, next steps |
| `LOG.md` | Append today's session summary (newest at top) |
| `MEMORY.md` | Updated architecture snapshot |
| `safe-refactor-code.md` | Flagged candidates, new rules, pitfalls |
| `BACKLOG.md` | Move completed items, add newly discovered tasks |

---

## Step 8: Final Summary

```
=== safe-code session complete ===

Project root: <path>
Agent: <agent>
Agents folder: <project-root>/<agent-folder>/agents/
Execution mode used: <A | B | C>

Session type: <fresh start | resumed from <saved_at>>

Files initialized this session:
  Root:  AGENTS.md - <created | existed>  |  CHANGELOG.md - <created | existed>
  Agent: ACTIVE.md - <created | existed>  |  BACKLOG.md - <created | existed>
         LOG.md - <created | existed>     |  MEMORY.md - <created | existed>
         safe-refactor-code.md - <created | existed>

Decisions made:
  <list with brief reasoning>

Dead code removed:
  <list>

Dead code flagged (not removed):
  <list - saved to safe-refactor-code.md>

Refactors applied:
  <summary>

Follow-up items:
  <list>

To save and commit this session, run: /safe-code save
```
