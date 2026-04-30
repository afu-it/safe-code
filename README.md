# safe-code

> **One command. Full repo hygiene.** Dead code removed, refactored, docs synced — all in one autonomous pass.

[![version](https://img.shields.io/badge/version-2.5.1-teal?style=flat-square)](./skills/safe-code/SKILL.md)
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

You run one command. The agent does everything else:

```
/safe-code
```

```
 Step 0  →  Detect active agent (Codex / Claude / Cursor / Windsurf)
 Step 1  →  Create 8 continuity docs + populate AGENTS.md with real project context
 Step 2  →  Load context, auto-resume saved session if found
 Step 3  →  Check git state + detect remote platform
 Step 4  →  Audit codebase — find dead code candidates
 Step 5  →  Plan + pick execution mode (auto / ask / plan-only)
 Step 6  →  Remove dead code slice by slice, verify each one
 Step 7  →  Refactor affected code + sync all docs
 Step 8  →  Print full session summary
```

Nothing is deleted without a rollback path. Nothing is pushed without your command.

---

## Two Commands. That's It.

| Command | What it does |
|---|---|
| `/safe-code` | Start a full hygiene pass — or resume from where you left off |
| `/safe-code save` | Checkpoint: update docs, commit, push, clear working memory |

### Saving a session does 11 things automatically:

```
1.  Migrate working notes  →  ACTIVE.md
2.  Update session state   →  ACTIVE.md (Last Session block)
3.  Append to diary        →  LOG.md
4.  Update architecture    →  MEMORY.md (if changed)
5.  Update release notes   →  CHANGELOG.md (if releasable)
6.  Trim old logs          →  LOG.md (archive if > 200 lines)
7.  Wipe working memory    →  SESSION.md (reset to blank)
8.  Stage all changes      →  git add -A
9.  Commit                 →  git commit -m "safe-code: YYYY-MM-DD - summary"
10. Push                   →  git push (auto-detect platform)
11. Report                 →  print commit hash + push status
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
> **SESSION.md** is wiped on every `/safe-code save` (like RAM).  

### How AGENTS.md is maintained

On setup, safe-code **investigates the repo before deciding what to do with `AGENTS.md`**:

- Reads `README*`, manifests, lockfiles, CI workflows, existing instruction files
- Extracts only high-signal facts: exact commands, stack quirks, folder structure, conventions
- Creates or populates missing/thin files, and reconciles existing files in place
- Treats short generic files as thin even if they contain a few project-specific lines
- Treats an already populated file as `unchanged` only after auditing it against the current repo
- Every line must answer: *"Would an agent miss this without help?"* — if not, it's left out

---

## Three Skills, One Ecosystem

```
          you
           │
           ▼
      /safe-code          ← you only talk to this one
           │
     ┌─────┴──────┐
     ▼            ▼
codebase-      safe-
 pruner      refactor-
             code

Step 4 & 6  Step 7
```

| Skill | Role | You call it? |
|---|---|---|
| `safe-code` | Orchestrator — coordinates everything | ✅ Yes |
| `codebase-pruner` | Finds + removes dead code | ❌ Called by safe-code |
| `safe-refactor-code` | Refactors + syncs all docs | ❌ Called by safe-code |

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

**v2.5.1** — short or generic `AGENTS.md` files are now treated as thin and must be upgraded to a complete compact handoff, not patched with a one-line note.

- `AGENTS.md` is audited every setup and only marked `unchanged` after checking it against current repo sources.
- Missing, thin, and populated files all follow the same compact, verified, high-signal authoring rules.
- `/safe-code` infers an internal profile: Orientation, Audit, or Cleanup. New/risky repos stay docs-and-audit only; stable repos with rollback can proceed to safe cleanup.
- Still only two commands: `/safe-code` and `/safe-code save`.

---

## New to skills?

Read the tutorial for a step-by-step setup guide:
- [English tutorial](./TUTORIAL-EN.md)
- [Tutorial Bahasa Melayu](./TUTORIAL-BM.md)
