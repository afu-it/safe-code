# safe-code reference: team mode

> Loaded on demand (Layer 3) when the run banner is computed and team mode is on, when the
> mode differs from the `.gitignore` state, or when `user-preferences.md` sets `team:`. One
> home of the detection, the committed vs per-developer split, and merge-friendly writing.

## Detection

1. **Local-only brain first** (SKILL.md, Local-Only Brain: `.safe-code/` or `.safe-code/context/`
   gitignored) -> team mode is irrelevant: nothing of the brain is committed. Stop here.
2. **Override** — `team: on` or `team: off` in `user-preferences.md` `## Team Mode` wins.
   `team: auto` (the default) or no line -> detect.
3. **Auto** — more than one **person** in the last 90 days. Count people, not addresses
   (`scripts/check.sh` implements exactly this; run it rather than re-deriving):
   - read `git log --since=90.days --use-mailmap --format='%aN%x09%aE'` (`.mailmap` is honoured);
   - bots never count: any address containing `[bot]`, and GitHub's `noreply` / `action` /
     `actions` `@github.com` service addresses;
   - identities sharing a normalized name (lowercase, letters and digits only), an email, or a
     GitHub noreply login (`123+login@users.noreply.github.com` -> `login`) are one person;
   - a person counts only with >= 3 commits and >= 5% of the window (the top author always
     counts); the rest are **minor identities** (a stray `user@Machine.local`, a one-off fix):
     reported, never counted. One developer with a work, a personal and a noreply address is
     one author.
   Still wrong for this repo -> the user sets `team: on|off`, or maps identities in `.mailmap`.

Banner: `Team: on (N authors, 90d)` / `Team: off (N author, 90d)`, plus `; M minor identities ignored` when any; with an override,
`Team: on (N authors, 90d; set by user-preferences.md)`. `scripts/check.sh` prints the same line.

## What is committed

| Shared (committed) | Per-developer (gitignored) |
|---|---|
| `AGENTS.md` + nested package `AGENTS.md` | `ACTIVE.md`, `SESSION.md`, `LOG.md`, `MEMORY.md`, `safe-refactor-code.md` |
| `.safe-code/context/` (overview, architecture, standards, workflow, progress, `feature-specs/`) | `.last-save`, `backups/` |
| `.safe-code/BACKLOG.md`, `.safe-code/CHANGELOG.md` | `context/current-issues.md` (always local) |
| `context/user-preferences.md` (shared preferences, `team:`) | `context/user-preferences.local.md` (personal overrides) |

The `.gitignore` lines (print them; add them only with the user's approval):

```gitignore
# safe-code team mode: per-developer session files
/.safe-code/ACTIVE.md
/.safe-code/SESSION.md
/.safe-code/LOG.md
/.safe-code/MEMORY.md
/.safe-code/safe-refactor-code.md
/.safe-code/.last-save
/.safe-code/backups/
/.safe-code/context/current-issues.md
/.safe-code/context/user-preferences.local.md
```

## Switching modes

- Mode differs from the `.gitignore` state -> report it, print the lines, ask once. Approved ->
  add them at `--save` in the scaffold commit (`chore: gitignore per-developer safe-code files`).
  Declined -> record `team: off` (or `on`) in `user-preferences.md`; do not ask again.
- Per-developer files already tracked -> print `git rm --cached <each file>` for the user.
  **Never run it** — until they do, the ignore lines change nothing.
- Team -> solo: print the lines to remove; touch nothing else.

## First setup commit on an existing repo (setup-adopt)

In team mode, the first setup commit is a team-visible change: before it, print the
`safe-code/adopt` branch suggestion (`references/adopt.md`, Branch); the user opens the PR.
Agreed -> commit on that branch. Declined or no answer -> nothing is committed on the default
branch; the files stay on disk and the report says `left uncommitted (team mode, default branch)`.
Never push.

## Six-File Save Rule in team mode

All six session files are still written on disk at every save, stamps included; only what is
committed changes. Verify the ignored ones by their fresh stamp on disk (as for a local-only
brain) and back each up to `.safe-code/backups/` before rewriting it (untracked files have no
commit to revert to). The bookkeeping commit carries `BACKLOG.md` + `context/` only. The
session hook treats an uncommitted change to the shared part as unsaved work.

## Per-developer preferences

`## Git Identity` and the absolute `diary_path` in `## Save Bridge` are one developer's
values. In team mode they live in `.safe-code/context/user-preferences.local.md` (template:
`references/doc-templates.md`; gitignored), and a value there overrides the same field in the
shared `user-preferences.md`. Step 3e and the Save Bridge read the local file first.

- Never commit a personal value to the shared `user-preferences.md` in team mode: leave `-`
  there. A drafted `## Git Identity` or `diary_path` goes to the local file at `--save`.
- Shared file already holds a personal value -> report it and offer to move it to the local
  file (draft-until-save); `scripts/check.sh` warns about it.
- `team:` is team-wide: it is read from `user-preferences.md` only, never from the local file.

## Merge-friendly context

- One fact per line, so two branches touch different lines.
- Append-only where possible: Completed, Architecture Decisions, Confirmed Decisions, Open
  Questions, BACKLOG items — add new lines at the end of the section; never reorder, rewrap,
  or renumber existing ones.
- Edit a line in place only to correct it; pruning (Brain Budget) removes whole lines — the
  saver's `LOG.md` `pruned:` field and the shared commit both record them.
- Date entries (`<YYYY-MM-DD> — …`) instead of shared counters. Feature spec numbers: take
  the next free number when writing; a merge collision renumbers the later spec.
- `last_synced_commit` conflict on merge -> keep the **older** stamp; the Context Freshness
  Check then re-verifies the extra commits.
