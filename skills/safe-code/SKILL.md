---
name: safe-code
description: "Full repo hygiene in one pass. Uses /safe-code for first-time setup, /safe-code --continue for context-safe resume, and /safe-code --save for handoff + local commit. Detects the active agent, initializes AGENTS.md, context files, and session docs inside the current project only, audits dead code in safe slices, refactors only when scoped, and drafts docs until /safe-code --save. /safe-code --save creates or uses a local git repo and commits locally only — it never pushes to a remote. Universal git remote detection is informational only. Use when asked to do a full cleanup, full hygiene pass, /safe-code, or maintain a repo in one go."
version: "2.9"
---

# Safe Code

Run a complete repo hygiene pass autonomously. Think before acting. Make decisions independently. Only ask the user when a decision cannot be reversed or when intent is genuinely unclear.

Apply `$senior-dev` discipline throughout the run: task list first, measure twice cut once, adversarial strategy critique, clean repo policy, small reversible slices, and verification before completion.

## Scope Rule (Read This First)

**Everything operates inside the current project root only.**

- Never read from or write to paths outside the current project root
- Never use `~/`, `~/.codex/`, `~/.claude/`, or any home directory path
- All paths are relative to the project root
- The project root is the directory where the agent was invoked
- Graph MCP bootstrap may create or update `<project-root>/.mcp.json` only. Do not auto-edit global agent MCP config.

```
CORRECT: <project-root>/.codex/agents/ACTIVE.md
WRONG:   ~/.codex/agents/ACTIVE.md
```

---

## Doc Structure

```
<project-root>/
├── AGENTS.md                      <- root entry point; tells agents what to read first
├── CHANGELOG.md                   <- release history (update on release only)
├── context/                       <- project brain; canonical long-term context
│   ├── project-overview.md        <- what, who, goals, scope, success criteria
│   ├── architecture.md            <- stack, boundaries, storage, invariants
│   ├── code-standards.md          <- implementation conventions
│   ├── ai-workflow-rules.md       <- agent workflow and scoping rules
│   ├── ui-context.md              <- UI/design conventions (read only for UI work)
│   ├── progress-tracker.md        <- phase, current goal, decisions, safe session notes
│   ├── current-issues.md          <- local-only manual user scratchpad; gitignored
│   └── feature-specs/             <- AI-written feature specs, one build unit per file
│       └── 00-template.md
└── .codex/
    └── agents/                    <- safe-code runtime/session memory
        ├── ACTIVE.md              <- saved resume point; written on /safe-code --save
        ├── SESSION.md             <- working memory + draft doc/context updates
        ├── LOG.md                 <- append-only safe diary; no raw secrets/log dumps
        ├── BACKLOG.md             <- operational task queue
        ├── MEMORY.md              <- temporary audit/refactor architecture notes
        └── safe-refactor-code.md  <- refactor rules and flagged candidates
```

Same runtime/session structure for other agents: `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`.

`context/` is canonical project context. `.codex/agents/` is operational session state.

---

## Loading Layers

### Layer 1 — Entry (every session)

```
AGENTS.md                         — root instructions and Read First order
context/project-overview.md       — product/project definition
context/architecture.md           — system boundaries and invariants
context/code-standards.md         — coding conventions
context/ai-workflow-rules.md      — workflow rules
context/ui-context.md             — only for UI/design work
context/progress-tracker.md       — Current Phase, Current Goal, Next Up, Open Questions only
ACTIVE.md                         — Before/Current/Next blocks only, if present
SESSION.md                        — Carry Forward + draft updates only, if present
LOG.md                            — last 3 typed entries only, if present
```

Do not read `context/current-issues.md` during normal work. Read it only when the user explicitly asks to debug/fix an issue or references that file.

### Layer 2 — Resume (`/safe-code --continue` or auto-continue)

```
context/progress-tracker.md       — full content
ACTIVE.md                         — full content
SESSION.md                        — full content
LOG.md                            — full content if Last Session.status = saved
```

`/safe-code` must auto-use Layer 2 when saved unfinished state exists, even if the user forgot `--continue`.

### Layer 3 — Detail (triggered only)

```
context/feature-specs/<active>.md — feature/refactor work contract
context/architecture.md           — audit/refactor/debug impact checks
MEMORY.md                         — old/migrated architecture notes or audit detail
safe-refactor-code.md             — cleanup/refactor candidates and guardrails
BACKLOG.md                        — operational queue sync
CHANGELOG.md                      — releasable changes only
```

Do not load detail files unless the trigger condition is met.

---

## Project Context vs Session State

