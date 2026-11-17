# safe-code reference: deep read (Read-Before-Touch + module notes)

> Loaded (Layer 3) before the first code edit of a run, and when module notes are written or
> refreshed (setup, `--save`). The binding rule — read before touching, record what was read —
> lives in SKILL.md (Read-Before-Touch Rule); this file holds the read set, the note shape, and
> the freshness procedure.

The aim is a senior engineer's working habit: a map of the whole project, a written note per
area, and a full read of anything about to change. It is not "every line memorised": the notes
say where to look and what to expect, the code read this session says what is true
(Verify-First).

## Part 1 — Read-Before-Touch

Before the first edit to a file in a run, read:

| What | How |
|---|---|
| The file | All of it. Over ~800 lines: its outline (`codegraph node -f <file> --symbols-only`, or the symbol list by `rg`) plus every unit being changed and the units those call, in full |
| Who uses what changes | `codegraph callers <symbol>` and `codegraph impact <symbol>` for each changed function, type, route, or export, confirmed with `rg`; no graph -> `rg` alone, with a positive control (`references/verification.md`, Scan Proof) |
| What it relies on | The definitions of the functions and types the changed lines call, when their behaviour matters to the change |
| Its tests | `codegraph affected <file>`, or the test files that import it; read the cases that exercise the changed unit |
| Its module note | `.safe-code/context/modules/<module>.md` when one exists — a lead, read first, never instead of the code |

Then record on the task, before editing:
`read: <files> · callers: <n> (<where>) · tests: <files | none found>`.
Before the first run of a check on the changed code, add `predict:` — what the output will
show and what must stay unchanged (`references/verification.md`, Predict, Then Compare).

- A caller whose behaviour depends on what changes is part of the change: read it too, and
  either update it or say why it is unaffected.
- `tests: none found` is a finding, not a pass: say so in the summary, and a behaviour change
  there needs a new test seen failing first.
- Something read contradicts the brain or a module note -> the code wins; draft the correction.
- Proportion: a comment, typo, or docs-only edit needs the file read, not the callers. A new
  file needs the neighbours it imitates and the place that will call it.
- The read set of an earlier task in the same run counts, unless the file changed since.

## Part 2 — Module notes

One note per **module**: a package root, a top-level source folder, or a group of files the
graph shows working as one unit (most edges inside, few outside). Small projects may have two
or three; a module is too big when its note cannot stay within the limit.

Path: `.safe-code/context/modules/<module>.md`. Notes are not loaded at session start and do
not count toward the brain budget; `architecture.md`'s Navigation map carries one line per
module: `<path> — <one-line purpose> — note: modules/<module>.md | not read yet`.

Shape (≤ ~40 lines, one fact per line):

```md
# <module>
covers: <paths or globs>
synced: <short-sha> · <date> · read: <full | partial (<what was not read>)> [· by: <model>]

## Purpose
<one or two lines: what it is for, who calls into it>

## Entry points
- <file>:<symbol> — <what triggers it> [extracted: <path>:<line>]

## How it works
- <the main flows, in order, each with a file:symbol pointer>

## Depends on / used by
- depends on: <modules, services, tables> [extracted: codegraph …]
- used by: <modules or entry points>

## Must stay true
- <invariants, ordering, assumptions a change could break — each with where it is enforced>

## Tests
- <test files and what they cover; what is not covered>

## Open questions
- <what the code does not explain>
```

Every technical line carries an evidence tag (SKILL.md, Evidence Tags). A reason only the user
knows is an Open Question until they answer it (`[user-confirmed: <date>]`).

### When notes are written

- **Setup** (after the code graph, with First-Run Population): one note per module, most
  depended-on first (graph "used by N files"; no graph -> most-changed in history, then entry
  points). Cap: 12 modules or the adopt scope cap (`references/adopt.md`), whichever is lower.
  The rest stay `not read yet` in the Navigation map and under `progress-tracker.md ## Not Yet
  Specified` — never a note written from filenames.
- **Later runs**: a task that works in a module with no note has just read it (Part 1) — draft
  its note in `SESSION.md ## Drafts`, written on `--save`. Coverage grows where the work is.
- `read: partial` is allowed and honest; a note never claims more than was read.
- Reading for notes is bulk work: with subagent support, one read-only subagent per module, on
  the host's cheaper tier when it offers one (`references/audit-checks.md`, Model tiers). The
  main model checks each returned note against the code before it is written.

### Keeping notes true

- **Stale test:** `git diff --name-only <synced>..HEAD -- <covers>` prints anything -> the note
  is stale. A stale note is still a lead; say `module note stale since <sha>` when relying on it.
- **On `--save`:** every module this run edited gets its note refreshed from what was read this
  run and re-stamped `synced: <HEAD>`; this is part of the save, not optional. Stale notes for
  modules this run did not touch are left alone and counted.
- **On `--audit`:** refresh every stale note (re-read the changed files only), most-used first.
- A deleted module -> its note is removed with a Graveyard entry; a renamed one -> `git mv`.
- Team mode: notes are shared brain (committed); one fact per line keeps merges small.

Report on the Step 8 banner: `Modules: <n> noted · <n> stale · <n> not read yet`.
