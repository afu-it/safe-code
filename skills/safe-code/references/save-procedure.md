# safe-code reference: --save procedure detail

> Loaded (Layer 3) on `/safe-code --save` only. The binding rules — Six-File Save Rule,
> Draft-Until-Save, local-commit-only, never push, stage only this run's paths, Local-Only
> Brain — live inline in SKILL.md; this file holds the procedures and exact shapes. The Step 8
> banner lives in `references/final-banner.md`.

## Writing the session files safely

- Never write a file in the same shell expression that reads it (`sort f > f`,
  `cat f | sed … > f` truncate it to nothing before the read). Write a temp file, then `mv` it.
- **Backup + line-count check** whenever `.safe-code/` is untracked or gitignored (no commit
  to fall back on):
  1. Before writing, copy each session file: `cp -p .safe-code/<file> .safe-code/backups/<file>.<YYYYMMDD-HHMM>`
     (`backups/` is gitignored), and note its line count.
  2. After writing, re-count. A file that shrank by more than 50% without a task that explains
     it (a LOG trim) -> stop the save, restore that file from its backup, and report the shrink.
     `SESSION.md`'s wipe to the carry-forward template (`references/doc-templates.md`, SESSION.md
     carry-forward) is the expected shrink, not a failure.
  3. A session file already lost before this save (ignored, never committed): print a
     recovery step for the user — the host's own transcript store of earlier sessions may
     still hold the content. Never read outside the project root yourself (Scope Rule).
- After the six files are written, touch `.safe-code/.last-save` (empty file). Its mtime is
  the save stamp the SessionStart save-reminder compares `SESSION.md` against. It is always
  gitignored (`/.safe-code/.last-save`, added at setup) and never staged: git keeps no
  mtimes, so a committed stamp would carry nothing.

## Local-only brain, or nothing committed

Detection: SKILL.md, Local-Only Brain (the one home). The save writes all six files with the
backup + line-count check above, commits code and scaffold only (no `docs: sync .safe-code
session files` commit), and does the Six-File check on disk (each file carries this save's
date stamp) instead of in a commit diff. The same on-disk check applies to team-mode
per-developer files and to a save that commits nothing (team adopt on the default branch,
branch declined — `references/adopt.md`).

## Atomic Commit Split — procedure

Split procedure (best-effort):

1. Read `SESSION.md` completed tasks and each task's recorded touched paths + commit type (SKILL.md, Measure Twice, Cut Once Policy; annotation format in `references/verification.md`, Task Checks).
2. Order commits: code/behavior tasks first in task order, then ONE final bookkeeping commit for the `.safe-code/` session files + `context/` updates.
3. For each group, stage only that group's paths by explicit path (`git add -- <paths>`) and commit with a conventional `type: subject` message derived from the task, ending with the trailer `Safe-Code: <version>` (`git commit -m "<type: subject>" -m "Safe-Code: <version>"`) — the Context Freshness Check ignores exactly those commits. Never use `--no-verify`, `git add -A`, `git add .`, or `commit -a`; only paths this run touched are ever staged (`references/multi-session.md`, Staging only this run's paths).
4. The six session files + `context/` updates are ALWAYS the last commit, never mixed with code: `docs: sync .safe-code session files`. Local-only brain -> no such commit.
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

Root scaffold artifacts from a first run (`AGENTS.md`, the provider bridge, `.gitignore`, `.codegraph/.gitignore` on its first appearance) form their own group(s) by commit type per the table above (`docs` / `chore`), committed before the final session-files commit — never mixed into it.

Fallback (degrade to single commit):

```
if hunks overlap across tasks, the task list is thin/unannotated,
or changes cannot be cleanly separated:
  -> stage every path this run touched (never other sessions' dirty paths),
     make ONE local commit (still with the `Safe-Code: <version>` trailer)
  -> append LOG.md note: "atomic split skipped: <reason>"
  -> list remaining dirty paths as "left uncommitted (not this run's)"
```

## Last Session block shapes

Written into `ACTIVE.md` by `/safe-code --save`:

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

`pending:` carries every unfinished task as written — `[ ]`, `[~]`, `[p] … parked: needs
approval (…)`, `[!] … abandoned: …` — so the next session sees which wait on the user. A
parked Mode B plan drafted in `SESSION.md ## Drafts` is applied now: its task line to
`pending`, its plan to `BACKLOG.md`.

After all pending done, reset to:

```md
## Last Session
status: completed
saved_at: <ISO timestamp>
completed: all
pending: []
next_action: none
```

## LOG.md Trim Rule — procedure

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

## Session Scope Rule + Session-File Discipline

A save records only what changed or was learned *this session*. Update the project brain
only where session evidence contradicts or extends it — never re-summarize the whole
project into session files or regenerate context wholesale. What earns an entry:

| Event | Goes to |
|---|---|
| Architectural/design decision made | `progress-tracker.md` Architecture Decisions |
| Current focus changes | `ACTIVE.md` Current |
| Task completed + verified | `SESSION.md` `[x]`; typed `LOG.md` entry on save |
| Unrelated/deferred work discovered | `BACKLOG.md` |
| Durable lesson, workaround, audit note | `MEMORY.md` |
| New feature idea | `feature-specs/` as `status: suggested` |
| User states a durable preference | `user-preferences.md` |
| Context fact goes stale or is superseded | pruned from its file -> one `pruned:` line in the save's LOG entry (Brain Budget, `references/agents-md-authoring.md`) |
| Command runs green | `AGENTS.md ## Commands` re-stamped (`verified: <short-sha> · <date>`, tests `known total: N`) |