| | `context/` | `.codex/agents/` |
|---|---|---|
| Purpose | Long-term project brain | Runtime/session memory |
| Updated | Draft during work, finalize on `/safe-code --save` | `SESSION.md` during work; others on save |
| Canonical for | Product, architecture, standards, workflow, progress | Resume point, logs, cleanup/refactor notes |
| Secrets/raw logs | Never | Avoid; keep summaries only |

`context/current-issues.md` is special: safe-code creates a blank template and gitignores it, but the user writes it manually. It may contain raw errors, URLs, or secrets. Never copy it into persistent docs.

---

## Command: `/safe-code`

Run setup, auto-resume, or a fresh hygiene pass.

Behavior:

1. Detect project root and active agent.
2. If saved unfinished safe-code state exists, automatically behave like `/safe-code --continue` and print: `Saved safe-code session found; resuming automatically. Say "fresh pass" to ignore saved state.`
3. If no saved state exists, initialize/reconcile doc structure.
4. If old safe-code continuity docs exist but `context/` is missing, run old-method migration.
5. Explore repo facts and select the safest profile: Orientation, Audit, or Cleanup.

Start a truly fresh pass only when no saved state exists or user explicitly says `fresh pass`, `fresh setup`, or `ignore saved state`.

## Command: `/safe-code --continue`

Resume an existing safe-code session with full context loading. Use this in a new chat, new day, or after `/safe-code --save`. `/safe-code` auto-enters this mode when saved state exists.

Before doing work, read:

```
1. AGENTS.md
2. context/progress-tracker.md
3. ACTIVE.md
4. SESSION.md
5. LOG.md
6. active context/feature-specs/<file>.md if resuming a feature
7. MEMORY.md / safe-refactor-code.md only if audit/refactor/debug resumes
```

Do not guess previous context. If saved state contradicts repo evidence, trust executable repo evidence and record the mismatch in `SESSION.md`.

## Command: `/safe-code --save`

End the session safely.

Save does these things:

```
1. Review SESSION.md draft updates
2. Apply approved context/doc updates
3. Update context/progress-tracker.md with safe summary only
4. Update ACTIVE.md with Last Session and next_action
5. Append safe typed summary to LOG.md
6. Update MEMORY.md / BACKLOG.md / safe-refactor-code.md if their triggered data changed
7. Update CHANGELOG.md only for releasable changes
8. Wipe SESSION.md to a clean carry-forward template
9. Ensure local git repo exists when allowed by current repo state
10. Stage changes and create local commit only
11. Report commit hash + local-only status + next action
```

Do not push.

### Draft-Until-Save Rule

During normal work, draft updates to `context/*.md`, `AGENTS.md`, `CHANGELOG.md`, and continuity docs in `SESSION.md`. Apply final persistent doc/context updates on `/safe-code --save`.

Exceptions:

- Create missing scaffold files/folders needed for safe operation.
- Add `/context/current-issues.md` to `.gitignore` during setup.
- Write an active feature spec before implementation when feature work needs a contract.
- Update code files as required by the user task.

Never write content into `context/current-issues.md`; only create the blank template if missing.

---

## Deprecated Command Forms

- `/safe-code save` -> print: "Use `/safe-code --save`."
- `/safe-code continue` -> print: "Use `/safe-code --continue`."

---

## How to Make Decisions

Before every action, reason explicitly. Do not guess. Do not skip this.

## Measure Twice, Cut Once Policy

Every run must maintain a visible task checklist in `SESSION.md`. The checklist is the working plan and progress tracker.

HARD RULE: Keep the codebase clean, no tmp files, no dead code, no dead files. Stay organized all the time. No unnecessary folders, subfolders, or files.

Rules:

- Create or refresh `SESSION.md ## Task List` before Step 3.
- Every meaningful task starts as `[ ]`.
- Mark a task `[~]` while actively working on it.
- Mark a task `[x]` only after the action and its verification are complete.
- Add newly discovered work as a new task instead of doing it invisibly.
- Move unrelated or deferred tasks to `BACKLOG.md`; do not hide them in prose.
- On `/safe-code --save`, migrate unfinished checklist items into `ACTIVE.md Last Session.pending` and `next_action`.
- Do not claim completion unless the checklist, verification output, and final summary agree.
- If verification fails, keep the task `[~]` or `[ ]`, add the failure note, and route to `$debug-issue` when appropriate.

Default checklist:

```md
## Task List
- [ ] Detect active agent and docs folder
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
```

### Decision Framework

1. What are the 2-3 options?
2. What does each risk or preserve?
3. Which is safest given what I know?
4. Can this be undone?
5. What am I assuming? → verify from codebase first; ask only if cannot verify

