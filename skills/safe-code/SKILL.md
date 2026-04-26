---
name: safe-code
description: "Full repo hygiene in one pass. Detects the active agent, auto-detects saved sessions from ACTIVE.md, initializes all 8 continuity docs inside the current project only, audits and removes dead code in safe slices, refactors in place, and keeps all docs in sync. Git push only occurs after the user explicitly runs /safe-code save — no autonomous push without user command. Universal git remote detection works with GitHub, GitLab, Bitbucket, Azure DevOps, Codeberg, self-hosted, Cloudflare Pages, Vercel, Netlify, and local-only repos. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go."
version: "2.1"
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
├── AGENTS.md              <- Rules for AI (set once, update rarely)
├── CHANGELOG.md           <- Release history (update on release only)
└── .codex/
    └── agents/
        ├── ACTIVE.md            <- Persistent state + resume point     [TIER 1]
        ├── SESSION.md           <- Working memory RAM (wipe on save)    [TIER 1]
        ├── LOG.md               <- Append-only diary (auto-trimmed)     [TIER 1]
        ├── BACKLOG.md           <- Task queue                           [TIER 2]
        ├── MEMORY.md            <- Architecture snapshot                [TIER 2]
        └── safe-refactor-code.md <- Refactor rules & flagged code       [TIER 2]
```

Same structure for other agents: `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`

---

## Loading Layers

### Layer 1 — Index (every session, always load first)

```
AGENTS.md      — project rules + stack
ACTIVE.md      — Before/Current/Next blocks only
SESSION.md     — Carry Forward block only
LOG.md         — last 3 typed entries only
```

### Layer 2 — Context (auto, if saved session detected)

```
LOG.md         — full content
SESSION.md     — full content
```

### Layer 3 — Detail (auto, by step trigger only)

```
MEMORY.md             — Step 4 (audit) or Step 7 (refactor + sync docs)
safe-refactor-code.md — Step 6 (execute dead code removal)
BACKLOG.md            — Step 7 (sync docs)
CHANGELOG.md          — Step 7 (sync docs, if releasable changes exist)
```

Do NOT load Layer 2 or Layer 3 files unless their trigger condition is met. This preserves context window for actual codebase analysis. No user action required — agent loads automatically.

---

## ACTIVE.md vs SESSION.md

| | ACTIVE.md | SESSION.md |
|---|---|---|
| **Persists** | Yes, across sessions | No — wiped on `/safe-code save` |
| **Contains** | Overall progress, next_action, resume point | Mid-step notes, temp decisions, working vars |
| **Updated** | On `/safe-code save` only | Freely throughout session |
| **Analogy** | Hard disk | RAM |

---

## Command: `/safe-code`

Run a full hygiene pass. Auto-detects saved session in `ACTIVE.md` and resumes if found.

## Command: `/safe-code save`

Checkpoint the current session:

```
1. Migrate SESSION.md — extract important decisions into ACTIVE.md
2. Update ACTIVE.md — Last Session block + current state
3. Append to LOG.md — typed session summary (newest at top)
4. Update MEMORY.md — if architecture changed
5. Update CHANGELOG.md (root) — only if releasable changes were made
6. Auto-trim LOG.md if needed (see LOG.md Trim Rule below)
7. Reset SESSION.md — empty template (wipe working memory)
8. git add -A
9. git commit -m "safe-code: <YYYY-MM-DD> - <one-line summary>"
10. Push based on remote bucket (see Step 3b)
11. Report commit hash + push status
```

Does NOT end the session — work can continue after saving.

---

## How to Make Decisions

Before every action, reason explicitly. Do not guess. Do not skip this.

### Decision Framework

1. What are the 2-3 options?
2. What does each risk or preserve?
3. Which is safest given what I know?
4. Can this be undone?

If (4) = no → stop, show options to user before acting.
If (4) = yes → proceed with safest option, log reasoning.

### Act Autonomously When
- Action is reversible (git tracked)
- Confidence is High (zero references, no dynamic risk)
- Decision is technical, not about user intent
- Answer is discoverable from the codebase

### Stop and Ask When
- Action is irreversible (no git, no backup)
- Confidence is Low
- Unexpected scope change (blast radius > 10 files)

**Never ask about Medium confidence candidates** — apply auto-promotion rule instead.

### Reasoning Format

```
Reasoning:
  Options: <list>
  Risk: <list>
  Decision: <chosen>
  Why: <one sentence>
  Reversible: yes/no
