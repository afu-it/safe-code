# safe-code

> **Three clear commands. Full repo hygiene.** First run, context-safe continue, and clean handoff.

[![version](https://img.shields.io/badge/version-2.8-teal?style=flat-square)](./skills/safe-code/SKILL.md)
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

## What It Does

You run one of three commands. The agent does everything else:

```
/safe-code
```

```
 Step 0  →  Detect active agent (Codex / Claude / Cursor / Windsurf)
 Step 1  →  Create 8 continuity docs + populate AGENTS.md with real project context
 Step 2  →  Load first-run context, or use --continue for saved session context
 Step 3  →  Check git state + detect remote platform + update graph when available
 Step 4  →  Audit codebase — find dead code candidates with graph + manual checks
 Step 5  →  Plan + pick execution mode (auto / ask / plan-only)
 Step 6  →  Remove dead code slice by slice, verify each one
 Step 7  →  Refactor affected code + auto-review changes + sync all docs
 Step 8  →  Print full session summary
```

Nothing is deleted without a rollback path. Nothing is pushed by safe-code.

safe-code follows a **measure twice, cut once** policy: every run keeps a visible task checklist in `SESSION.md`, verifies each meaningful step before marking it done, and moves unfinished work into `ACTIVE.md` on `/safe-code --save`.

---

## Three Commands. That's It.

| Command | What it does |
|---|---|
| `/safe-code` | First-time setup or fresh full hygiene pass |
| `/safe-code --continue` | Resume from continuity docs without hallucinating context |
| `/safe-code --save` | End the session: update docs, initialize local git if needed, commit locally, clear working memory |

### Saving a session does 11 things automatically:

```
1.  Migrate working notes  →  ACTIVE.md
2.  Update session state   →  ACTIVE.md (Last Session block)
3.  Append to diary        →  LOG.md
4.  Update architecture    →  MEMORY.md (if changed)
5.  Update release notes   →  CHANGELOG.md (if releasable)
6.  Trim old logs          →  LOG.md (archive if > 200 lines)
7.  Wipe working memory    →  SESSION.md (reset to blank)
8.  Ensure local git repo  →  git init if needed
9.  Stage all changes      →  git add -A
10. Commit locally         →  git commit -m "safe-code: YYYY-MM-DD - summary"
11. Report                 →  print commit hash + local-only status + session closed
```

---

## The 8 Continuity Docs

Every project gets these files, created once and kept in sync:

```
your-project/
├── AGENTS.md                    ← rules, stack, coding standards
├── CHANGELOG.md                 ← release history
└── .codex/agents/               ← (or .claude/ .cursor/ .windsurf/)
    ├── ACTIVE.md                ← current task + resume point  💾 hard disk
    ├── SESSION.md               ← working notes this session   🧠 RAM
    ├── LOG.md                   ← append-only typed diary
    ├── BACKLOG.md               ← task queue (High / Medium / Low)
    ├── MEMORY.md                ← architecture snapshot
    └── safe-refactor-code.md   ← refactor rules + flagged code
```

> **ACTIVE.md** persists across sessions (like a hard disk).
> **SESSION.md** is wiped on every `/safe-code --save` (like RAM).

### How AGENTS.md is maintained

On setup, safe-code **investigates the repo before deciding what to do with `AGENTS.md`**:

- Reads `README*`, manifests, lockfiles, CI workflows, existing instruction files
- Extracts only high-signal facts: exact commands, stack quirks, folder structure, conventions
- Creates or populates missing/thin files, and reconciles existing files in place
- Treats short generic files as thin even if they contain a few project-specific lines
- Treats an already populated file as `unchanged` only after auditing it against the current repo
- Every line must answer: *"Would an agent miss this without help?"* — if not, it's left out

---

## Eight Skills, One Ecosystem

```
          you
           │
           ▼
      /safe-code          ← first run / fresh pass
           │
     ┌─────┬──────┬──────────┬─────────┐
     ▼     ▼      ▼          ▼         ▼
 senior build  codebase    safe-    review-
 dev    graph   pruner   refactor  changes
                         code
     │      │              │
     ▼      ▼              ▼
 discipline explore      debug-
            codebase     issue

Step 3f  Step 4 & 6  Step 7  automatic review/debug support
```

| Skill | Role | You call it? |
|---|---|---|
| `safe-code` | Orchestrator — coordinates everything | ✅ Yes |
| `senior-dev` | Senior engineering discipline, task lists, adversarial strategy critique, clean repo policy | ❌ Auto-applied by safe-code and usable alone |
| `build-graph` | Builds or updates code-review graph | ❌ Called by safe-code |
| `explore-codebase` | Graph-backed repo orientation and AGENTS.md facts | ❌ Auto-called by safe-code |
| `codebase-pruner` | Finds + removes dead code | ❌ Called by safe-code |
| `safe-refactor-code` | Refactors with graph impact checks + syncs docs | ❌ Called by safe-code |
| `review-changes` | Delta/PR review with blast radius and tests | ❌ Auto-called after edits |
| `debug-issue` | Graph-assisted bug tracing | ❌ Auto-called on failures or bugs |

Helper skills are internal automation. Users only need `/safe-code`, `/safe-code --continue`, and `/safe-code --save`.

Graph support comes from `code-review-graph` when available. On first run, safe-code can auto-create a project-local `.mcp.json` that uses `uvx code-review-graph serve` when `uvx` is installed. It does not edit global agent config or run global installs.

If graph tools are unavailable, safe-code falls back to manual `rg`, manifest, config, and test-based analysis.

---

## How Dead Code Removal Works

The agent never deletes in bulk. It goes **one slice at a time**:

```
  Before executing, it prints a plan:

  Slice 1: src/utils/old-helper.js → parseDate()
    action : delete
    verify : grep -r "parseDate" . → expect 0 results

  Slice 2: src/api/legacy.js → LegacyRouter
    action : delete
    verify : npm test → expect all pass

  Then executes slice 1 → verifies → slice 2 → verifies → ...
  If any slice fails → rollback that slice only, continue the rest.
```

---

## Execution Modes

The agent picks the right mode automatically:

| Mode | When | What happens |
|---|---|---|
| **A — Auto** | Git clean, all high-confidence, no surprises | Runs fully on its own |
| **B — Ask** | Dirty worktree, borderline cases, large scope | Shows plan, waits for your approval |
| **C — Plan only** | No git, no rollback, or explicitly requested | Shows plan, does nothing |

---

## What's New

**v2.8** — safe-code now has explicit first-run, continue, and save commands.

- `/safe-code` is first-time setup or a fresh hygiene pass.
- `/safe-code --continue` forces context-safe resume from `AGENTS.md`, `ACTIVE.md`, `SESSION.md`, `LOG.md`, and memory files.
- `/safe-code --save` saves handoff state, commits locally, wipes session RAM, and closes the session.
- Deprecated forms `/safe-code save` and `/safe-code continue` now point to the flag commands.
- Every run now maintains a `SESSION.md` task checklist and migrates unfinished items to `ACTIVE.md` on save.

**v2.7** — safe-code now integrates code-review-graph workflows without making them mandatory.

- Added `senior-dev`, `build-graph`, `explore-codebase`, `review-changes`, and `debug-issue`.
- `codebase-pruner` now uses graph dead-code, callers/importers, and impact-radius evidence when available.
- `safe-refactor-code` now folds in graph-powered rename previews, affected flows, and post-change review.
- `/safe-code` now performs a graph readiness check before audit and falls back cleanly when graph tools are missing.
- `/safe-code` now auto-routes helper skills; users do not need to call helpers manually.

**v2.6** — `/safe-code --save` initializes or uses local git and commits locally only. It never pushes to a remote.

- `AGENTS.md` is audited every setup and only marked `unchanged` after checking it against current repo sources.
- Missing, thin, and populated files all follow the same compact, verified, high-signal authoring rules.
- `/safe-code` infers an internal profile: Orientation, Audit, or Cleanup. New/risky repos stay docs-and-audit only; stable repos with rollback can proceed to safe cleanup.
- Replaced by v2.8 command contract: `/safe-code`, `/safe-code --continue`, and `/safe-code --save`.

---

## New to skills?

Read the tutorial for a step-by-step setup guide:
- [English tutorial](./TUTORIAL-EN.md)
- [Tutorial Bahasa Melayu](./TUTORIAL-BM.md)
