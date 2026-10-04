# safe-code reference: multi-session safety

> Loaded on demand (Layer 3) at Step 3a when another session may share this checkout,
> before `--save` stages anything while one might, and before any git command that rewrites
> the working tree or reads an old commit (Safety Invariants). The binding rules — `--save`
> stages only this run's paths (Atomic Commit Split Rule), unexplained changes are labelled
> `foreign` and never reverted (Step 8) — live inline in SKILL.md; this file holds the
> detection signals, the procedures, and the Shared-checkout rules themselves.

Two agent sessions in one checkout share one index, one working tree, and one `HEAD`. A
stash, reset, checkout, or `git add -A` by one silently takes or destroys the other's work.

## Detect other sessions (Step 3a)

Any one signal is enough to report:

1. **Agent processes in this checkout** — an agent CLI process whose working directory is
   this repo (process list + its cwd: `lsof -a -d cwd -p <pid>` on macOS/Linux, `/proc/<pid>/cwd`
   on Linux). Exclude this agent's own process tree first: the current shell (`$$`) and its
   parent chain (`ps -o ppid= -p <pid>` up to pid 1), and any subagent this run dispatched —
   the agent itself always has this repo as its cwd. Report process name and pid only — never
   print a process's arguments (they can carry tokens). Skip silently when the platform cannot
   answer.
2. **Other worktrees** — `git worktree list` shows more than this one (a
   `.safe-code/backups/wt-*` worktree this run created to read an old commit does not count). They share branches
   and the object store; a branch checked out there cannot be checked out here.
3. **Unexplained dirty files** — paths in `git status --porcelain` that no task in `SESSION.md`
   claims and safe-code did not write this run.
4. **Foreign commits** — commits in `<run_start>..HEAD` that this run did not make. At
   Step 3a record `HEAD` as `run_start: <sha>` in `SESSION.md`; re-check this signal before
   `--save` stages anything and at Step 8. Commits before `run_start` — including the user's
   ordinary commits between sessions — are history, not another session (the Context
   Freshness drift scan handles them).

Found -> one line in the Step 3c Reasoning block, `other sessions: <signals>`, and in the final
summary. Treat every path those signals name as **foreign**. For multi-step work, suggest a
separate worktree: `git worktree add ../<repo>-<task> -b <branch>`. Never kill, pause, or
message another process; never take over its files.

## Shared-checkout rules

The one home of these rules — SKILL.md's Safety Invariants and the helper skills point here.

- No `git stash` / `stash pop`, `reset --hard`, `checkout -- <file>`, `restore` of a file you
  did not change, or `clean -fd` in a shared checkout.
- To read an old commit: one file -> `git show <commit>:<path>` (no checkout at all).
  More than one file -> `git worktree add --detach .safe-code/backups/wt-<sha> <commit>`
  (gitignored and inside the project root — Scope Rule), read there, then
  `git worktree remove .safe-code/backups/wt-<sha>` — only the worktree you created.
- Do not switch branches in a checkout another session uses; it rewrites files under it.
- Subagents get these rules in their dispatch prompt — they apply to every command a
  subagent runs.

## Staging only this run's paths (`--save`, including the fallback)

1. Path set ("paths this run touched") = every `files:` annotation in `SESSION.md` —
   including tasks carried over from an earlier unsaved session, since their changes are
   still uncommitted and this save is what commits them — + files safe-code wrote this run
   (scaffold, bridges, `.gitignore`, `.codegraph/.gitignore` on its first appearance, and
   the `.safe-code/` session files unless the brain is local-only; never the gitignored
   `.last-save` stamp).
2. Stage per commit group with explicit paths: `git add -- <path> …`. Never `git add -A`,
   `git add .`, or `git commit -a`.
3. A file both this run and another session edited: stage this run's hunks with `git add -p`
   only when they are clearly separable; otherwise leave the file uncommitted and report it.
4. After the last commit, re-read `git status --porcelain`; every remaining path goes on the
   save report as `left uncommitted (not this run's): <paths>`.

## First-run WIP question (setup-adopt)

On a setup-adopt run, signal 3 (unexplained dirty files) is asked about once before the paths
are treated as foreign: `Are these uncommitted changes your work in progress? <paths>`. Yes ->
the user's active work (`SESSION.md` `user WIP: <paths>`, named in `ACTIVE.md next_action` on
`--save`; facts from them tagged `[inferred: uncommitted WIP]`), but still never staged, never
reverted, and not a sign of another session. No, no answer, or non-interactive -> foreign, as
below. Detail: `references/adopt.md` (The user's uncommitted work).

## Foreign changes (Step 8)

A change this run did not make is labelled `foreign` on the `Out-of-scope touches:` line. It
is never reverted, never staged, never "cleaned up" — another session or the user owns it.
Ask the user only when a foreign change blocks a task (it breaks the build you need green,
or edits the same lines). An unclaimed change this run *did* make is not foreign: it is an
out-of-scope touch to explain or claim with a task.

## Fresh worktree environment

A new worktree has none of the gitignored env files (`.env*`, local config) the main
checkout has. `AGENTS.md` lists which ones a fresh worktree needs (key names only, never
values — see `references/agents-md-authoring.md`). Red tests in a new worktree -> check
those files exist first (by shape — Safety Invariants), before any code hypothesis; missing
ones are reported to the user by name.