```

---

## Step 0: Detect Active Agent

```
if <project-root>/.codex/ exists    -> agents folder = <project-root>/.codex/agents/
if <project-root>/.claude/ exists   -> agents folder = <project-root>/.claude/agents/
if <project-root>/.cursor/ exists   -> agents folder = <project-root>/.cursor/agents/
if <project-root>/.windsurf/ exists -> agents folder = <project-root>/.windsurf/agents/
if none detected                    -> create <project-root>/.codex/agents/ and use it
```

Multiple folders found → reason which matches current agent. Do not ask user.

---

## Step 1: Initialize Doc Structure

Create agents folder + all files **before** reading the codebase.
**If a file exists — leave it untouched. Create only if missing.**

---

### `<project-root>/AGENTS.md`

```md
# AGENTS.md

## Project Overview
<!-- What this project does, purpose, target users -->

## Tech Stack
- Runtime:
- Framework:
- Database:
- Other:

## Coding Standards
- Style:
- Naming:
- Comments: English only, inline for complex logic only

## Project Structure
<!-- Brief folder tree or key modules -->

## Key Rules for AI
- Read ACTIVE.md before starting any task
- Update ACTIVE.md and append to LOG.md after any significant change
- Do NOT modify CHANGELOG.md unless explicitly asked to release
- Never read or write files outside the project root
- When in doubt, ask — do not assume

## Environment
- Node version:
- Package manager:
- Dev command:
- Build command:
- Test command:
```

---

### `<project-root>/CHANGELOG.md`

```md
# CHANGELOG.md

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [Unreleased]
### Added
- Project initialized

---
<!-- ## [X.Y.Z] - YYYY-MM-DD -->
<!-- ### Added / Changed / Deprecated / Removed / Fixed / Security -->
```

---

### `<agents-folder>/ACTIVE.md` — persistent state only

```md
# ACTIVE.md
_<DATE>_

## Before
last_saved: -
completed_last: none

## Current
task: init
step: step 1 — initialize doc structure
mode: -

## Blocked
none

## Next
- <what comes after current task>

---

## Last Session
status: none
saved_at: -
completed: []
pending: []
next_action: none
```

---

### `<agents-folder>/SESSION.md` — working memory RAM (wipe on save)

```md
# SESSION.md
_<DATE> <TIME>_
> Temporary working memory. Auto-wiped on /safe-code save.
> Do NOT rely on this for persistent state — use ACTIVE.md.

## Working Now
<!-- What is being actively processed this moment -->

## Temp Decisions
<!-- Decisions made mid-session, not yet committed to ACTIVE.md -->

## Mid-Step Notes
<!-- Notes for current step only — discard after step completes -->

## Carry Forward
<!-- Important findings to migrate into ACTIVE.md on save -->
```

---

### `<agents-folder>/BACKLOG.md`

```md
# BACKLOG.md
_<DATE>_

## High
- [ ] <task>

## Medium
- [ ] <task>

## Low / Nice to Have
- [ ] <task>

## Ideas
- <not committed yet>

---
> Move to ACTIVE.md when starting. Mark done with [x] + date.
```

---

### `<agents-folder>/LOG.md`

```md
# LOG.md
> Append-only. Newest at top. Auto-trimmed when > 200 lines.
> Each entry uses typed format: type, scope, topic, before, change, why, after.

Valid types: init | decision | refactor | bugfix | risk | blocked | verify

---

## <DATE TIME>
type: init
scope: project root
topic: scaffold
before: no doc structure existed
change: created AGENTS.md, CHANGELOG.md, ACTIVE.md, SESSION.md, BACKLOG.md, LOG.md, MEMORY.md, safe-refactor-code.md
why: first run of /safe-code — initializing continuity docs
after: all 8 docs created, proceeding to Step 2

---
```

---

### `<agents-folder>/MEMORY.md`

```md
# MEMORY.md
_<DATE>_

## Architecture
<!-- Current structure of the codebase -->