If assumption is about user intent (not a technical fact) → verify from codebase first.
If assumption cannot be verified from codebase → stop and ask.

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
  Assumptions: <list — or "none">
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

Create only the scaffold needed for safe operation before reading the codebase. Do not populate long-term context with guesses.

Create missing folders/files:

```
AGENTS.md
CHANGELOG.md
context/
context/project-overview.md
context/architecture.md
context/code-standards.md
context/ai-workflow-rules.md
context/ui-context.md
context/progress-tracker.md
context/current-issues.md
context/feature-specs/
context/feature-specs/00-template.md
<agents-folder>/ACTIVE.md
<agents-folder>/SESSION.md
<agents-folder>/LOG.md
<agents-folder>/BACKLOG.md
<agents-folder>/MEMORY.md
<agents-folder>/safe-refactor-code.md
```

Rules:

- If a file exists, do not overwrite it.
- Create missing context files with templates only.
- Add `/context/current-issues.md` to `.gitignore` if absent.
- Never write user issue content into `context/current-issues.md`; it is a manual local scratchpad.
- For project facts, inspect repo evidence first, then draft updates in `SESSION.md`.
- Final context/doc writes happen on `/safe-code --save` unless a scaffold file or active feature spec is required now.

### Existing Project Backfill

If the repo already has code, docs, manifests, routes, schemas, tests, or configs:

- Treat the repo as source of truth.
- Backfill `context/*.md` from evidence only.
- Put unverifiable product or architecture facts into `context/progress-tracker.md` Open Questions.
- Generate feature specs only for upcoming work, active bugs, refactors, or missing documentation units.
- Do not create fake historical specs for completed features unless the user asks.

### Old Safe-Code Migration

Detect old-method projects by existing continuity docs with no `context/` folder:

```
<agents-folder>/ACTIVE.md
<agents-folder>/SESSION.md
<agents-folder>/LOG.md
<agents-folder>/BACKLOG.md
<agents-folder>/MEMORY.md
<agents-folder>/safe-refactor-code.md
```

Migration mapping:

- `MEMORY.md` -> draft candidate facts for `context/architecture.md`
- `BACKLOG.md` -> draft Next Up / Open Questions for `context/progress-tracker.md`
- `ACTIVE.md` -> draft Current Goal / In Progress for `context/progress-tracker.md`
- `LOG.md` -> safe decision summaries only
- existing `AGENTS.md` -> preserve verified rules and add Read First section

Migration rules:

- Do not delete old continuity docs.
- Do not copy raw logs, secrets, stack traces, private URLs, or `current-issues.md` content into context files.
- Mark uncertain migrated facts as Open Questions.
- Store migration draft in `SESSION.md` first; apply final migrated context files on `/safe-code --save`.
- After save, `context/` is canonical project context; `.codex/agents/` remains session state.

### `<project-root>/AGENTS.md`

Use this as the fallback shape for missing or thin files. Preserve generated blocks and verified existing project guidance.

```md
# AGENTS.md

## Read First
Read these files in order before implementation or architectural decisions:
1. `context/project-overview.md`
2. `context/architecture.md`
3. `context/code-standards.md`
4. `context/ai-workflow-rules.md`
5. `context/ui-context.md` if UI/design work
6. `context/progress-tracker.md`
7. Active spec in `context/feature-specs/` when implementing a feature

Do not read `context/current-issues.md` unless the user explicitly asks for debugging/issue analysis or references that file.

## Feature Specs
- Feature specs live in `context/feature-specs/`.
- AI may draft feature specs from user intent, repo evidence, and context files.
- Do not implement a feature until there is an active spec, unless the user explicitly asks for a tiny direct edit.
- For new projects, create specs in planned build order: `01-design-system.md`, `02-editor.md`, etc.
- For existing or in-progress projects, create specs only for upcoming work or unclear areas.
- Each spec must include goal, scope, likely touched areas, acceptance checks, and out-of-scope items.

## Session State
Read before resuming safe-code work:
- `<agents-folder>/ACTIVE.md`
- `<agents-folder>/SESSION.md`

## Project Facts
<!-- Exact commands, env vars, setup gotchas, package manager, non-obvious repo facts. -->

## Key Rules
- Never read or write outside the project root.
- Keep context updates drafted during work and finalized on `/safe-code --save`.
- Verify before claiming completion.
- Do not commit or publish `context/current-issues.md`.
```

When creating, populating, or reconciling `AGENTS.md`, do not fill the template blindly. Follow authoring rules below.

---

#### AGENTS.md authoring rules (agent init style)

Create or update `AGENTS.md` for this repository.

The goal is a compact instruction file that helps future agent sessions avoid mistakes and ramp up quickly. Follow these rules instead of improvising.

