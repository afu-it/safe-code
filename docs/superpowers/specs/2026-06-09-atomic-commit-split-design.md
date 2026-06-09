# Atomic Commit Split for `/safe-code --save`

- **Date:** 2026-06-09
- **Status:** approved (design)
- **Target:** `skills/safe-code/SKILL.md` v4.1 → v4.2
- **Origin:** Port the idea from the `bring-shrubbery/atomic-commits` Claude Code skill into safe-code, adapted to safe-code's safety model.

## Problem

`bring-shrubbery/atomic-commits` enforces "one logical change = one commit, committed as you go, with a conventional message." That granularity is valuable, but its *as-you-go auto-commit* behavior conflicts with safe-code's iron rule: **commits happen only at `/safe-code --save`, as a single local commit, never pushed.**

Today `/safe-code --save` step 7 stages everything and makes **one** commit that mixes dead-code removal, refactors, bug fixes, and the six session-file/context updates together. That commit is hard to review and hard to revert selectively.

## Goal

Keep safe-code's commit gate exactly as-is, but make the single save **produce several atomic conventional commits grouped by logical change** — degrading safely to today's single-commit behavior when a clean split isn't possible.

## Decisions (locked during brainstorming)

1. **Commit boundary — Approach A: split the `--save` commit.**
   The "commit only at `--save`, local-only, never push" gate is unchanged. Only the *structure* of that one save changes: N atomic commits instead of one blob.

2. **Grouping rule — by `SESSION.md` task list.**
   Each completed task/slice in the existing task checklist becomes one commit. The `.safe-code/` bookkeeping (six session files + `context/`) is always a final, separate `docs:` commit. Reuses structure safe-code already maintains.

3. **Fallback — degrade to a single commit.**
   When changes can't be cleanly split (overlapping hunks across tasks, thin/missing task list, inseparable changes), stage everything into **one** commit (today's behavior) and append a `LOG.md` note explaining why. **The save never fails or blocks because of commit-splitting.**

## The contract

| Frozen (the safety gate) | Upgraded |
|---|---|
| Commits happen only at `/safe-code --save` | The save produces N atomic commits instead of 1 |
| Local-only, never pushes | Messages adopt conventional `type: what` format |
| Save never fails / never blocks | Split is best-effort; degrades to 1 commit |
| `--save` is the single user-controlled trigger | Six session files become their own final `docs:` commit |

## Design

### A. Atomic Commit Split Rule (new subsection under `## Command: /safe-code --save`)

Replaces today's save-step 7 (`Stage changes and create local commit only`) with:

```
7. Atomic Commit Split (best-effort):
   a. Read SESSION.md completed tasks + each task's recorded touched paths.
   b. Order commits: code/behavior tasks first (in task order), then ONE final
      docs/chore commit for .safe-code/ bookkeeping.
   c. For each group: `git add <only that group's paths>` → commit with a
      conventional `type: subject` message derived from the task. Never --no-verify.
   d. The six session files + context/ updates are ALWAYS the last commit, never
      mixed with code (`docs: sync .safe-code session files`).
   e. Fallback: if hunks overlap across tasks, the task list is thin, or changes
      can't be cleanly separated → stage everything, make ONE commit (today's
      behavior), and append a LOG.md note: "atomic split skipped: <reason>".
8. Report: list of commit hashes + types, local-only status, next action.
```

**No re-verification between commits.** Changes were already verified per-slice during the run (Step 6 verifies after each slice). The split is a staging/commit operation over already-good changes, keeping the save cheap. If a task's changes genuinely can't stand alone, merge it with its dependency into one commit rather than emit a broken commit.

### B. Task-list annotation (file → task mapping)

In the **Measure Twice, Cut Once** section, the task-list rule gains: when a task is marked `[x]`, record the paths it touched and its commit type, *while the info is fresh during the run* — never reconstructed by guessing at save time.

```md
## Task List
- [x] remove unused dateUtil  · type: refactor · files: src/utils/dateUtil.ts
- [x] fix parser null deref    · type: fix      · files: src/parser.ts
- [x] cover parser edge case   · type: test     · files: tests/parser.test.ts
```

A missing annotation = "thin task list" = fallback to single commit.

### C. Conventional commit type mapping

| safe-code work | commit type |
|---|---|
| dead-code removal, rename, restructure (Step 6/7) | `refactor` |
| bug fix from `$debug-issue` / issue tracker | `fix` |
| new feature from a feature-spec | `feat` |
| test additions/changes | `test` |
| `.safe-code/` session files, context, CHANGELOG, AGENTS.md | `docs` |
| config/tooling/gitignore | `chore` |

## Concrete edit points in `SKILL.md`

1. **Frontmatter `description`** (line 3): `…then commits locally only — never pushes` → `…then creates atomic conventional commits locally only — never pushes`.
2. **`version`** (line 4): `"4.1"` → `"4.2"`.
3. **`## Command: /safe-code --save`** sequence (lines ~214–236): rewrite step 7 → the Atomic Commit Split Rule (§A); renumber report step.
4. **Measure Twice, Cut Once** (lines ~287–298): add the task annotation rule (§B).
5. **Step 8 Final Summary** (line ~1091 + body): bump banner to `v4.2`, add a `Commits:` line listing the atomic commits or the single-commit fallback reason.

Net: additive. No existing safety rule is removed — one new rule, one annotation, one version bump.

## Non-goals (YAGNI)

- No commit-as-you-go during the run (rejected: breaks the commit-only-on-save gate).
- No grouping-by-conventional-type or diff-heuristic grouping (rejected in favor of task-list grouping).
- No re-running tests between split commits at save time.
- No push behavior of any kind.

## Success criteria

- A `--save` with a clean, annotated task list produces multiple conventional commits, code first and a `docs:` bookkeeping commit last, all local-only.
- A `--save` with tangled/thin changes produces exactly one commit plus a `LOG.md` "atomic split skipped" note, identical to current behavior.
- No safe-code run ever pushes, and no save ever fails because of splitting.