## Source of Truth Files
<!-- Files that define core behavior -->

## Active Workarounds
<!-- Temporary fixes still in place -->

## Follow-up
<!-- Things that still need to be done -->
```

---

### `<agents-folder>/safe-refactor-code.md`

```md
# safe-refactor-code.md

## Safe to Touch
<!-- Modules or files safe to refactor freely -->

## Dangerous / Generated
<!-- Files that should not be edited directly -->

## Verification Commands
<!-- e.g. npm run lint, npm test -->

## Conventions
<!-- Naming, import order, file structure rules -->

## Flagged Dead Code
<!-- Structured entries below. Requires explicit user approval before deletion in Execute mode. -->

## Pitfalls
<!-- Things that broke before or are easy to get wrong -->
```

**Flagged Dead Code entry format:**

```md
### [<DATE>] <path/to/file>:<functionOrModule>
scope: file | module | subsystem
topic: <e.g. routing, auth, billing>
confidence: High | Medium | Low
reason: <why it is suspected dead>
risk: Zero | Local | Cross-module | External
action: auto-delete | manual review | skip
```

---

### 1c. Confirm Initialization

```
Project root: <path>
Agent: <agent>
Agents folder: <project-root>/<agent-folder>/agents/

Root:  AGENTS.md - <created|exists>  |  CHANGELOG.md - <created|exists>
Agent: ACTIVE.md - <created|exists>  |  SESSION.md - <created|exists>
       BACKLOG.md - <created|exists>  |  LOG.md - <created|exists>
       MEMORY.md - <created|exists>   |  safe-refactor-code.md - <created|exists>

All paths inside project root. Proceeding.
```

---

## Step 2: Load Context + Auto-Detect Session

### 2a. Load Layer 1 (always, every session)

```
1. AGENTS.md      — apply project rules, stack, standards
2. ACTIVE.md      — read Before/Current/Next blocks only
3. SESSION.md     — read Carry Forward block only
4. LOG.md         — read last 3 typed entries only
```

### 2b. Detect saved session from ACTIVE.md

```
if Last Session.status = "saved":
  -> Load Layer 2: LOG.md full + SESSION.md full
  -> Print: "Resuming saved session from <saved_at>"
  -> Print: "Pending: <pending> | Next: <next_action>"
  -> Skip audit for completed slices
  -> Resume from next_action directly

if Last Session.status = "none" or block missing:
  -> Stay on Layer 1 only
  -> Print: "No saved session. Starting fresh."
  -> Continue to Step 3
```

Auto-detect only. Do not ask user.

### Last Session block (written by `/safe-code save`)

```md
## Last Session
status: saved
saved_at: <ISO timestamp>
completed:
  - <slice>
pending:
  - <slice>
next_action: <what to do on resume>
```

After all pending done, reset to:

```md
## Last Session
status: completed
saved_at: <ISO timestamp>
completed: all
pending: []
next_action: none
```

---

## LOG.md Trim Rule

Check LOG.md line count on every `/safe-code save`.

```
if LOG.md > 200 lines:
  -> Collect all entries older than 7 days
  -> Summarize them into one block at the bottom:

  ## Archived Summary [<oldest date> - <7 days ago>]
  - <bullet summary of what happened in that period>

  -> Keep last 7 days of entries as-is above the archive block
  -> Never delete any information — only compress old entries
  -> Append new entries above everything as usual
```

This keeps LOG.md scannable without losing history.

---

## Step 3: Git + Remote Check

### 3a. Check git repo state

```
if git repo exists AND has commits -> rollback available -> auto-execute after plan
if git repo exists BUT no commits  -> warn user, plan only before executing
if no git repo                     -> require explicit user approval before executing

if worktree dirty -> note it, do not overwrite user changes
if worktree clean -> safe to proceed
```

### 3b. Detect remote platform

Run `git remote -v` and classify into one of three buckets:

```
BUCKET A — Git-native platforms
  Matches: github.com, gitlab.com, bitbucket.org,
           dev.azure.com, codeberg.org,
           self-hosted GitLab/Gitea (custom domain),
           SSH custom URLs, HTTPS custom URLs
  Action:  git commit + git push

