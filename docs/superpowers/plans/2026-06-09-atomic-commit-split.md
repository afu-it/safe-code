# Atomic Commit Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/safe-code --save` split one session into several atomic conventional commits (code first, a `docs:` bookkeeping commit last), grouped by the `SESSION.md` task list, degrading safely to today's single commit when a clean split isn't possible — all local-only, never pushed.

**Architecture:** Pure documentation edits to one skill file (`skills/safe-code/SKILL.md`). No code, no test runner. Each task applies an exact string `Edit` and verifies with `grep`. The behavior change is entirely in the instructions the skill gives the agent at `--save` time; the commit gate (only at `--save`, local-only, never push) is untouched.

**Tech Stack:** Markdown (Claude Code skill format), `git`, `grep`.

**Source spec:** `docs/superpowers/specs/2026-06-09-atomic-commit-split-design.md`

---

## File Structure

| File | Change | Responsibility |
|---|---|---|
| `skills/safe-code/SKILL.md` | Modify (5 regions) | Frontmatter version+description, `--save` save sequence, new Atomic Commit Split Rule, task-list annotation rule, Step 8 summary |

All edits are additive or in-place; no existing safety rule is removed. The file is large (~1130 lines) but edits are localized to 5 known regions.

**Pre-flight (run once before Task 1):**

Run: `grep -n 'version: "4.1"\|safe-code v4.1\|then commits locally only\|Stage changes and create local commit only' skills/safe-code/SKILL.md`
Expected: 4 matches (line ~3 description, line ~4 version, line ~234 save step 7, line ~1091 banner). Confirms anchors are present and unchanged before editing.

---

## Task 1: Frontmatter — version bump + description

**Files:**
- Modify: `skills/safe-code/SKILL.md:3-4`

- [ ] **Step 1: Update the description's commit phrasing**

Edit — replace exactly:

```
/safe-code --save updates all six session files, then commits locally only — never pushes.
```

with:

```
/safe-code --save updates all six session files, then creates atomic conventional commits locally only — never pushes.
```

- [ ] **Step 2: Bump the version**

Edit — replace exactly:

```
version: "4.1"
```

with:

```
version: "4.2"
```

- [ ] **Step 3: Verify both edits landed and old strings are gone**

Run: `grep -n 'version: "4.2"\|creates atomic conventional commits locally only' skills/safe-code/SKILL.md`
Expected: 2 matches.

Run: `grep -n 'version: "4.1"' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 2: `--save` sequence + new Atomic Commit Split Rule

**Files:**
- Modify: `skills/safe-code/SKILL.md` — save sequence block (~lines 233-234) and the area just after `Do not push.` (~line 236)

- [ ] **Step 1: Rewrite save steps 7–8 to point at the new rule**

Edit — replace exactly:

```
6. Ensure local git repo exists when allowed by current repo state
7. Stage changes and create local commit only
8. Report commit hash + local-only status + next action
```

with:

```
6. Ensure local git repo exists when allowed by current repo state
7. Split the session into atomic commits (Atomic Commit Split Rule below)
8. Report commit hashes + types + local-only status + next action
```

- [ ] **Step 2: Insert the Atomic Commit Split Rule subsection**

Edit — replace exactly:

```
Do not push.