If the user provides focus or constraints in the `/safe-code` request, honor them while still verifying facts from the repo. Examples: "focus on onboarding agents", "document test commands", "preserve Claude/Cursor rules", or "do not mention deployment".

**Decision test for every line**

- Every line must answer: "Would an agent likely miss this without help?" If not, leave it out.
- Prefer a smaller but accurate file over a long, vague one.

**How to investigate**

Always investigate the repo before editing `AGENTS.md`. Read the highest-value sources first, stopping when you have enough signal:

- `README*`, root manifests, workspace config, and lockfiles
  (for example: `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `pnpm-lock.yaml`, `bun.lockb`).
- Build, test, lint, formatter, typecheck, and codegen config
  (for example: `next.config.*`, `vite.config.*`, `tsconfig.json`, `eslint*`, `prettier*`, `tailwind.config.*`, `postcss.config.*`).
- CI workflows, pre-commit hooks, and task runners
  (for example: `.github/workflows`, `.husky/`, `.lintstagedrc*`, `lefthook.yml`, `justfile`, `Makefile`, `flake.nix`, Git hooks, monorepo task tools).
- Existing instruction files
  (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`, or equivalents).

If architecture is still unclear after reading config and docs, inspect a **small** number of representative code files to find the real entrypoints, package boundaries, and execution flow. Prefer files that explain how the system is wired together over random leaf files.

**Source-of-truth rule**

- Prefer executable sources of truth over prose. If docs conflict with scripts or config, trust the executable source.
- Do not document anything you could not verify directly from the repo or from clearly trustworthy instruction files.

**What to extract**

Focus on high-signal facts that materially change how an agent should work in this repo:

- Exact developer commands, especially non-obvious ones
  (dev, build, lint, typecheck, unit tests, integration tests, migrations, codegen, seeding).
- Missing expected commands when that absence matters
  (for example: no `test` script, no `typecheck` script, no migration command wrapper).
- How to run a single test, a single package, or a focused verification step.
- Required command order when it matters (for example: `lint → typecheck → test`).
- Setup prerequisites and required environment variables, especially database URLs, auth secrets, API keys, local services, and seed data.
- Monorepo or multi-package layout: package boundaries, major directories, and real app/library entrypoints.
- Framework or toolchain quirks: generated code, migrations, codegen outputs, build artefacts, special env loading, dev server behaviour, infra deploy flow.
- Repo-specific style or workflow conventions that differ from common defaults.
- Testing quirks: fixtures, integration test prerequisites, required services, snapshot workflows, slow or flaky suites.
- Important constraints from existing instruction files that are still correct and useful.

Good AGENTS.md content is hard-earned context that usually required reading multiple files to infer.

**What to exclude**

Do **not** put these into `AGENTS.md`:

- Generic language or framework advice.
- Long tutorials, how-tos, or exhaustive file trees.
- Obvious conventions that any competent developer or model would already know.
- Speculative statements, guesses, or anything not verified from the repo.
- Content that belongs in another dedicated document already referenced from config.
- Tool-specific config files unless they matter to universal agent handoff.

When in doubt, omit.

**Behaviour when AGENTS.md is missing vs existing**

- If `AGENTS.md` is **missing**, effectively empty, or thin:
  - Create or repopulate it using the authoring rules above and the template as a fallback shape.
  - Include only sections backed by real, verified project details from the investigation above.
  - Preserve any existing generated comment blocks at the top and append your sections after them.
  - Ensure the result is useful as a first-read handoff for another AI agent without requiring it to inspect every config file first.
- If `AGENTS.md` already contains real project context:
  - Improve it in place rather than rewriting blindly.
  - Preserve guidance that is still correct and high-signal.
  - Delete or rewrite content that is clearly stale, generic, or contradicted by the current codebase.
  - Reconcile differences in favour of executable sources (config, scripts, CI) while keeping any still-valid nuance from older instructions.
  - Add missing high-signal facts discovered during investigation, even when the existing file is not empty.
  - Do not report "AGENTS.md already has real project context, so it was not rewritten" as the decision. The required decision is whether it was `reconciled` or audited and `unchanged`, with a short reason.

**Minimum quality bar after writing**

Before marking `AGENTS.md` done, verify it answers these for the current repo:

- What is this project and who/what uses it?
- What exact commands should an agent run for dev, build, lint, typecheck, tests, migrations, codegen, or seeds when those exist?
- What expected commands are intentionally absent or must be run through `npx`/tooling instead?
- What env vars, local services, databases, or setup prerequisites are required?
- What verification order should an agent use before claiming work is done?
- What are the true runtime/framework/database/auth/i18n/styling/package-manager facts?
- What directories and files are real entrypoints or source-of-truth wiring?
- What repo-specific gotchas would an agent likely miss without this file?
- Are any existing `AGENTS.md` claims contradicted by executable sources?
- What existing instruction files or generated blocks must be preserved?

