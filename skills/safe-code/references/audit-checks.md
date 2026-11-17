# safe-code reference: audit checks (Step 3 report-only checks, remote buckets, helper dispatch)

> Loaded on demand (Layer 3): at Step 3a on setup and audit runs (report-only repo checks),
> at Step 3b when a remote URL does not clearly fit a bucket, and at Step 3g before a helper
> is dispatched as a subagent. The binding rules — report only, never fix, never `git add`,
> never push, outcomes never depend on subagent availability — live inline in SKILL.md; this
> file holds the checks and the procedures.

## Report-only repo checks (setup and audit runs)

Each finding is reported with its severity in the Step 3c Reasoning block and the final
summary, and drafted in `SESSION.md` for `BACKLOG.md`. Never fix one yourself.

- **Fresh-clone completeness** (High) — cross-check `.gitignore` (and `git status --ignored`)
  against real source directories (`migrations/`, `schema/`, `seeds/`, `fixtures/`, `scripts/`
  the docs reference). Untracked or ignored source means a fresh clone silently lacks it (DB
  migrations that live on one machine leave every clone with an empty database). Never
  `git add` it yourself — the user decides what was meant to be private.
- **Out-of-band schema migrations** (High) — a migration applied outside the project's
  migration tool, so its tracking table is out of sync with the migrations folder.
- **Colliding sequential IDs** (High) — migration numbers, spec numbers, or other sequential
  IDs duplicated after an upstream merge.

Light runs skip these checks; `/safe-code --audit` (or a cleanup/audit ask) runs them. A
setup-adopt run runs them too, with the history mining in `references/adopt.md` — equally
report-only: hot files, decision commits, and TODO candidates are findings, never fixes.

## Remote buckets (Step 3b)

Classify `git remote -v` for information only; the save action is identical in every case:
**local git commit only, never push**. Detect from the URL only — never ask the user which
platform they use, and never let detection cause a push.

| Bucket | Remote | Output note |
|---|---|---|
| **A** — git-native platform | github.com, gitlab.com, bitbucket.org, dev.azure.com, codeberg.org, self-hosted, custom SSH/HTTPS URLs | none |
| **B** — auto-deploy platform | vercel.com, netlify.com, pages.cloudflare.com, anything deploying on push | "Remote push may trigger deploy, so /safe-code --save never pushes." |
| **C** — no remote | — | "No remote detected." |

## Helper Execution Mode (Step 3g)

When the host supports fresh-context subagents (Claude Code Agent tool, Codex subagents, or
equivalent), prefer dispatching **read-only** helpers as subagents so the main context stays
lean on long runs.

- **Subagent-eligible:** `$explore-codebase`, `$codebase-pruner` Audit mode, the Step 4b
  config scan, the Context Self-Test, `$review-changes` analysis, and on setup-adopt the
  memory-import read and the history mining (`references/adopt.md`; findings return as drafts).
- **Bulk reads** (also subagent-eligible): the module-note reads at setup and on `--audit`
  (`references/deep-read.md`), one subagent per module.
- **Inline-only** (writes or session state): `$safe-refactor-code`, `$codebase-pruner`
  Execute mode, `$debug-issue` fixes, all doc/session updates.

Rules:

1. Dispatch with the query AND the run objective, so the subagent knows what matters in its
   summary.
2. Subagents return findings as summaries merged into `SESSION.md` drafts; they never edit
   files or session docs, and they inherit the shared-checkout invariant
   (`references/multi-session.md`, Shared-checkout rules).
3. Evaluate every summary before accepting it: at most 2 follow-up dispatches when key facts
   are missing, then continue with what exists.
4. The returned summary is the **success signal** — a missing, empty, or off-topic summary
   counts as a failed dispatch, never as "no findings".
5. More than half of a parallel fan-out fails -> stop dispatching and run the remaining work
   inline.
6. No subagent support -> run helpers inline exactly as before — outcomes must not depend on
   subagent availability.

### Model tiers (bulk reads only)

Reading many files to summarise them is high-volume, low-judgement work. When the host lets the
agent choose a model per subagent, bulk reads run on a cheaper, faster tier and the main model
keeps the judgement.

1. **Which model.** `user-preferences.md` may name it: `- bulk-read-model: <model name or alias
   as this host spells it>` (per-developer values go in `user-preferences.local.md`). Not set ->
   use the host's own "smaller / faster" tier when it exposes one by a stable alias; never guess
   a model name, never pick one from memory of a provider's line-up. No way to choose, or the
   host or user pins subagent models -> subagents inherit the session model; say so once
   (`Bulk reads: session model (host does not offer a tier)`).
2. **What may go down a tier.** Only read-and-summarise work: module-note reads, the adopt
   memory-import read, history mining, `$explore-codebase` orientation. Never the Context
   Self-Test grading, `$review-changes` (incl. the Security axis), dead-code classification,
   debugging, a security audit, or any write.
3. **The main model checks the result.** For each returned note: every technical line has an
   evidence tag; open at least three cited `path:line` pointers per note (all of them when the
   note has fewer) and confirm they say what the note claims. One wrong pointer -> that note is
   rejected and re-read on the session model. More than a third of a batch rejected -> stop
   using the cheaper tier for this run.
4. **Stamp it.** A note read on another tier records it: `read: full · by: <model>`. A lower-tier
   note is a lead like any other; Read-Before-Touch still reads the real code before any edit.
5. Report one line: `Bulk reads: <n> on <model> · <n> re-read on session model`.
