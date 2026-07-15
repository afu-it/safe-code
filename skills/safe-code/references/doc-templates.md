# safe-code reference: doc + session templates

> Loaded on demand by `/safe-code` during Step 1 (Initialize Doc Structure).
> Fallback shapes for .safe-code/CHANGELOG.md, .safe-code/context/*.md, and .safe-code/*.md. Do not overwrite existing files.

### `<project-root>/.safe-code/CHANGELOG.md`

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

### `.safe-code/context/project-overview.md`

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

### `.safe-code/context/architecture.md`

```md
# Architecture

## Stack
| Layer | Technology | Role |
|---|---|---|
| Runtime | | |
| Framework | | |
| UI | | |
| Database | | |

## Navigation (Where Things Live)
<!-- The map a fresh agent uses to jump straight to the right file instead of
     re-scanning the whole repo. Fill from real paths; keep it current. -->
- **Entry points**: <!-- main / app / server / CLI entry files. -->
- **Routes / endpoints**: <!-- where they are defined. -->
- **Data / models / schema**: <!-- where defined. -->
- **Config / env**: <!-- where config and env live. -->
- **Tests**: <!-- where tests live + how to run them. -->
- **To add a feature/route/model, edit**: <!-- folder/file. -->

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

### `.safe-code/context/user-preferences.md`

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

### `.safe-code/context/code-standards.md`

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

### `.safe-code/context/ai-workflow-rules.md`

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
- Draft ambiguity for `.safe-code/context/progress-tracker.md` Open Questions before implementing.

## Protected Files
- <!-- Files/folders requiring explicit instruction. -->

## Before Moving On
1. Active unit works within scope.
2. No `.safe-code/context/architecture.md` invariant is violated.
3. Verification passes or blocked reason is recorded.
4. Draft progress update is ready for `/safe-code --save`.
```

---

### `.safe-code/context/ui-context.md`

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

### `.safe-code/context/progress-tracker.md`

```md
# Progress Tracker

Update with safe summaries on `/safe-code --save`.

<!-- Context freshness + coverage stamps — updated on /safe-code --save. -->
last_synced_commit: none
context_synced_at: -
context_selftest: -

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

### `.safe-code/context/current-issues.md` — local-only issue tracker (user + AI)

Add `/.safe-code/context/current-issues.md` to `.gitignore`. Stays local-only; never committed. The user pastes raw context; the agent appends/updates entries on issue triggers (Issue Tracking Rule) and flips them to Resolved once fixed.

```md
# Current Issues  (local-only, gitignored)

User + AI shared issue tracker. Not committed.
The user pastes raw context here; the agent appends an entry on error triggers
("fix this", "failed", "got error", pasted stack trace) and flips it to
Resolved once fixed. May contain secrets/logs — never copied into committed docs.

## How To Ask The Agent

> Explore current-issues.md, deeply analyze the problem, give me the analysis
> plus your fix plan, then wait for my green light before executing.

---

## Open

<!-- Newest first. One block per issue. Status: open. -->

### [<DATE>] <short title> — status: open
- symptom: <what the user sees>
- error: <key error line(s) — trim long dumps>
- repro: <steps, or "unknown">
- notes: <env, recent changes, URLs>

---

## Resolved

<!-- Moved here once fixed. A sanitized one-liner also goes to LOG.md. -->

### [<DATE>] <short title> — status: fixed (<DATE>)
- symptom: <what was wrong>
- root cause: <one line>
- fix: <what changed — file/approach, no secrets>
```

---

### `.safe-code/context/feature-specs/00-template.md`

```md
# Unit NN: Feature Name

status: suggested   <!-- suggested | approved | in-progress | done | rejected -->
created: <DATE>
updated: <DATE>

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

### `.safe-code/ACTIVE.md` — persistent state only

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

### `.safe-code/SESSION.md` — working memory RAM (wipe on save)

```md
# SESSION.md
_<DATE> <TIME>_
> Temporary working memory. Auto-wiped on /safe-code --save.
> Do NOT rely on this for persistent state — use ACTIVE.md.

## Working Now
<!-- What is being actively processed this moment -->

## Task List
<!-- Copy the canonical Default checklist from safe-code SKILL.md (Measure Twice,
     Cut Once Policy) and adapt per mode — do not maintain a divergent copy here.
     States: [ ] todo · [~] active · [x] done after verification. -->
- [ ] <task>  · type: <commit type> · files: <paths>

## Temp Decisions
<!-- Decisions made mid-session, not yet committed to ACTIVE.md -->

## Mid-Step Notes
<!-- Notes for current step only — discard after step completes -->

## Carry Forward
<!-- Important findings to migrate into ACTIVE.md or context docs on save -->
```

---

### `.safe-code/BACKLOG.md`

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

### `.safe-code/LOG.md`

```md
# LOG.md
> Append-only. Newest at top. Auto-trimmed when > 200 lines.
> Each entry uses typed format: type, scope, topic, before, change, why, after, plain.
> `plain:` is one sentence in plain language a non-coder can read.

Valid types: init | decision | refactor | bugfix | risk | blocked | verify

---

## <DATE TIME>
type: init
scope: project root
topic: scaffold
before: no doc structure existed
change: created AGENTS.md, context files, .safe-code/CHANGELOG.md, and safe-code session docs
why: first run of /safe-code — initializing context and session docs
after: scaffold created, proceeding to Step 2
plain: set up the project's memory so any AI can pick up where we left off.

---
```

---

### `.safe-code/MEMORY.md`

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

### `.safe-code/safe-refactor-code.md`

```md
# safe-refactor-code.md
_<DATE>_

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

---

## Provider Bridge Files (pointers — never duplicate facts)

> Thin redirects so hosts that do not auto-read `AGENTS.md` still load the same brain.
> Write only the bridge for the host currently running (see SKILL.md Provider Bridge); the
> templates below are the shapes for each host, used when that host's bridge is the one written.
> Never overwrite a user's existing file; if it exists without a `<!-- safe-code:bridge -->`
> block, append the block instead of replacing the file.

### `<project-root>/CLAUDE.md`

```md
# CLAUDE.md

<!-- safe-code:bridge -->
> Project context is maintained by safe-code. Read these before any task.

@AGENTS.md

After AGENTS.md, read the files it lists under `.safe-code/context/` (project overview,
architecture incl. the Navigation map, code standards, workflow rules, progress). Treat them
as the source of truth; do not re-scan the whole codebase for facts already documented there.
<!-- /safe-code:bridge -->
```

### `<project-root>/GEMINI.md`

```md
# GEMINI.md

<!-- safe-code:bridge -->
Project context is maintained by safe-code. Before doing any work, read `AGENTS.md` at the
repo root, then the files it lists under `.safe-code/context/` (project overview, architecture
incl. the Navigation map, code standards, workflow rules, progress). They are the source of
truth for what this project is and how to work in it. Do not re-derive project facts by
scanning the whole codebase when they are already documented there.
<!-- /safe-code:bridge -->
```

### `<project-root>/.github/copilot-instructions.md`

```md
<!-- safe-code:bridge -->
# Project Instructions

Project context is maintained by safe-code. Before generating code or answering, read
`AGENTS.md` at the repo root and the files it references under `.safe-code/context/` (project
overview, architecture incl. the Navigation map, code standards, workflow rules, progress).
Treat those as the source of truth; follow them instead of re-scanning the entire codebase.
<!-- /safe-code:bridge -->
```

### `<project-root>/.cursor/rules/safe-code.mdc`

```md
---
description: safe-code project context entry point
alwaysApply: true
---

Project context is maintained by safe-code. Before any task, read `AGENTS.md` at the repo
root and the files it references under `.safe-code/context/` (project overview, architecture
incl. the Navigation map, code standards, workflow rules, progress). Treat those as the source
of truth; do not re-scan the whole codebase for facts already documented there.
```