If two or more answers are missing and discoverable from the repo, keep editing `AGENTS.md`; do not mark it `unchanged`, and do not finish with only a one-line reconciliation.

If any existing `AGENTS.md` claim is contradicted by executable sources, fix that claim before finishing even when the file is otherwise compact and useful.

**Questions to the user**

- Only ask the user questions if the repo genuinely cannot answer something important:
  - Undocumented team conventions or policies.
  - Branch / PR / release expectations.
  - Setup or test prerequisites that are known but not written down.
- Ask at most one short batch of questions if needed.
- Do **not** ask about anything the repo already makes clear.

**Length and density**

- For small repos, keep `AGENTS.md` short but ensure all critical commands, structure, and constraints are covered.
- For larger repos, summarize only the structural facts and workflows that actually change how an agent should work.
- Prefer short sections and bullets over long paragraphs.

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
- Add ambiguity to `context/progress-tracker.md` Open Questions before implementing.

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
> Temporary working memory. Auto-wiped on /safe-code --save.
> Do NOT rely on this for persistent state — use ACTIVE.md.

## Working Now
<!-- What is being actively processed this moment -->

## Task List
- [ ] Detect active agent and docs folder
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
change: created AGENTS.md, context files, CHANGELOG.md, and safe-code session docs
why: first run of /safe-code — initializing context and session docs
after: scaffold created, proceeding to Step 2

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

## Surgical Change Rules
- Touch only lines that directly fix the task — nothing else
- Match existing style: quotes, spacing, naming, indent — even if you'd do it differently
- Do NOT add type hints, docstrings, or comments unless explicitly asked
- Do NOT reformat adjacent code while fixing something
- Do NOT refactor things that aren't broken
- Unrelated issues found → log in BACKLOG.md, do not fix silently
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

### 1c. Confirm Initialization

```
Project root: <path>
Agent: <agent>
Agents folder: <project-root>/<agent-folder>/agents/

Root:    AGENTS.md - <created|exists|populated>  |  CHANGELOG.md - <created|exists>
Context: context/ - <created|exists|migrated>   |  feature-specs/ - <created|exists>
         current-issues.md - <created|exists|gitignored>
Agent:   ACTIVE.md - <created|exists>           |  SESSION.md - <created|exists>
         BACKLOG.md - <created|exists>          |  LOG.md - <created|exists>
         MEMORY.md - <created|exists>           |  safe-refactor-code.md - <created|exists>

All paths inside project root. Proceeding.
```

---

## Step 2: Load Context + Detect Session Mode

### 2a. Load Layer 1 (always, every session)

```
1. AGENTS.md
2. context/project-overview.md
3. context/architecture.md
4. context/code-standards.md
5. context/ai-workflow-rules.md
6. context/ui-context.md only for UI/design work
7. context/progress-tracker.md Current Phase / Current Goal / Next Up / Open Questions only
8. ACTIVE.md Before/Current/Next only, if present
9. SESSION.md Carry Forward + Draft Updates only, if present
10. LOG.md last 3 typed entries only, if present
```

Do not read `context/current-issues.md` unless the user explicitly asks for debugging/issue analysis or references that file.

### 2b. Detect saved session from ACTIVE.md

This step is mandatory for both `/safe-code` and `/safe-code --continue`.

```
if Last Session.status = "saved" and pending/next_action exists:
  -> Auto-continue, even for plain /safe-code
  -> Load Layer 2: context/progress-tracker.md full + ACTIVE.md full + SESSION.md full + LOG.md full
  -> Print: "Saved safe-code session found; resuming automatically. Say 'fresh pass' to ignore saved state."
  -> Print: "Pending: <pending> | Next: <next_action>"
  -> Skip completed slices
  -> Resume from next_action directly

if Last Session.status = "completed":
  -> Load Layer 1 only
  -> Start new pass unless user asks to inspect previous work

if Last Session.status = "none" or block missing:
  -> Load Layer 1 only
  -> Start setup/orientation
```

If the user explicitly says `fresh pass`, `fresh setup`, or `ignore saved state`, do not auto-continue. Record this in `SESSION.md`.

### 2c. Create or Update Task List

Before Step 3, write `SESSION.md ## Task List`.

