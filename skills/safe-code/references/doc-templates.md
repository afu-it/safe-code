# safe-code reference: doc + session templates

> Fallback shapes for `.safe-code/` files — applied to **missing** files only, never over an
> existing one. Read only the sections the step needs:
>
> | Section | Read when |
> |---|---|
> | each `context/` file, `00-template.md` | Step 1, for that missing file |
> | each session file (`ACTIVE.md` … `safe-refactor-code.md`) | Step 1, for that missing file |
> | SESSION.md carry-forward | `--save` (the shape `SESSION.md` is wiped to) |
> | `CHANGELOG.md`, `ui-context.md` | only when that lazy file is first created |
> | `user-preferences.local.md` | team mode, or a personal value to record |
> | Provider Bridge Files | writing or reporting a bridge |
>
> The hook settings JSON lives in `references/save-reminder-hook.md`; what earns a session-file
> entry, in `references/save-procedure.md` (Session-File Discipline).

### `<project-root>/.safe-code/CHANGELOG.md` — created on the first releasable change

```md
# CHANGELOG.md

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [Unreleased]
### <Added | Changed | Fixed | Removed | Security>
- <the releasable change that created this file — never an invented "Project initialized" line>

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

Preference phrases to watch for: AGENTS.md `## User Preference Detection`. Draft each in
`SESSION.md`; apply it here on `/safe-code --save`.

## Hard Preferences
- <!-- Example: Use SVG icons only; do not use emoji icons. -->

## Hard Dislikes / Avoid
- <!-- Example: Avoid overcomplicated folder structures. -->

## Style Preferences
- <!-- Tone, UI style, naming, formatting preferences. -->

## Git Identity
<!-- Optional. Checked by Step 3e before the first commit; never auto-filled. Personal: in team
     mode leave `-` here and put the values in user-preferences.local.md (it wins). -->
- name: <!-- handle or name to commit as -->
- email: <!-- e.g. 12345+handle@users.noreply.github.com -->

## Save Bridge
<!-- Optional. Absolute path of a personal journal that --save appends one block to. Personal:
     in team mode set it in user-preferences.local.md instead (it wins). -->
- diary_path: -

## Workflow Preferences
- <!-- How user wants agent to plan, save, ask, or execute. -->

## Team Mode
<!-- Optional. Overrides auto-detection (references/team-mode.md). `on` or `off`; leave `auto` to detect. -->
- team: auto

## Confirmed Decisions
- <!-- Date — decision — reason. -->
```

---

### `.safe-code/context/user-preferences.local.md` — per-developer overrides (optional)

Created only when a developer has a personal value to record. Gitignore
`/.safe-code/context/user-preferences.local.md` at creation; never committed. Its values override
`user-preferences.md`; read by Step 3e and the Save Bridge only, not Layer 1. `team:` stays in
the shared file.

```md
# User Preferences — local (this developer only, gitignored)

## Git Identity
- name: <!-- handle or name to commit as -->
- email: <!-- e.g. 12345+handle@users.noreply.github.com -->

## Save Bridge
- diary_path: -
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

## Testing
- <!-- Command(s), and what they cover. -->
- <!-- The known test total lives on the `test:` line of AGENTS.md `## Commands`
  (`verified: <sha> · <date> · known total: N`) — the single source; do not repeat it here. -->
- tiers: <!-- Optional, project-declared only, e.g. "small change: unit; schema/auth: full
  suite". safe-code never picks a lighter tier itself; no tiers declared = full suite. -->
- Reject: implementation-coupled tests (mock internal collaborators, break on refactor),
  tautological tests (expected value recomputed the way the code does it — use an
  independent literal, worked example, or the spec), horizontal slicing (all tests first,
  then all code). Work one test -> one implementation -> repeat.
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

### `.safe-code/context/ui-context.md` — created on the first UI work

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
- <!-- Unknown product/technical facts — sharp enough to phrase as a question. One per line,
     most blocking first: the session hook's brief shows the count and the top two. -->

## Not Yet Specified
- <!-- Fog of war: in-scope work you can see coming but cannot yet phrase as a sharp
     question. Do not pre-slice it into specs. Move each patch out the moment it
     graduates to an Open Question or a spec, so it lives in exactly one place. -->

