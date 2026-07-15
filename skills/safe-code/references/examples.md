# safe-code reference: worked examples

> Loaded on demand. These are concrete, end-to-end illustrations of what a good
> `/safe-code` run looks like. Use them to match the *shape* of a run — the
> reasoning blocks, the task-list discipline, the draft-until-save rule, and the
> profile/mode decisions. They are examples, not templates to copy verbatim.

Each example shows the kind of output and file state a correct run produces. Real
runs vary with the repo, but the discipline shown here should not.

---

## Example 1 — Orientation profile (fresh/empty repo)

**Situation:** new repo, no commits, thin or missing `AGENTS.md`, no `.safe-code/`.

**Correct behavior:** scaffold docs, write only evidence-backed facts, touch no code.

```
Reasoning:
  AGENTS.md: missing
  Rollback: no (0 commits)
  Worktree: untracked-heavy
  User intent: orientation
  Profile: Orientation
  Why: nothing to clean yet; establish the project brain first
```

What the run does:

- Creates `AGENTS.md` and the single `.safe-code/` folder: six session files,
  `CHANGELOG.md`, `context/*.md`, and `context/feature-specs/` inside it.
- Adds `/.safe-code/context/current-issues.md` to `.gitignore`.
- Reads README, manifests, configs — First-Run Population: writes evidence-derivable
  facts straight into `AGENTS.md` + the empty context scaffolds (`project-overview`,
  `architecture` + Navigation map, `code-standards`, `progress-tracker`), and drafts
  everything else in `SESSION.md`.
- Puts anything unverifiable into `progress-tracker.md` Open Questions.
- Removes/refactors nothing. Execution mode is **C — Plan only**.

Good `SESSION.md` task list at this point:

```md
## Task List
- [x] Locate project root and .safe-code/ folder
- [x] Initialize AGENTS.md, context, and session docs
- [~] Explore repo facts before context backfill
- [ ] Draft docs/context updates in SESSION.md
- [ ] Save final docs/context updates on /safe-code --save
```

Note: setup tasks are `[x]` only after they actually completed; the active task
is `[~]`; nothing is marked done speculatively.

---

## Example 2 — Audit profile (risky/dirty repo)

**Situation:** repo has code and commits, but the worktree is dirty or there is no
clean rollback path, and the user asked to "check for dead code."

**Correct behavior:** scan and flag, change nothing.

```
Reasoning:
  AGENTS.md: reconciled
  Rollback: no (worktree dirty, uncommitted changes present)
  Worktree: dirty
  User intent: audit
  Profile: Audit
  Why: no clean rollback, so flag candidates instead of deleting
```

Sample audit output (from `$codebase-pruner` in Audit mode):

```
Entrypoints mapped: 6
Files scanned: 142

Dead code inventory:
[HIGH] Orphaned module: src/legacy/old-uploader.ts - no live imports or config refs
[HIGH] Dead function: src/utils/format.ts:legacyDate - 0 callers
[MEDIUM] Suspected dead: src/handlers/webhook-v1.ts:handle - dynamic dispatch risk
[LOW] Stale env var: OLD_S3_BUCKET - not read in scanned files

Total confirmed dead: 2 | suspected: 1 | low: 1
Recommended next step: commit current work, then Dry-Run
```

What the run does:

- Drafts the inventory into `SESSION.md` for `safe-refactor-code.md`.
- Deletes nothing — execution mode stays **C**.
- Tells the user the blocker (dirty worktree / no rollback) and the safe next step.

The discipline: a MEDIUM candidate with dynamic-dispatch risk is **flagged, never
auto-promoted**, because it fails the auto-promotion test (not provably dead).

---

## Example 3 — Cleanup profile (clean repo, slice-by-slice)

**Situation:** git is clean, commits exist (rollback available), `AGENTS.md` is
reconciled, and there are HIGH-confidence dead-code candidates.

**Correct behavior:** execute one reversible slice at a time, verify each.