```
if /safe-code with no saved state:
  -> create fresh default checklist
  -> mark completed setup items [x] as they finish

if /safe-code auto-continues or /safe-code --continue:
  -> load unfinished items from ACTIVE.md Last Session.pending
  -> merge them with default checklist
  -> keep completed items visible only if needed to avoid repeated work

if /safe-code --save:
  -> read current checklist
  -> migrate unchecked or active items into ACTIVE.md Last Session.pending
  -> set next_action to first unfinished task
```

Default checklist must include:

```md
- [ ] Load AGENTS.md and context files
- [ ] Detect saved state / migration need
- [ ] Draft or update active feature spec if needed
- [ ] Check git state and rollback safety
- [ ] Check graph readiness when useful
- [ ] Explore repo facts before context backfill
- [ ] Audit dead code/stale files only when in scope
- [ ] Select Orientation/Audit/Cleanup profile
- [ ] Execute scoped code changes if requested
- [ ] Verify changed behavior
- [ ] Draft context/doc updates in SESSION.md
- [ ] Save final context/session updates on /safe-code --save
```

Update checklist after every major step. Never wait until final summary to mark progress.

### Last Session block (written by `/safe-code --save`)

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

Check LOG.md line count on every `/safe-code --save`.

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

Run `git remote -v` and classify into one of three buckets for information only. Remote detection must never cause an automatic push.

```
BUCKET A — Git-native platforms
  Matches: github.com, gitlab.com, bitbucket.org,
           dev.azure.com, codeberg.org,
           self-hosted GitLab/Gitea (custom domain),
           SSH custom URLs, HTTPS custom URLs
  Save action: local git commit only

BUCKET B — Git + external deploy platforms
  Matches: vercel.com, netlify.com, pages.cloudflare.com,
           any platform that auto-deploys on push
  Save action: local git commit only
  Note:    "Remote push may trigger deploy, so /safe-code --save never pushes."

BUCKET C — Local only
  Matches: no remote configured
  Save action: local git commit only
  Note:    "No remote detected."
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

## Step 3d: Infer Run Intent

`/safe-code` has only one entry command. Do not add extra commands for docs-only, init-only, or audit-only work. Instead, infer the safest run profile from repo facts.

### Intent Profiles

```
Orientation  -> repo is new, no commits, no remote, missing/thin AGENTS.md, or context/session docs just created
Audit        -> rollback is missing or risky, worktree is heavily dirty, user asked to check/review, or candidates are uncertain
Cleanup      -> git rollback exists, worktree state is understood, AGENTS.md is reconciled, and high-confidence cleanup is available
```

### Profile Rules

- Always complete `AGENTS.md` audit/reconciliation before selecting the profile.
- If `AGENTS.md` was `created`, `populated`, or meaningfully `reconciled`, prefer `Orientation` or `Audit` unless the user explicitly asked for cleanup.
- If git has `0` commits, no repo, or no rollback path, choose `Orientation` or `Audit`; do not delete code.
- If the whole tree is untracked, choose `Audit`; write docs and flags only.
- If no High-confidence dead-code candidates exist, choose `Audit`; do not force a refactor.
- If the user asks for broad "cleanup", "hygiene", or `/safe-code` in a stable repo with rollback, `Cleanup` is allowed after the pre-plan safety check.

### Profile Effects

```
Orientation:
  - create/reconcile AGENTS.md, context files, and session docs
  - load context and record project facts
  - do not remove or refactor code

Audit:
  - do everything in Orientation
  - scan for risks, stale docs, dead code, and verification gaps
  - write findings to BACKLOG.md, MEMORY.md, or safe-refactor-code.md
  - do not remove code unless the user separately approves a Mode B plan

Cleanup:
  - do everything in Audit
  - execute only High-confidence, reversible slices
  - verify after each slice
```

The profile is an internal behavior guide. The final safety mode remains A/B/C.

### 3e. Intent reasoning output

```
Reasoning:
  AGENTS.md: <created | populated | reconciled | unchanged>
  Rollback: yes/no
  Worktree: <clean | dirty | untracked-heavy>
  User intent: <orientation | audit | cleanup | unclear>
  Profile: <Orientation | Audit | Cleanup>
  Why: <one sentence>