## Architecture Decisions
- <!-- Safe summaries only; include why. -->

## Session Notes
- <!-- Safe resume notes. No secrets, raw logs, or private URLs. -->
```

---

### `.safe-code/context/current-issues.md` — local-only issue tracker (user + AI)

Gitignore it together with `/.safe-code/backups/` and `/.safe-code/.last-save` (git keeps no
mtimes, so a committed stamp carries nothing); all three stay local-only.

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

status: suggested   <!-- suggested | approved | in-progress | done | rejected | removed (<date>) -->
created: <DATE>
updated: <DATE>

## Goal
<!-- 1-2 sentences. Concrete output when complete. -->

## Open Questions
<!-- Max 3. Only for decisions that materially change the design. A spec cannot flip
     suggested -> approved while any marker remains: ask the user each question (offer a
     recommended answer), write the answer into the relevant section, delete the marker. -->
- [NEEDS CLARIFICATION: <specific question>]

## Scope
### In Scope
- <!-- What will be built. -->

### Out of Scope
- <!-- What must not be touched. -->

## Design / Behavior
<!-- UI, API, data, and behavior decisions. Reference context files. -->

## Implementation Notes
<!-- Durable: interfaces, type names, signatures, config shapes, behavioural contracts.
     No file paths, no line numbers — the code moves while this spec waits. A snippet
     that encodes a decision (schema, state machine, type shape) may be inlined. -->
- <!-- Contract or interface this unit introduces or changes. -->

## Dependencies
<!-- Verify each package exists on its official registry (npm/PyPI/crates/...) before the
     spec is approved. If an install later fails, STOP — never substitute a
     similar-sounding package; re-verify the name with the user. -->
- <!-- package-name (reason), or None. -->

## Verify When Done
<!-- File existence is not verification; SESSION/LOG claims are not evidence — re-check
     against the repo. -->
### Behavior (observable when running or using it)
- [ ] <!-- What a user/caller can see working. -->
### Artifacts (files exist)
- [ ] <!-- Exact paths created or changed. -->
### Wiring (new code is reachable)
- [ ] <!-- The route/import/caller that connects it — name it. -->
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
<!-- Blocked/Next entries carry a runnable pointer, not just prose:
     - <one-line state> | evidence: <file:line or exact `grep -n` command>
     On resume, re-run the pointer instead of trusting the prose; a pointer that no
     longer matches is a detected stale fact. -->

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

<!-- `next_action:` is one line the session hook's brief quotes at the next session start —
     a runnable first step, not a summary. -->

---

### `.safe-code/SESSION.md` — working memory RAM (wipe on save)

```md
# SESSION.md
_<DATE> <TIME>_ · run_start: <HEAD sha at Step 3a; commits after it that this run did not make are foreign>
> Temporary working memory. Auto-wiped on /safe-code --save.
> Do NOT rely on this for persistent state — use ACTIVE.md.

## Working Now
<!-- What is being actively processed this moment -->

## Task List
<!-- Copy the canonical checklist from safe-code SKILL.md (Measure Twice, Cut Once
     Policy): Light for light runs, Default for setup and audit runs.
     States: [ ] todo · [~] active · [x] done after verification ·
     [p] parked: needs approval (open, not abandoned) · [!] abandoned: <reason>. -->
- [ ] <task>  · type: <commit type> · files: <paths>

## Drafts
<!-- Draft doc/context updates (Draft-Until-Save) — applied on /safe-code --save.
     Content here is what the save-reminder treats as unsaved work. -->

## Temp Decisions
<!-- Decisions made mid-session, not yet committed to ACTIVE.md -->

## Mid-Step Notes
<!-- Notes for current step only — discard after step completes -->

## Carry Forward
<!-- Important findings to migrate into ACTIVE.md or context docs on save -->
```

#### SESSION.md carry-forward — the shape `--save` wipes it to

Everything else was applied (drafts -> their files, unfinished tasks -> `ACTIVE.md pending`,
deferred work -> `BACKLOG.md`), so the wiped file holds no work by the save-reminder's
definition: no `[~]` item, no `[x] … files:` task, nothing under `## Drafts`.