```
Reasoning:
  AGENTS.md: unchanged
  Rollback: yes
  Worktree: clean
  High candidates: 2
  Pre-Plan flags: none
  Decision: A
  Why: clean tree + rollback + all High + no surprises -> auto-execute
```

Execution plan printed before starting:

```
Slice 1: src/utils/format.ts:legacyDate
  action: delete
  verify: rg "legacyDate" src -> expect: zero results, then `npm run lint`

Slice 2: src/legacy/old-uploader.ts
  action: delete
  verify: import scan + `npm test` -> expect: tests pass
```

Slice-by-slice execution (never batched):

```
Slice 1 complete: removed legacyDate from src/utils/format.ts
  verify: rg clean, lint passed
Slice 2 complete: removed src/legacy/old-uploader.ts
  verify: import scan clean, 142 tests passed
```

The discipline: if Slice 1's verification had failed, the run rolls back **only
that slice**, marks the task `[~]`, records the failure, and routes to
`$debug-issue` — it does not proceed to Slice 2.

---

## Example 4 — `/safe-code --save` (finalize + local commit)

**Situation:** work is done for the session; time to persist and close.

What `--save` does, in order:

```
1. Review SESSION.md draft updates
2. Apply approved updates to .safe-code/context/*.md and AGENTS.md
3. Update progress-tracker.md (safe summary only)
4. Update ALL SIX session files in .safe-code/ (Six-File Save Rule):
   ACTIVE.md, SESSION.md (wiped), LOG.md (entry appended),
   BACKLOG.md, MEMORY.md, safe-refactor-code.md
   — files with no new content get a fresh date stamp
5. Update .safe-code/CHANGELOG.md ONLY for releasable changes
6. Ensure a local git repo exists
7. Split the session into atomic LOCAL commits (Atomic Commit Split Rule):
   code/behavior tasks first, then ONE final `docs:` commit for the
   .safe-code/ session files — degrade to a single commit if the
   changes cannot be cleanly separated
8. Verify all six session files appear in the final docs commit diff
9. Report commit hashes + types + local-only status + next action
```

Sample close-out:

```
=== safe-code v4.6 session complete ===
Save: local commits only; no push
Commits: 2 atomic — refactor: remove dead legacyDate + old-uploader · docs: sync .safe-code session files
Six-file save: ACTIVE ✓ SESSION ✓ LOG ✓ BACKLOG ✓ MEMORY ✓ safe-refactor-code ✓
LOG entry plain: "Removed 2 unused files/functions; all tests pass."
Removed: src/utils/format.ts:legacyDate, src/legacy/old-uploader.ts
Task list: 12/12 complete; unfinished: none
Next /safe-code --continue: resume from "wire new uploader into routes"
```

The two rules that always hold:

- **Nothing is pushed.** `--save` commits locally only, even when a remote exists.
- **`current-issues.md` is never committed.** The agent writes it only to append or
  update issue entries on an error trigger (Issue Tracking Rule) — and never copies
  its raw content into any committed file.

What the resume looks like next session:

```
you> /safe-code
it > Saved safe-code session found; resuming automatically.
     Pending: wire new uploader into routes | Next: that task
```

---

## Anti-patterns (do NOT do these)

- Marking a task `[x]` before its verification ran. Done means *verified*.
- Auto-promoting a MEDIUM candidate that has dynamic-dispatch/reflection risk.
- Deleting code with no rollback path (no git, or dirty tree) without approval.
- Writing real content into `.safe-code/context/*.md` mid-session instead of
  drafting in `SESSION.md` and applying on `--save` (exception: First-Run
  Population seeding empty scaffolds).
- Creating `.codex/`, `.claude/`, `.cursor/`, `.windsurf/`, or `.agents/` session-state
  folders — continuity lives in `.safe-code/` only (provider-bridge pointers like
  `.cursor/rules/safe-code.mdc` are redirects, not state).
- Saving without touching all six session files — an untouched file means an
  incomplete save.
- Pushing to a remote. safe-code never pushes.
- Copying secrets, raw logs, or `current-issues.md` content into persistent docs.