```

---

## Step 3f: Graph Readiness Check

Use the code-review graph as an analysis accelerator when available. It never overrides the safety rules above.

1. Detect graph access:
   - MCP graph tools already available
   - `code-review-graph` command available
   - `uvx` command available
   - existing `<project-root>/.mcp.json`
2. If MCP graph tools are missing but `uvx` exists, auto-create or update project-local `.mcp.json`:

   ```json
   {
     "mcpServers": {
       "code-review-graph": {
         "command": "uvx",
         "args": ["code-review-graph", "serve"]
       }
     }
   }
   ```

   Preserve existing MCP servers when updating `.mcp.json`.
3. If `code-review-graph` is installed locally but MCP tools are not exposed, record the install as available and continue manual/CLI graph fallback for this run.
4. Do not run `pipx install`, edit global MCP files, or write outside the project root automatically.
5. Automatically run `$build-graph` when MCP graph tools are available:
   - `get_minimal_context_tool(task="safe-code hygiene pass")`
   - `build_or_update_graph_tool()` if the graph is stale or empty
   - `list_graph_stats_tool()` to confirm files, nodes, edges, and languages
6. If graph tools are unavailable, empty, or fail, record `Graph: unavailable` and continue with manual scans.
7. If graph coverage is partial, use graph findings only for covered languages and keep manual entrypoint/config checks.

Do not ask the user to run helper skills manually. `/safe-code` owns helper orchestration.

### 3f. Graph reasoning output

```
Reasoning:
  Graph: <ready | bootstrapped .mcp.json | command available | unavailable | partial | stale>
  Files/nodes/edges: <counts | unknown>
  Languages: <list | unknown>
  Decision: <use graph + manual checks | manual checks only>
  Why: <one sentence>
```

---

## Step 3g: Auto Helper Routing

`/safe-code` automatically decides which helper skills to use. The user should only need `/safe-code`, `/safe-code --continue`, and `/safe-code --save`.

| Condition | Auto action |
|---|---|
| Any `/safe-code`, `/safe-code --continue`, or `/safe-code --save` run | Apply `$senior-dev` discipline |
| First run, missing/thin `AGENTS.md`, or architecture facts needed | Run `$explore-codebase` or equivalent graph/manual orientation |
| Graph missing, stale, or branch changed | Run `$build-graph` if graph tools exist |
| Dead-code audit or cleanup is in scope | Run `$codebase-pruner` in analysis mode first |
| Rename, restructure, modernization, or verified cleanup follow-up is in scope | Run `$safe-refactor-code` |
| Edits were made or risk is non-trivial | Run `$review-changes` before final summary |
| A test fails, verification fails, or user asks about a bug/regression | Run `$debug-issue` |

Helper skills must not make broad changes merely because `/safe-code` ran. Their findings feed `SESSION.md` drafts and the safe-code task list first. If a helper skill cannot run, use its documented fallback behavior inside `/safe-code` and record the fallback in the final summary.

---

## Step 4: Audit Dead Code

> **Layer 3 Trigger:** Load `MEMORY.md` now if not already loaded.

Invoke `$codebase-pruner` in `Audit` mode only when audit/cleanup is in scope. Orientation profile may record that pruning was skipped.

- Classify every candidate explicitly (High vs Medium)
- Cross-reference `safe-refactor-code.md` for previously flagged items
- Use `refactor_tool(mode="dead_code")`, callers/importers queries, and impact radius when graph tools are ready
- Treat graph findings as candidate evidence; still check configs, exports, dynamic loaders, and runtime wiring
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

### Pre-Plan Check (run before deciding mode)

Use the Step 3d profile first:

- `Orientation` profile -> Mode C unless the user explicitly requests a cleanup plan.
- `Audit` profile -> Mode C by default; Mode B only if there is a small, reversible cleanup plan worth asking about.
- `Cleanup` profile -> continue with the pre-plan check below.

Answer these before producing the execution plan:

```
- Multiple valid interpretations of "dead" for any candidate? → if yes, default Mode B
- Blast radius > 10 files?                                   → stop, report first
- Graph impact radius > 10 files?                             → stop, report first
- Any candidate in a recently modified file (git log)?       → flag, extra caution
- Can every planned step be verified with a command?         → if no, default Mode B
```

If any check raises doubt → default to Mode B.

```
Reasoning:
  High candidates: <count>
  Rollback: yes/no
  Risk: low/medium/high
  Pre-Plan flags: <list — or "none">
  Decision: A / B / C
  Why: <one sentence>
```

- **A** — `Cleanup` profile + git clean + rollback + all High + no surprises → auto-execute
- **B** — cleanup is possible but dirty / borderline / large scope → show plan, wait for approval
- **C** — `Orientation` or `Audit` profile, no git, no rollback, or plan-only asked → docs + findings only

---

## Step 6: Execute Dead Code Removal

> **Layer 3 Trigger:** Load `safe-refactor-code.md` now if not already loaded.

Run `$codebase-pruner` in `Execute` mode. Requires explicit user approval before deleting any candidate that is not High confidence.

### Print Execution Plan Before Starting

```
Slice 1: <path/to/file>:<symbol>
  action: delete
  verify: <command> → expect: <zero results | tests pass>

Slice 2: <path/to/file>:<symbol>
  action: delete
  verify: <command> → expect: <zero results | tests pass>
