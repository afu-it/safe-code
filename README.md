# safe-code

> **Spec-first repo hygiene.** Project context, session memory, safe cleanup, and clean handoff in three commands.

[![version](https://img.shields.io/badge/version-3.1-teal?style=flat-square)](./skills/safe-code/SKILL.md)
[![works with](https://img.shields.io/badge/works%20with-Codex%20%7C%20Claude%20%7C%20Cursor%20%7C%20Windsurf-blue?style=flat-square)](#)
[![license](https://img.shields.io/badge/license-MIT-green?style=flat-square)](#)

---

## Install

```bash
# Install into your current project
npx skills add afu-it/safe-code

# Install globally (all projects)
npx skills add afu-it/safe-code -g

# Preview before installing
npx skills add afu-it/safe-code --list
```

Works with **Codex, Claude Code, Cursor, Windsurf**, and 40+ other agents.

---

## Three Commands

| Command | What it does |
|---|---|
| `/safe-code` | Setup, auto-resume saved work, or run a fresh hygiene pass |
| `/safe-code --continue` | Explicitly resume saved work |
| `/safe-code --save` | Finalize context/docs, commit locally, and close session |

If users forget `--continue`, `/safe-code` auto-detects saved unfinished state and resumes.

### Verify (optional)

The conventions above are normally maintained by the agent. To check them deterministically — for a human, a CI step, or the agent itself — run the bundled script from anywhere inside the project:

```bash
bash scripts/check.sh
```

It verifies `AGENTS.md`, the `context/` files, and the `.agents/` session docs exist, flags a stale `SESSION.md`, detects legacy `.codex/agents` layouts to migrate, and **fails** (exit 1) if `context/current-issues.md` was accidentally committed. Warnings are advisory; only that hard check fails the run.

Upgrading from a pre-3.0 install? Move legacy session folders into `.agents/` automatically:

```bash
bash scripts/migrate.sh           # preview (dry-run)
bash scripts/migrate.sh --apply   # move files (uses git mv when tracked)
```

It never overwrites existing `.agents/` files, uses `git mv` to preserve history, and cleans up the empty legacy folders afterward.

---

## How It Works

```
/safe-code
```

```
 Step 0  →  Locate project root (single agent-agnostic `.agents/` folder)
 Step 1  →  Create/reconcile AGENTS.md, context/, and session docs
 Step 2  →  Load AGENTS.md first, then context files, then saved state if present
 Step 3  →  Check git rollback safety + graph readiness
 Step 4  →  Explore/audit repo facts before writing context
 Step 5  →  Draft or read active feature spec when building a feature
 Step 6  →  Execute scoped code changes, cleanup, or refactor only when in scope
 Step 7  →  Verify, review, debug failures if needed
 Step 8  →  Draft context/doc updates in SESSION.md
--save   →  Apply final context/docs + local commit only
```

Nothing is pushed. Nothing risky is deleted without rollback evidence.

---

## Context + Session Docs

Every project gets one root entry point, project context, feature specs, and runtime session state:

```text
your-project/
├── AGENTS.md
├── CHANGELOG.md
├── context/
│   ├── project-overview.md
│   ├── architecture.md
│   ├── user-preferences.md
│   ├── code-standards.md
│   ├── ai-workflow-rules.md
│   ├── ui-context.md
│   ├── progress-tracker.md
│   ├── current-issues.md        # local-only, gitignored, user-written
│   └── feature-specs/
│       └── 00-template.md
└── .agents/                     # agent-agnostic session memory (Codex/Claude/Cursor/Windsurf)
    ├── ACTIVE.md
    ├── SESSION.md
    ├── LOG.md
    ├── BACKLOG.md
    ├── MEMORY.md
    └── safe-refactor-code.md
```

- `AGENTS.md` stays at root and tells agents what to read first.
- `context/` is canonical long-term project brain.
- `context/user-preferences.md` stores explicit durable user preferences, like “SVG icons only, no emoji icons”.
- Agents watch for strong preference language like `I don't want`, `aku taknak`, `I prefer`, `please remove`, `jangan`, `always`, and `never`.
- `context/feature-specs/` holds AI-written build specs, one unit per file.
- `context/current-issues.md` is manual user scratchpad, never committed.
- `.agents/` is runtime/session memory, shared across agents.

---

## Draft Until Save

During work, safe-code drafts persistent documentation changes in `SESSION.md`.

`/safe-code --save` applies final updates to:

- `context/*.md`
- `AGENTS.md`
- `ACTIVE.md`
- `LOG.md`
- `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md` when triggered
- `CHANGELOG.md` only for releasable changes

Exceptions written before save:

- missing scaffold files/folders
- `/context/current-issues.md` gitignore rule
- active feature specs in `context/feature-specs/`
- code changes required by user task

---

## Existing Projects and Old Method Migration

safe-code works for blank, in-progress, finished, and old safe-code projects.

For existing projects:

- reads repo evidence first: README, manifests, routes, schemas, tests, configs
- backfills context files only from proven facts
- places unknown facts in `context/progress-tracker.md` Open Questions
- creates feature specs only for upcoming work, bugs, refactors, or missing documentation units

For old safe-code projects:

- keeps old continuity docs
- migrates useful facts into `context/` as drafts
- treats `context/` as canonical project context after `/safe-code --save`

---

## Feature Specs

Feature specs are written by AI from user intent + context + repo evidence.

Example:

```text
context/feature-specs/
├── 01-design-system.md
├── 02-editor.md
└── 03-auth.md
```

Each spec includes:

- goal
- scope and out-of-scope
- design/behavior
- likely touched files or areas
- dependencies
- verification checklist

safe-code should not implement feature work without an active spec unless the user asks for a tiny direct edit.

---

## Current Issues

`context/current-issues.md` is created by safe-code, but manually written by the user.

It is gitignored:

```gitignore
/context/current-issues.md
```

User prompt inside the template:

> Explore the current-issues.md file and deeply analyze the problem. Only when you have the analysis, give it back to me with the idea of how you're planning to solve it, and then wait for me to give you the green light to execute it.

Agents do not read this file unless explicitly asked.

---

## Helper Skills

Users normally call only `/safe-code`.

| Skill | Role | Called by safe-code? |
|---|---|---|
| `senior-dev` | Task lists, adversarial strategy, clean repo discipline | Yes |
| `build-graph` | Graph build/update when available | Yes |
| `explore-codebase` | Repo orientation and facts | Yes |
| `codebase-pruner` | Dead-code analysis and scoped cleanup | When in scope |
| `safe-refactor-code` | Refactor with impact checks | When in scope |
| `review-changes` | Delta review before final summary | After edits/risk |
| `debug-issue` | Failure/regression tracing | On failures/bugs |

Helper skills analyze first and never make broad changes merely because `/safe-code` ran.

---

## Execution Modes

| Mode | When | What happens |
|---|---|---|
| **A — Auto** | Git clean, high-confidence, reversible | Runs scoped plan |
| **B — Ask** | Dirty worktree, borderline, broad scope | Shows plan, waits |
| **C — Plan only** | No rollback, orientation/audit, or requested | Findings only |

---

## What's New

**v3.1** — agent config trust audit.

- New **Step 4b: Agent Config Trust Audit** — Audit/Cleanup profiles now scan repo-controlled agent config (`.claude/`, `.mcp.json`, hooks, commands, skills, rules, `AGENTS.md`) as supply chain artifacts: hidden unicode, embedded payloads, outbound exec primitives, risky env overrides (`ANTHROPIC_BASE_URL`), committed secrets, and unknown MCP servers.
- Report-only by design: findings go to `SESSION.md`/`BACKLOG.md`; trust decisions stay with the user. High findings quarantine the affected file's content as instructions for the rest of the run.
- Patterns and High/Medium/Info classification live in `references/agent-config-audit.md` (Layer 3, loaded on demand). Uses `agentshield` CLI when available; the built-in pattern scan alone is a valid pass.

**v3.0** — unified session folder + leaner skill (breaking change).

- **Breaking:** session/continuity docs now live in one agent-agnostic `.agents/` folder at the project root, replacing per-agent `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, and the helper skills' `.codex/memory/`. Run `bash scripts/migrate.sh --apply` to move existing files into `.agents/` and keep continuity.
- Removed per-agent detection from the skills; continuity now belongs to the project, not the tool.
- `CHANGELOG.md` is now consistently at the project root across all skills.
- Slimmed `safe-code/SKILL.md` by moving doc/session templates into `skills/safe-code/references/`, loaded on demand per the Agent Skills spec.
- AGENTS.md authoring rules now have one canonical home (`references/agents-md-authoring.md`); helper skills defer to it.

**v2.9** — six-file project context + feature specs.

- Added `context/` project brain and `context/feature-specs/` build specs.
- Added local-only `context/current-issues.md` template and gitignore rule.
- `/safe-code` auto-resumes saved sessions when users forget `--continue`.
- Persistent context/doc updates are drafted during work and finalized on `/safe-code --save`.
- Old safe-code continuity docs migrate into new context files safely.

**v2.8** — explicit first-run, continue, and save commands.

**v2.7** — code-review-graph and helper-skill orchestration.

---

## New to skills?

Read the tutorial for step-by-step setup:
- [English tutorial](./TUTORIAL-EN.md)
- [Tutorial Bahasa Melayu](./TUTORIAL-BM.md)