BUCKET B — Git + external deploy platforms
  Matches: vercel.com, netlify.com, pages.cloudflare.com,
           any platform that auto-deploys on push
  Action:  git commit + git push
  Note:    "Auto-deploy may trigger on push — confirm intent if needed"

BUCKET C — Local only
  Matches: no remote configured
  Action:  git commit only — no push attempt
  Note:    "No remote detected. Push manually when ready."
```

Do NOT ask user which platform they use — detect from URL only.

### 3c. Reasoning output

```
Reasoning:
  Git state: <found | not found | found but no commits>
  Remote: <URL | none>
  Bucket: <A | B | C>
  Rollback available: yes/no
  Decision: <proceed | require approval>
  Why: <one sentence>
```

---

## Step 4: Audit Dead Code

> **Layer 3 Trigger:** Load `MEMORY.md` now if not already loaded.

Invoke `$codebase-pruner` in `Audit` mode.

- Classify every candidate explicitly (High vs Medium)
- Cross-reference `safe-refactor-code.md` for previously flagged items
- Do not delete or modify anything in this step

### Medium Auto-Promotion Rule

```
if ALL true:
  1. Same subsystem as confirmed High candidate
  2. Zero static references outside that subsystem
  3. Subsystem confirmed dead (no live route or config)
-> promote to High, log reason

if ANY false:
-> keep Medium, flag in safe-refactor-code.md using structured format, skip silently
```

---

## Step 5: Plan + Execution Mode

```
Reasoning:
  High candidates: <count>
  Rollback: yes/no
  Risk: low/medium/high
  Decision: A / B / C
  Why: <one sentence>
```

- **A** — git clean + rollback + all High + no surprises → auto-execute
- **B** — git dirty / borderline / large scope → show plan, wait for approval
- **C** — no git / no rollback / plan-only asked → show plan only

---

## Step 6: Execute Dead Code Removal

> **Layer 3 Trigger:** Load `safe-refactor-code.md` now if not already loaded.

Run `$codebase-pruner` in `Execute` mode. Requires explicit user approval before deleting any candidate that is not High confidence.

- Delete approved candidates only
- Verify after each slice
- Roll back only the failing slice if verification fails
- Save new flagged candidates to `safe-refactor-code.md` using structured format

---

## Step 7: Refactor + Sync Docs

> **Layer 3 Trigger:** Load `MEMORY.md`, `BACKLOG.md`, and `CHANGELOG.md` now if not already loaded.

Run `$safe-refactor-code` on affected areas.

| File | When to update |
|---|---|
| `AGENTS.md` | Only if project rules or stack changed |
| `CHANGELOG.md` | Only if changes are releasable |
| `ACTIVE.md` | Every session — Before/Current/Next + Last Session |
| `SESSION.md` | Throughout session — wiped on save |
| `LOG.md` | Every session — append typed entry, newest at top |
| `MEMORY.md` | When architecture changes |
| `safe-refactor-code.md` | Flagged candidates (structured format), pitfalls, new rules |
| `BACKLOG.md` | Move completed items, add newly discovered tasks |

---

## Step 8: Final Summary

```
=== safe-code v2.1 session complete ===

Project root: <path>
Agent: <agent>
Agents folder: <agents-folder>
Execution mode: <A | B | C>
Session type: <fresh | resumed from <saved_at>>

Git:    <repo found | not found> | <commit count> commits | branch: <branch>
Remote: <URL | none>  [Bucket <A | B | C>]
Push:   <auto on /safe-code save | manual | not applicable>

Files:
  Root:  AGENTS.md <created|existed>    CHANGELOG.md <created|existed>
  Agent: ACTIVE.md <created|existed>    SESSION.md <created|existed>
         BACKLOG.md <created|existed>   LOG.md <created|existed>
         MEMORY.md <created|existed>    safe-refactor-code.md <created|existed>

Loaded (Layer 1): AGENTS.md, ACTIVE.md (index), SESSION.md (carry forward), LOG.md (last 3)
Loaded (Layer 2): <full context files if resumed session, else: none>
Loaded (Layer 3): <on-demand files loaded this session>

Decisions: <list>
Removed:   <list>
Flagged:   <list>
Refactors: <summary>
Follow-up: <list>

Run /safe-code save to commit this session.
```