```

### Execution Rules

- Execute one slice at a time — never batch
- Verify after each slice before moving to the next
- Roll back only the failing slice if verification fails
- If verification command unavailable → flag as Medium, skip to next slice
- After each slice, run `detect_changes_tool(detail_level="minimal")` when graph tools are ready
- Draft new flagged candidates in `SESSION.md`; write them to `safe-refactor-code.md` on `/safe-code --save`

---

## Step 7: Refactor + Draft Docs

> **Layer 3 Trigger:** Load `MEMORY.md`, `BACKLOG.md`, and `CHANGELOG.md` only if their data is needed.

Run `$safe-refactor-code` only when refactor scope exists from user request, active feature spec, cleanup profile, or verified pruner finding.

Graph-aware refactors:

- Use graph rename previews for symbol renames.
- Check impact radius before editing shared code.
- Check affected flows before runtime-path changes.
- Run graph delta review before final docs sync when graph tools are ready.

Then automatically run `$review-changes` when code changed or graph/manual impact analysis reports Medium or High risk. Skip only for pure documentation/session updates.

If verification fails or a regression appears, automatically run `$debug-issue` on the failing symptom before asking the user for help.

### Draft-Until-Save Sync Table

During work, draft updates in `SESSION.md`. Apply them to persistent docs only on `/safe-code --save`, except scaffold files and active feature specs.

| File | Draft during work | Apply on `/safe-code --save` |
|---|---|---|
| `AGENTS.md` | Missing/stale Read First rules, commands, project facts | Yes |
| `context/project-overview.md` | Evidence-backed product/project facts | Yes |
| `context/architecture.md` | Evidence-backed stack, boundaries, invariants | Yes |
| `context/code-standards.md` | Verified conventions | Yes |
| `context/ai-workflow-rules.md` | Workflow rules discovered from repo/team docs | Yes |
| `context/ui-context.md` | UI tokens/components only when UI work occurs | Yes |
| `context/progress-tracker.md` | Current phase, completed work, decisions, safe notes | Yes |
| `context/current-issues.md` | Never draft or write user issue content | No |
| `context/feature-specs/*.md` | Active spec before implementation | Write immediately when needed |
| `CHANGELOG.md` | Releasable changes | Yes |
| `ACTIVE.md` | Last Session, pending checklist, next_action | Yes |
| `SESSION.md` | Live task list, temp decisions, draft doc updates | Live during work; wipe on save |
| `LOG.md` | Safe typed summary only | Yes |
| `MEMORY.md` | Audit/refactor notes not canonical context | Yes if triggered |
| `safe-refactor-code.md` | Flagged candidates and guardrails | Yes if triggered |
| `BACKLOG.md` | Operational follow-ups | Yes if triggered |

Do not copy raw `current-issues.md` content, secrets, stack traces, private URLs, or long logs into any persistent file.

---

## Step 8: Final Summary

```
=== safe-code v2.9 session complete ===

Project root: <path>
Agent: <agent>
Agents folder: <agents-folder>
Execution mode: <A | B | C>
Run profile: <Orientation | Audit | Cleanup>
Session type: <fresh | resumed from <saved_at>>
Graph:  <ready | unavailable | partial> | files: <count> | nodes: <count> | edges: <count>

Git:    <repo found | not found> | <commit count> commits | branch: <branch>
Remote: <URL | none>  [Bucket <A | B | C>]
Save:   local commit only; no push

Files:
  Root:    AGENTS.md <created|populated|reconciled|unchanged>    CHANGELOG.md <created|existed>
  Context: context/ <created|existed|migrated>       feature-specs/ <created|existed>
           current-issues.md <created|existed|gitignored>
  Agent:   ACTIVE.md <created|existed>               SESSION.md <created|existed>
           BACKLOG.md <created|existed>              LOG.md <created|existed>
           MEMORY.md <created|existed>               safe-refactor-code.md <created|existed>

Loaded (Layer 1): AGENTS.md, context index files, ACTIVE.md index, SESSION.md carry forward, LOG.md last 3
Loaded (Layer 2): <resume files if auto-continued/--continue, else: none>
Loaded (Layer 3): <active spec/audit/refactor files loaded this session>

Decisions: <list>
Removed:   <list>
Flagged:   <list>
Refactors: <summary>
Review:    <review-changes run | skipped: docs-only | unavailable fallback>
Debug:     <debug-issue run | not needed | unresolved blocker>
Task list: <completed>/<total> complete; unfinished moved to <ACTIVE.md|BACKLOG.md|none>
Follow-up saved for next `/safe-code --continue`: <list>

Run /safe-code --save to commit and close this session.
```