Do NOT log typos, renames, formatting, intermediate saves, or transient retries; batch related
small changes. Test: "would this be useful in a retrospective or handoff?" When quoting long
output, keep head + tail with `…[elided ~N lines — do not infer content]…` between.

## Draft-Until-Save Sync Table

During work, draft updates in `SESSION.md`. Apply them to persistent docs only on `/safe-code --save`, except scaffold files and active feature specs.

| File | Draft during work | Apply on `/safe-code --save` |
|---|---|---|
| `AGENTS.md` | Missing/stale Read First rules, commands, project facts | Yes |
| `.safe-code/context/project-overview.md` | Evidence-backed product/project facts | Yes |
| `.safe-code/context/architecture.md` | Evidence-backed stack, boundaries, invariants | Yes |
| `.safe-code/context/user-preferences.md` | User-approved preferences, hard dislikes, recurring instructions | Yes |
| `.safe-code/context/user-preferences.local.md` | Personal `## Git Identity` / `diary_path` (team mode: never the shared file) | Yes — on disk only, gitignored, never committed |
| `.safe-code/context/code-standards.md` | Verified conventions | Yes |
| `.safe-code/context/ai-workflow-rules.md` | Workflow rules discovered from repo/team docs | Yes |
| `.safe-code/context/ui-context.md` | UI tokens/components only when UI work occurs (file created then) | Yes |
| `.safe-code/context/progress-tracker.md` | Current phase, completed work, decisions, safe notes | Yes |
| `.safe-code/context/current-issues.md` | Append/update issue entries on error triggers (local-only, gitignored) | No — written live, never via save |
| `.safe-code/context/feature-specs/*.md` | Active spec before implementation; `status: suggested` spec for new ideas | Write immediately when needed |
| `.safe-code/CHANGELOG.md` | Releasable changes (file created on the first one) | Yes |
| `ACTIVE.md` | Last Session, pending checklist, next_action | Yes |
| `SESSION.md` | Live task list, temp decisions, draft doc updates (`## Drafts`) | Live during work; wipe on save |
| `LOG.md` | Safe typed summary only | Yes |
| `MEMORY.md` | Audit/refactor notes not canonical context | Always (Six-File Save Rule; stamp refresh if no content) |
| `safe-refactor-code.md` | Flagged candidates and guardrails | Always (Six-File Save Rule; stamp refresh if no content) |
| `BACKLOG.md` | Operational follow-ups | Always (Six-File Save Rule; stamp refresh if no content) |

---

## Retro categories

Ordered by severity; each finding becomes one `retro: <category> — <one line>` item in `BACKLOG.md`:

| Category | Signal in the run | Where the fix goes |
|---|---|---|
| navigation | a file was hard to find | a Navigation-map pointer in `architecture.md` |
| automated checks | a lint/type/test could have caught this mistake | propose the check |
| coding standards | the reviewer needed a rule that does not exist | a new rule in `code-standards.md` |
| AGENTS.md bloat | steering that belongs in standards or checks | move it out of `AGENTS.md` |
| tool economy | expensive or token-wasteful tool calls | a cheaper command or a recorded shortcut |
| no-ops | steering lines that changed no behaviour | delete them |
| information access | a fact the agent could not reach | record where it lives, or an Open Question |

Principle: the review step enforces standards, because the implementing agent carries all the context pressure. A clean run writes nothing.

## Graveyard — filling hashes

- Entry shape (one line in `safe-refactor-code.md ## Graveyard`):
  `- <date> · <path> (<whole file | symbol>) · why: <reason> · evidence: <scan + positive control> · restore: <git revert <hash> | .safe-code/backups/<file>.<stamp>>`
- The `<hash>` is filled during `--save`: code commits are created before the final docs
  commit (Atomic Commit Split), so the removal's real hash exists by the time
  `safe-refactor-code.md` is written.
- Untracked or gitignored files (and a local-only brain) have no commit to revert to — the
  `restore:` points at the `.safe-code/backups/` copy taken before the rewrite (`cp -p`).
- Entries are **never deleted**. When the list grows long, compress old entries LOG-trim
  style, keeping path + restore pointer for each.
- A removed shipped feature also flips its spec to `status: removed (<date>)` with the same
  restore pointer; the spec file stays.

## Save Bridge — procedure

Runs after the last commit of the Atomic Commit Split (so the hashes are real). Block shape:

```
## <YYYY-MM-DD HH:MM> — <project name> — safe-code save
- plain: <the LOG.md plain: recap, verbatim>
- commits: <hash type: subject>, …
- next: <ACTIVE.md next_action>
```

1. Read `diary_path` from `## Save Bridge` in `.safe-code/context/user-preferences.local.md` when that file sets it (per-developer, gitignored; it wins), else from `user-preferences.md`. `-`, empty, or missing -> skip silently (print nothing; only a declared-but-absent file earns the `skipped` line).
2. Existence check only (`[ -f "$diary_path" ]`). Missing -> report `Save bridge: skipped (file not found)`; never create it.
3. Append the block (shape above) with a trailing blank line. Use the same `plain:` line already written to `LOG.md`; do not compose a second summary.
4. Report `Save bridge: appended -> <diary_path>` in the save output. A bridge failure never fails the save: the commits are already done.
