# safe-code reference: doc + session templates

> Loaded on demand by `/safe-code` during Step 1 (Initialize Doc Structure).
> Fallback shapes for CHANGELOG.md, context/*.md, and .agents/*.md. Do not overwrite existing files.

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

### `context/project-overview.md`

```md
# Project Overview

## Overview
<!-- What this project does, who it serves, and the problem it solves. -->

## Goals
1. <!-- Specific measurable goal. -->

## Core User Flow
1. <!-- Main path to value. -->

## Features
- <!-- Feature/category. -->

## Scope
### In Scope
- <!-- Included work. -->

### Out of Scope
- <!-- Explicitly excluded work. -->

## Success Criteria
1. <!-- Verifiable condition. -->
```

---

### `context/architecture.md`

```md
# Architecture

## Stack
| Layer | Technology | Role |
|---|---|---|
| Runtime | | |
| Framework | | |
| UI | | |
| Database | | |

## System Boundaries
- `folder/` — <!-- Ownership and responsibility. -->

## Storage Model
- **Database**: <!-- Metadata, ownership, relationships. -->
- **File/Blob Storage**: <!-- Media, generated files, large artifacts. -->

## Auth and Access Model
- <!-- Authentication, ownership, authorization. -->

## Invariants
1. <!-- Rule the codebase must never violate. -->
```

---

### `context/user-preferences.md`

```md
# User Preferences

Record only explicit user preferences or decisions confirmed by repeated conversation.
Do not infer preferences from one ambiguous message.
Do not store secrets, private logs, or temporary emotions.

Agents should watch for strong preference phrases in chat, including:

- `I don't want`, `I want`, `I don't like`, `I prefer`
- `aku taknak`, `tak nak`, `aku nak`, `aku tak suka`, `aku prefer`
- `please remove`, `remove this`, `make it like this`
- `jangan`, `must`, `always`, `never`

When detected, draft the preference in `SESSION.md` and apply it here on `/safe-code --save`.

## Hard Preferences
- <!-- Example: Use SVG icons only; do not use emoji icons. -->

## Hard Dislikes / Avoid
- <!-- Example: Avoid overcomplicated folder structures. -->

## Style Preferences
- <!-- Tone, UI style, naming, formatting preferences. -->

## Workflow Preferences
- <!-- How user wants agent to plan, save, ask, or execute. -->

## Confirmed Decisions
- <!-- Date — decision — reason. -->
```

---

### `context/code-standards.md`

```md
# Code Standards

## General
- <!-- Principle. -->

## Language / Framework
- <!-- Convention. -->

## Styling
- <!-- Rule. -->

## API / Data Access
- <!-- Rule. -->

## File Organization
- `folder/` — <!-- What belongs here. -->
```

---

### `context/ai-workflow-rules.md`

```md
# AI Workflow Rules

## Approach
- Work spec-first and incrementally.
- Context files define what to build.
- Keep implementation inside the active spec scope.

## Scoping Rules
- Work on one feature unit at a time.
- Prefer small verifiable increments.
- Do not combine unrelated boundaries in one step.

## Handling Missing Requirements
- Do not invent undefined behavior.
- Draft ambiguity for `context/progress-tracker.md` Open Questions before implementing.

## Protected Files
- <!-- Files/folders requiring explicit instruction. -->

## Before Moving On
1. Active unit works within scope.
2. No `context/architecture.md` invariant is violated.
3. Verification passes or blocked reason is recorded.
4. Draft progress update is ready for `/safe-code --save`.
```

---

### `context/ui-context.md`

```md
# UI Context

## Theme
<!-- Visual language, dark/light mode, density. -->

## Colors
| Role | CSS Variable | Value |
|---|---|---|
| Page background | `--bg-base` | |
| Surface | `--bg-surface` | |
| Primary text | `--text-primary` | |
| Accent | `--accent-primary` | |
| Border | `--border-default` | |

## Typography
| Role | Font | Variable |
|---|---|---|
| UI text | | `--font-sans` |
| Code | | `--font-mono` |

## Component Library
<!-- e.g. shadcn/ui, Mantine, native components. -->

## Layout Patterns
- <!-- Common layouts. -->
```

---

### `context/progress-tracker.md`

```md
# Progress Tracker

Update with safe summaries on `/safe-code --save`.

## Current Phase
- Not started

## Current Goal
- <!-- What is being built now. -->

## Completed
- None yet.

## In Progress
- None yet.

## Next Up
- <!-- First unit to build. -->

## Open Questions
- <!-- Unknown product/technical facts. -->

## Architecture Decisions
- <!-- Safe summaries only; include why. -->

## Session Notes
- <!-- Safe resume notes. No secrets, raw logs, or private URLs. -->
```

---

### `context/current-issues.md` — local-only manual scratchpad

Add `/context/current-issues.md` to `.gitignore`.

```md
# Current Issues

This file is a local-only manual scratchpad for the user.
Do not commit this file.
Do not paste secrets unless you understand the risk.
AI agents should read this file only when the user explicitly asks for issue/debug analysis.

## How To Ask The Agent

Copy/paste this prompt when ready:

> Explore the current-issues.md file and deeply analyze the problem. Only when you have the analysis, give it back to me with the idea of how you're planning to solve it, and then wait for me to give you the green light to execute it.

## Issue
<!-- Manually describe the problem here. -->

## Error / Logs
<!-- Manually paste error messages, stack traces, or relevant logs here. -->

## Steps To Reproduce
1. <!-- Step one -->
2. <!-- Step two -->
3. <!-- Step three -->

## Expected Result
<!-- What should happen instead. -->

## Actual Result
<!-- What happens now. -->

## Notes
<!-- URLs, screenshot notes, environment details, recent changes. -->
```

---

### `context/feature-specs/00-template.md`

```md
# Unit NN: Feature Name

## Goal
<!-- 1-2 sentences. Concrete output when complete. -->

## Scope
### In Scope
- <!-- What will be built. -->

### Out of Scope
- <!-- What must not be touched. -->

## Design / Behavior
<!-- UI, API, data, and behavior decisions. Reference context files. -->

## Implementation Notes
- <!-- Files/areas likely touched. -->

## Dependencies
- <!-- package-name (reason), or None. -->

## Verify When Done
- [ ] <!-- Specific acceptance condition. -->
- [ ] Build/typecheck/test command passes if available.
- [ ] No unrelated changes.
```

---

### `.agents/ACTIVE.md` — persistent state only

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

### `.agents/SESSION.md` — working memory RAM (wipe on save)

```md
# SESSION.md
_<DATE> <TIME>_
> Temporary working memory. Auto-wiped on /safe-code --save.
> Do NOT rely on this for persistent state — use ACTIVE.md.

## Working Now
<!-- What is being actively processed this moment -->

## Task List
- [ ] Locate project root and `.agents/` folder
- [ ] Initialize or reconcile AGENTS.md, context, and session docs
- [ ] Detect saved state or old-method migration need
- [ ] Load required context for this command
- [ ] Draft or update active feature spec if needed
- [ ] Check git state and rollback safety
- [ ] Check or bootstrap graph support when useful
- [ ] Explore repo facts before context backfill
- [ ] Audit dead code and stale files only when in scope
- [ ] Decide run profile and execution mode
- [ ] Execute scoped code changes if requested
- [ ] Review changes and test coverage
- [ ] Debug verification failures, if any
- [ ] Draft docs/context updates in SESSION.md
- [ ] Save final docs/context updates on /safe-code --save

## Temp Decisions
<!-- Decisions made mid-session, not yet committed to ACTIVE.md -->

## Mid-Step Notes
<!-- Notes for current step only — discard after step completes -->

## Carry Forward
<!-- Important findings to migrate into ACTIVE.md or context docs on save -->
```

---

### `.agents/BACKLOG.md`

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

### `.agents/LOG.md`

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
change: created AGENTS.md, context files, CHANGELOG.md, and safe-code session docs
why: first run of /safe-code — initializing context and session docs
after: scaffold created, proceeding to Step 2

---
```

---

### `.agents/MEMORY.md`

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

### `.agents/safe-refactor-code.md`

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

## Surgical Change Rules
- Touch only lines that directly fix the task — nothing else
- Match existing style: quotes, spacing, naming, indent — even if you'd do it differently
- Do NOT add type hints, docstrings, or comments unless explicitly asked
- Do NOT reformat adjacent code while fixing something
- Do NOT refactor things that aren't broken
- Unrelated issues found → draft BACKLOG.md entry in SESSION.md, do not fix silently
- Every changed line must trace back to the user's request

Test: Can every diff line be justified by the task? If not, revert it.

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