### Six-File Save Rule
```

with (the literal block below, fences and tables included):

````
Do not push.

### Atomic Commit Split Rule

`/safe-code --save` turns the session's **one** save into **several atomic commits** grouped by logical change. The commit gate is unchanged: this still happens only at `--save`, stays **local-only, and never pushes**.

Split procedure (best-effort):

1. Read `SESSION.md` completed tasks and each task's recorded touched paths + commit type (Task Annotation, Measure Twice section).
2. Order commits: code/behavior tasks first in task order, then ONE final bookkeeping commit for the `.safe-code/` session files + `context/` updates.
3. For each group, stage only that group's paths (`git add <paths>`) and commit with a conventional `type: subject` message derived from the task. Never use `--no-verify`.
4. The six session files + `context/` updates are ALWAYS the last commit, never mixed with code: `docs: sync .safe-code session files`.
5. Do not re-run verification between commits — each task was already verified per-slice during the run (Step 6). The split is a staging/commit operation over already-good changes. If a task's changes cannot stand alone, merge it with its dependency into one commit rather than emit a broken commit.

Commit type mapping:

| Work | type |
|---|---|
| dead-code removal, rename, restructure (Step 6/7) | `refactor` |
| bug fix (`$debug-issue` / issue tracker) | `fix` |
| new feature from a feature spec | `feat` |
| test additions/changes | `test` |
| `.safe-code/` session files, `context/`, `CHANGELOG.md`, `AGENTS.md` | `docs` |
| config/tooling/`.gitignore` | `chore` |

Fallback (degrade to single commit):

```
if hunks overlap across tasks, the task list is thin/unannotated,
or changes cannot be cleanly separated:
  -> stage everything, make ONE local commit (today's behavior)
  -> append LOG.md note: "atomic split skipped: <reason>"
```

The save **never fails or blocks** because of splitting. Atomic splitting can only ever improve a save, never break one.

### Six-File Save Rule
````

- [ ] **Step 3: Verify the rule is present and the save step was rewritten**

Run: `grep -n '### Atomic Commit Split Rule\|Split the session into atomic commits\|atomic split skipped' skills/safe-code/SKILL.md`
Expected: 3 matches.

Run: `grep -n 'Stage changes and create local commit only' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

Run: `grep -c '### Six-File Save Rule' skills/safe-code/SKILL.md`
Expected: `1` (confirms the anchor wasn't duplicated).

---

## Task 3: Task-list annotation rule (Measure Twice section)

**Files:**
- Modify: `skills/safe-code/SKILL.md` — Measure Twice, Cut Once "Rules" list, just before `Default checklist:` (~line 299)

- [ ] **Step 1: Add the annotation rule + format**

Edit — replace exactly:

```
- If verification fails, keep the task `[~]` or `[ ]`, add the failure note, and route to `$debug-issue` when appropriate.

Default checklist:
```

with (literal block below):

````
- If verification fails, keep the task `[~]` or `[ ]`, add the failure note, and route to `$debug-issue` when appropriate.
- When marking a task `[x]`, annotate it with the paths it touched and its commit type, so `/safe-code --save` can map each task to one atomic commit (Atomic Commit Split Rule). Record paths while the info is fresh; never reconstruct at save time. A missing annotation is a thin task list — the split falls back to a single commit.

Task annotation format:

```md
- [x] remove unused dateUtil  · type: refactor · files: src/utils/dateUtil.ts
```

Default checklist:
````

- [ ] **Step 2: Verify the annotation rule landed**

Run: `grep -n 'annotate it with the paths it touched\|type: refactor · files:' skills/safe-code/SKILL.md`
Expected: 2 matches.

---

## Task 4: Step 8 Final Summary — banner + Commits line

**Files:**
- Modify: `skills/safe-code/SKILL.md` — Step 8 summary banner (~line 1091) and the Git/Remote/Save block (~lines 1100-1102)

- [ ] **Step 1: Bump the summary banner version**

Edit — replace exactly:

```
=== safe-code v4.1 session complete ===
```

with:

```
=== safe-code v4.2 session complete ===
```

- [ ] **Step 2: Add a Commits line to the summary**

Edit — replace exactly:

```
Remote: <URL | none>  [Bucket <A | B | C>]
Save:   local commit only; no push
```

with:

```
Remote: <URL | none>  [Bucket <A | B | C>]
Save:   local commit only; no push
Commits: <n atomic: type:subject, … | 1 (atomic split skipped: <reason>)>
```

- [ ] **Step 3: Verify summary edits landed and no stale version remains**

Run: `grep -n 'safe-code v4.2 session complete\|Commits: <n atomic' skills/safe-code/SKILL.md`
Expected: 2 matches.

Run: `grep -n 'v4.1' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 5: Whole-file consistency sweep

**Files:**
- Read-only: `skills/safe-code/SKILL.md`; awareness-only: `README.md`, `TUTORIAL-EN.md`, `TUTORIAL-BM.md`

- [ ] **Step 1: Confirm no stale 4.1 / old save phrasing anywhere in the skill**

Run: `grep -rn '4\.1\|then commits locally only — never pushes\|Stage changes and create local commit only' skills/safe-code/SKILL.md`
Expected: no output (exit 1). Every old anchor has been replaced.

- [ ] **Step 2: Confirm the new rule is internally referenced consistently**

Run: `grep -n 'Atomic Commit Split Rule' skills/safe-code/SKILL.md`
Expected: 3 matches — the `### Atomic Commit Split Rule` heading, the save-step-7 pointer, and the Task-3 annotation cross-reference.

- [ ] **Step 3: Surface (do NOT edit) out-of-scope version mentions for the user**

Run: `grep -rn 'v4\.1\|4\.1\|never pushes' README.md TUTORIAL-EN.md TUTORIAL-BM.md skills/safe-code/references/`
Expected: possibly some matches. These files are already mid-edit by the user and are **out of scope** for this plan (spec is SKILL.md-only). Report any hits as a follow-up note; do not modify them.

---

## Task 6: Commit (gated on user go-ahead)

**This repo commits only when the user asks, and the working tree is already dirty with unrelated in-flight edits. Do NOT auto-commit.**

- [ ] **Step 1: Ask the user whether to commit, and on which branch**

If yes, stage ONLY the skill file and the two new design docs — never the user's unrelated dirty files:

```bash
git checkout -b feat/atomic-commit-split
git add skills/safe-code/SKILL.md \
        docs/superpowers/specs/2026-06-09-atomic-commit-split-design.md \
        docs/superpowers/plans/2026-06-09-atomic-commit-split.md
git commit -m "feat: split /safe-code --save into atomic conventional commits (v4.2)"
```

Expected: one commit on a new branch; `git status` shows the user's original modified files (`README.md`, `TUTORIAL-*.md`, etc.) still unstaged and untouched.

---

## Self-Review

**1. Spec coverage** — every spec section maps to a task:

| Spec item | Task |
|---|---|
| §A Atomic Commit Split Rule (save step 7) | Task 2 |
| §B Task-list annotation (file→task mapping) | Task 3 |
| §C Conventional type mapping | Task 2 (table inside the rule) |
| Edit point 1 (description) | Task 1 |
| Edit point 2 (version) | Task 1 |
| Edit point 3 (save sequence) | Task 2 |
| Edit point 4 (Measure Twice annotation) | Task 3 |
| Edit point 5 (Step 8 summary banner + Commits line) | Task 4 |
| Fallback = single commit + LOG note | Task 2 (rule body) |
| Local-only / never push preserved | Task 2 (rule body); no push step anywhere |

No gaps.

**2. Placeholder scan** — no "TBD/TODO/implement later". The `<…>` tokens in the summary `Commits:` line and the fallback block are *intentional template placeholders inside the skill's own output format* (matching the file's existing `<…>` summary style), not plan placeholders.

**3. Type/string consistency** — the heading `### Atomic Commit Split Rule` is referenced verbatim from save step 7 ("Atomic Commit Split Rule below"), Task 3's annotation rule ("Atomic Commit Split Rule"), and the Self-Review. The `docs: sync .safe-code session files` message, the type set (`feat/fix/refactor/test/docs/chore`), and the "atomic split skipped" LOG phrasing are identical between the spec and Task 2. Verified consistent.
