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
  `context/*.md`, and `context/feature-specs/` inside it (`CHANGELOG.md` and
  `ui-context.md` wait for the first releasable change / first UI work).
- Adds `/.safe-code/context/current-issues.md`, `/.safe-code/backups/`, and
  `/.safe-code/.last-save` to `.gitignore`.
- Reads README, manifests, configs — First-Run Population: writes evidence-derivable
  facts straight into `AGENTS.md` + the empty context scaffolds (`project-overview`,
  `architecture` + Navigation map, `code-standards`, `progress-tracker`), and drafts
  everything else in `SESSION.md`.
- Puts anything unverifiable into `progress-tracker.md` Open Questions.
- Being a setup run, still runs the findings-only dead-code scan (Step 4) and config
  trust audit (Step 4b): candidates are reported, nothing is removed.
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

**Situation:** the user ran `/safe-code --audit` (or asked to "clean up the repo"), so this is
an **audit run**; git is clean, commits exist (rollback available), `AGENTS.md` was
reconciled in an earlier run, and there are HIGH-confidence dead-code candidates. A plain
`/safe-code` on this repo would be a light run and never reach this step.

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
0. Legacy setup config found -> run Legacy Layout Migration first
1. Review SESSION.md drafts (## Drafts)
2. Apply approved updates to .safe-code/context/*.md and AGENTS.md
3. progress-tracker.md: safe summary; last_synced_commit = HEAD,
   context_synced_at = today
4. Update ALL SIX session files in .safe-code/ (Six-File Save Rule) —
   untracked or local-only brain -> back up each first:
   ACTIVE.md, SESSION.md (wiped), LOG.md (entry + plain: recap),
   BACKLOG.md, MEMORY.md, safe-refactor-code.md
   — files with no new content get a fresh date stamp;
   then touch .safe-code/.last-save (gitignored save stamp)
5. Update .safe-code/CHANGELOG.md ONLY for releasable changes
   (created on the first one)
6. Ensure a local git repo exists when allowed by current repo state
7. Split the session into atomic LOCAL commits (Atomic Commit Split Rule),
   staging only paths this run touched, each ending with the
   `Safe-Code: <version>` trailer: code/behavior tasks first, root
   scaffold as its own chore:/docs: group, then ONE final `docs:` commit
   for the .safe-code/ session files (none when the brain is local-only)
   — degrade to a single commit of this run's paths if the changes
   cannot be cleanly separated; verify all six session files are in the
   docs commit diff (local-only brain: fresh stamp on disk)
8. Retro -> `retro:` items in BACKLOG.md (nothing found, nothing written)
9. Save Bridge: diary_path declared and the file exists -> append one block
10. Report commit hashes + types + local-only status + paths left
    uncommitted (not this run's) + next action
```

Sample close-out:

```
=== safe-code v5.0 session complete ===
Run: audit · profile: Cleanup · mode: A
Save: local commits only; no push
Brain: 214 lines (budget 300)
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

## Example 5 — Light resume (`/safe-code` on a project with a brain)

**Situation:** the brain exists, the last save left `status: saved` with one pending item, and
the user types `/safe-code` with no sweep asked.

**Correct behavior:** a **light run** — resume and do the work; no dead-code audit, config
audit, or refactor sweep.

What the run does:

- Loads Layer 1, then Layer 2 (saved state), runs `codegraph sync` only if `.codegraph/`
  exists, and the Context Freshness Check (stamp vs `HEAD`).
- Probes the pending item (`git log` for its commit) — still open, so it stays.
- Writes the **Light checklist** into `SESSION.md`, then works `next_action`.
- Smoke-verifies with the `AGENTS.md ## Commands` test line and compares the count with its
  `known total`.

```
=== safe-code v5.0 session complete ===
Run: light · profile: n/a · mode: n/a   (hygiene pass skipped (light run; /safe-code --audit runs it))
Git: repo found | Remote: <URL> [Bucket A] | Save: local commit only; no push | Commits: pending — run /safe-code --save
Brain: 214 lines (budget 300)
Task list: 6/7 · Parked: none · Abandoned: none · Requested: 1/1 · Out-of-scope touches: none
Run /safe-code --save to commit and close this session.
```

The discipline: a light run skips the sweep, never the safety rules — git state, other
sessions, the identity guard before a commit, and verification of the user's work all run.

---

## Anti-patterns (do NOT do these)

- Marking a task `[x]` before its verification ran. Done means *verified*.
- Auto-promoting a MEDIUM candidate that has dynamic-dispatch/reflection risk.
- Deleting code with no rollback path (no git, or dirty tree) without approval.
- Writing real content into `.safe-code/context/*.md` mid-session instead of
  drafting in `SESSION.md` and applying on `--save` (exception: First-Run
  Population seeding empty scaffolds).
- Creating `.codex/`, `.claude/`, `.cursor/`, `.windsurf/`, or `.agents/` session-state
  folders — continuity lives in `.safe-code/` only (a provider-bridge pointer such as
  `CLAUDE.md` is a redirect, not state).
- Saving without touching all six session files — an untouched file means an
  incomplete save.
- Pushing to a remote. safe-code never pushes.
- Staging with `git add -A` / `git add .` at save time — another session's dirty files
  end up in your commit. Stage only the paths this run touched.
- Reverting or stashing a change you cannot explain. Label it `foreign`, leave it, and
  ask only if it blocks a task.
- Copying secrets, raw logs, or `current-issues.md` content into persistent docs.
