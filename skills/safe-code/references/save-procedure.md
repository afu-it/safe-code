# safe-code reference: --save procedure detail

> Loaded on demand by `/safe-code --save` (Layer 3). The binding rules — Six-File Save
> Rule, Draft-Until-Save, local-commit-only, never push — live inline in SKILL.md; this
> file holds the mechanical procedures and exact shapes.

## Atomic Commit Split — procedure

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

Root scaffold artifacts from a first run (`AGENTS.md`, the provider bridge, `.gitignore`, `.mcp.json`) form their own group(s) by commit type per the table above (`docs` / `chore`), committed before the final session-files commit — never mixed into it.

Fallback (degrade to single commit):

```
if hunks overlap across tasks, the task list is thin/unannotated,
or changes cannot be cleanly separated:
  -> stage everything, make ONE local commit (today's behavior)
  -> append LOG.md note: "atomic split skipped: <reason>"
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

## Session Scope Rule

A save records only what changed or was learned *this session*. Update the project brain
only where session evidence contradicts or extends it — never re-summarize the whole
project into session files or regenerate context wholesale. (What earns an entry, and the
do-not-log noise filter, live in `doc-templates.md` Session-File Discipline.)

## Draft-Until-Save Sync Table

During work, draft updates in `SESSION.md`. Apply them to persistent docs only on `/safe-code --save`, except scaffold files and active feature specs.

| File | Draft during work | Apply on `/safe-code --save` |
|---|---|---|
| `AGENTS.md` | Missing/stale Read First rules, commands, project facts | Yes |
| `.safe-code/context/project-overview.md` | Evidence-backed product/project facts | Yes |
| `.safe-code/context/architecture.md` | Evidence-backed stack, boundaries, invariants | Yes |
| `.safe-code/context/user-preferences.md` | User-approved preferences, hard dislikes, recurring instructions | Yes |
| `.safe-code/context/code-standards.md` | Verified conventions | Yes |
| `.safe-code/context/ai-workflow-rules.md` | Workflow rules discovered from repo/team docs | Yes |
| `.safe-code/context/ui-context.md` | UI tokens/components only when UI work occurs | Yes |
| `.safe-code/context/progress-tracker.md` | Current phase, completed work, decisions, safe notes | Yes |
| `.safe-code/context/current-issues.md` | Append/update issue entries on error triggers (local-only, gitignored) | No — written live, never via save |
| `.safe-code/context/feature-specs/*.md` | Active spec before implementation; `status: suggested` spec for new ideas | Write immediately when needed |
| `.safe-code/CHANGELOG.md` | Releasable changes | Yes |
| `ACTIVE.md` | Last Session, pending checklist, next_action | Yes |
| `SESSION.md` | Live task list, temp decisions, draft doc updates | Live during work; wipe on save |
| `LOG.md` | Safe typed summary only | Yes |
| `MEMORY.md` | Audit/refactor notes not canonical context | Always (Six-File Save Rule; stamp refresh if no content) |
| `safe-refactor-code.md` | Flagged candidates and guardrails | Always (Six-File Save Rule; stamp refresh if no content) |
| `BACKLOG.md` | Operational follow-ups | Always (Six-File Save Rule; stamp refresh if no content) |
