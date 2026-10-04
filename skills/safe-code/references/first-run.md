# safe-code reference: first-run population + context self-test

> Loaded on demand on the first `/safe-code` run (empty scaffold, setup-fresh or setup-adopt) and whenever the
> Context Self-Test triggers (Layer 3). The binding rules — write evidence-derivable
> context immediately on first run, never invent facts, gaps become work — live inline
> in SKILL.md; this file holds the per-file table, the question set, and the grading.

## First-Run Population — per-file table

| File | First-run write |
|---|---|
| `AGENTS.md` | Yes — Read First order + verified project facts/commands |
| `.safe-code/context/project-overview.md` | Yes — from README, manifests, package metadata |
| `.safe-code/context/architecture.md` | Yes — stack, boundaries, invariants, **and a Navigation map (where things live / entry points)** from manifests/folders/configs |
| `.safe-code/context/code-standards.md` | Yes — conventions from linter/formatter/tsconfig/editorconfig |
| `.safe-code/context/ai-workflow-rules.md` | Only if repo/team docs reveal real workflow; else leave template |
| `.safe-code/context/progress-tracker.md` | Yes — Current Phase + Open Questions (unverifiable facts) |
| `.safe-code/context/user-preferences.md` | No — conversation-derived only, no repo evidence |
| `.safe-code/context/ui-context.md` | No — not created at setup; created on the first UI/design work |
| `.safe-code/context/current-issues.md` | No — manual + issue-trigger only |

Rules:

- This immediate-write exception applies only while a file is an empty scaffold. Once it holds real content, later edits revert to Draft-Until-Save.
- Never invent facts. Anything not provable from repo evidence is an Open Question, not a populated claim.
- Tag load-bearing technical claims per the Evidence Tags rule in SKILL.md — `[extracted: <path|command>]` when read directly from the repo, `[inferred: <basis>]` for deductions. Absent evidence never becomes a negative fact ("there is no X") — it becomes an Open Question (`references/source-of-truth.md`, Evidence Rules).
- Foreign dirty paths (`git status --porcelain` entries no task explains — another session's or the user's uncommitted work): read the committed version (`git show HEAD:<path>`), or tag a claim drawn from the working copy `[inferred: uncommitted foreign change]`. Never present someone's half-done edit as an established fact.
- Still draft *this session's* ongoing changes in `SESSION.md`; First-Run Population is about seeding empty context, not about live edits.
- After populating, run the **Context Self-Test** to verify the brain is sufficient; fill or flag any gaps it finds.

### Setup-adopt: what differs

Same table, more sources (`references/adopt.md`). Population order: import existing memory first, then mine history, then
read code within the scope cap — so imported claims get verified against code read in the same run.

| File | Extra on adopt |
|---|---|
| `AGENTS.md` | reconcile an existing one (rules kept); one `## Project Facts` line naming instruction files kept in place; imported commands enter as `unverified` |
| `architecture.md` | pointer lines to ADR / architecture docs (link, not copy); a "most changed" Navigation-map line from history |
| `code-standards.md` / `ai-workflow-rules.md` | imported conventions and policies, `[extracted: <file>:<line>]` |
| `progress-tracker.md` | decision-like commits under Architecture Decisions; active branches as In Progress candidates; unverified imports as Open Questions; unread areas under `## Not Yet Specified` (scope cap) |
| `BACKLOG.md` | not written at setup: TODO/FIXME/HACK candidates are drafted in `SESSION.md` and applied on `--save` |

User WIP the user confirmed is read as fact tagged `[inferred: uncommitted WIP]`; the foreign-path rule above covers the rest.

## Context Self-Test — how

1. **Closed-book.** Dispatch a fresh-context subagent with the canonical prompt below, given **only** the `.safe-code/context/*.md` files plus the `## Commands` section of `AGENTS.md` (the single home of runnable commands) — no repo access. (No subagent support -> run inline, but answer strictly from the loaded context, not from code read this session.) The point is to simulate an agent that has the brain but not the codebase.
2. **Ask the Day-1 question set** (8–10), each mapped to the file that should answer it:

   | Question | Should be answered by |
   |---|---|
   | What does this project do, and for whom? | `project-overview.md` |
   | What is the stack and high-level architecture? | `architecture.md` |
   | Where do I add a new route / feature / model? | `architecture.md` (Navigation map) |
   | How do I run, build, and test it? | `AGENTS.md ## Commands` |
   | What invariants must never be broken? | `architecture.md` |
   | What code conventions must I follow? | `code-standards.md` |
   | What is in progress and what is next? | `progress-tracker.md` |
   | Any user preferences / hard dislikes to respect? | `user-preferences.md` |

   Add repo-specific questions when the stack warrants (e.g. "how is auth enforced?", "how is data persisted?"). When a codegraph index (`.codegraph/`) exists, seed 1–2 extra questions from the most-depended-on files (`codegraph node -f <file> --symbols-only` reports "used by N files"): "What is <file/module> for and what depends on it?" — the brain should be able to answer about the code the graph says matters most.