```md
# SESSION.md
_<DATE> <TIME>_ · saved · run_start: -
> Temporary working memory. Wiped to this shape on every /safe-code --save.
> Resume state lives in ACTIVE.md (Last Session).

## Working Now
- none

## Task List
<!-- Written at the next run from the canonical checklist. -->

## Drafts
<!-- Empty after a save. -->

## Carry Forward
- <0–5 one-line notes the next session needs first (e.g. `user WIP: <paths>`, an unanswered question); else `- none`>
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
> Optional `pruned:` — one line per fact a save moved out of a context file (Brain Budget,
> references/agents-md-authoring.md): `- <file>: <fact> (superseded by <entry> | stale since <sha> | removed <date>)`.

Valid types: init | decision | refactor | bugfix | risk | blocked | verify

---

## <DATE TIME>
type: init
scope: project root
topic: scaffold
before: no doc structure existed
change: created AGENTS.md, context files, and safe-code session docs
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

### Host table + rules (the one home; SKILL.md keeps a short summary)

`AGENTS.md` is the default and only required output. A bridge is written only for the host currently running safe-code, and only when that host does not read `AGENTS.md`:

| Host | Reads `AGENTS.md` natively? | Output when it is the running host |
|---|---|---|
| OpenAI Codex, Amp, Google Jules, Cursor, Factory, RooCode, Kilo Code, goose, opencode, Zed, Warp, Windsurf, Devin, GitHub Copilot coding agent, VS Code, Augment Code, Junie, Cline | Yes | none — `AGENTS.md` only |
| GitHub Copilot in VS Code | Yes, via setting `chat.useAgentsMdFile` | none — `AGENTS.md` only |
| Claude Code | v2.1.277+ only when no `CLAUDE.md` / `.claude/CLAUDE.md` / `CLAUDE.local.md` exists here or in any parent (often one does) | `CLAUDE.md` bridge (`@AGENTS.md` import) — always: it works in every case and never double-reads. Existing `CLAUDE.md` (or `.claude/CLAUDE.md`) -> append the bridge block; else create a minimal one. Never edit `~/.claude/CLAUDE.md`. |
| Gemini CLI | Via config (`context.fileName`); default is `GEMINI.md` only | no file — PRINT (never auto-edit) `{"context":{"fileName":["AGENTS.md","GEMINI.md"]}}` for `.gemini/settings.json`; an existing `GEMINI.md` is not touched |
| Aider | Via config | no file — PRINT the suggestion: add `read: AGENTS.md` to `.aider.conf.yml` |
| Undetectable | — | none — `AGENTS.md` only, plus one report line naming the two exceptions: Claude Code when any `CLAUDE.md` exists above the project; Gemini CLI until `context.fileName` lists `AGENTS.md` |

Rules:

- When appending to an existing `CLAUDE.md`, copy only the lines between the bridge markers
  (`<!-- safe-code:bridge … -->` through `<!-- /safe-code:bridge -->`), never the `# CLAUDE.md` heading.
- Bridges are **pointers, not state** — a few lines redirecting to `AGENTS.md` + `.safe-code/context/`. Never duplicate project facts into them.
- **Write only the running host's bridge, only when it needs one**; `AGENTS.md` is always written. No automatic `GEMINI.md`, `.github/copilot-instructions.md`, or `.cursor/rules/safe-code.mdc`.
- **Never delete or overwrite** an existing bridge: `CLAUDE.md` not pointing at the brain -> append the marked block; already pointing there -> leave it. Older bridges (`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md`) stay untouched.
- Bridges are scaffold files — written immediately; never legacy state.

> Substitute `v<VERSION>` with the running skill version and `<DATE>` with today — the stamp
> lets a later run (and the shipped `scripts/check.sh`) see which version wrote the bridge.

### `<project-root>/CLAUDE.md`

```md
# CLAUDE.md

<!-- safe-code:bridge · written by safe-code v<VERSION> · <DATE> -->
> Project context is maintained by safe-code. Read these before any task.

@AGENTS.md

After AGENTS.md, read the files it lists under `.safe-code/context/` (project overview,
architecture incl. the Navigation map, code standards, workflow rules, progress). Treat them
as the source of truth; do not re-scan the whole codebase for facts already documented there.
<!-- /safe-code:bridge -->
```