3. **Grade each answer** — four grades, one set of rules:
   - **PASS** — cites file + section, and rests on `[extracted: …]` or `[user-confirmed: <date>]` claims (the user is the only source for the latter), or on an `[inferred: …]` claim where no `[extracted]` evidence could exist. A file that is a template by design (`user-preferences.md`, `ui-context.md` — absent counts the same) answering "none recorded yet" is **PASS**: absence is the correct answer there.
   - **WEAK** — cited, but rests only on `[inferred: …]` claims where repo evidence could exist. Treat as a gap: verify from the repo and upgrade the tag, or downgrade the claim to an Open Question.
   - **OPEN** — the brain answers only with an unresolved Open Question (stays open honestly when the repo cannot answer it either).
   - **FAIL** — no citation possible (the model is answering from training memory, not the brain), or the cited text does not support the answer.
4. **Re-verify before scoring — read-only.** The closed-book grader checks citability, not truth: a stale fact that is faithfully cited still passes. So before scoring, re-verify every command string and path that appears in `context/*.md` and `AGENTS.md ## Commands` with read-only probes only: the path exists (`test -e`), the binary or script entry exists and answers `--help` / `--version` (or the `package.json` script / Makefile target is defined), and a command with a dry-run mode runs in that mode. Build/test/run commands are checked by their entry existing, not by running them. A command with side effects — deploy, migrate, send, push, install, publish, anything that writes outside the repo or to a database — is **never executed**: it gets `check: manual` and counts as unverified, not stale. A command that cannot succeed as written (missing path, binary, or script entry) is a **FAIL** for the question that cites it and a drafted correction in `SESSION.md`.
5. **Adversarial grade — only when the first pass has WEAK or FAIL answers** (and subagents are available). A second subagent tries to refute each WEAK/FAIL answer ("is this actually supported by the context, or invented?"); majority-refuted -> FAIL. An all-PASS/OPEN first pass skips it — the extra dispatch buys nothing there.

### Canonical self-test prompt (dispatch verbatim, fill the `<…>` slots)

```text
You are grading a project brain closed-book. Read ONLY these files: <list of
.safe-code/context/*.md paths>, plus the `## Commands` section of AGENTS.md. Do not
open any other file, run any command, or use what you know about similar projects.

Answer each question in 1-3 lines and cite `<file>.md § <section>` (or
`AGENTS.md § Commands`). Grade it:
- PASS: cited, and rests on [extracted: …] or [user-confirmed: …] claims, or on an
  [inferred: …] claim where no repo evidence could exist. A template-by-design file
  (user-preferences.md, ui-context.md, or that file being absent) answering
  "none recorded yet" is PASS.
- WEAK: cited, but rests only on [inferred: …] claims where repo evidence could exist.
- OPEN: the only answer is an unresolved Open Question.
- FAIL: no citation possible, or the cited text does not support the answer.

Questions:
<numbered Day-1 question set + repo-specific questions>

Return one line per question: `<n>. <PASS|WEAK|OPEN|FAIL> — <answer> — <file § section>`,
then one totals line: `<p> pass · <w> weak · <o> open · <f> fail`. Edit nothing.
```

## Gaps are work, not just a score

For each WEAK or FAIL question (and each OPEN one the repo can answer):

- **Discoverable from the repo** -> read the specific code, write the fact into the right context file (draft in `SESSION.md`, apply on `--save`).
- **Not provable from repo evidence** -> add to `.safe-code/context/progress-tracker.md` Open Questions for the user.

Keep the question set small — this is a coverage gate, not an interrogation.

## Result format (the one format)

```text
context_selftest: <p>/<total> pass · <w> weak · <o> open · <f> fail · <m> commands re-verified (read-only), <k> stale, <j> manual (<date>)
```

Counts are taken after the gap work above. The same line goes into `progress-tracker.md` and
the Step 8 `Context self-test:` line; a run that skips the test prints `skipped: routine resume`.
