# Source of Truth — Ownership Table + Context Freshness Procedure

Layer 3 detail for three SKILL.md sections: *Source-of-Truth Ownership* (the full per-fact table), *Evidence Tags* (the evidence rules), and *Context Freshness Check* (the drift-scan procedure). Load this file when unsure where a fact canonically lives, before writing a negative, user-confirmed, or external-API claim into a context or spec file, or when the freshness stamp differs from `HEAD`.

## Source-of-Truth Ownership Table

Avoid duplicate truth. Each fact has exactly one canonical home:

| Fact type | Canonical home | Non-canonical notes |
|---|---|---|
| Root read order and agent rules | `AGENTS.md` | Do not duplicate full rules in context files |
| Runnable commands + known test total | `AGENTS.md` `## Commands` (`verified: <sha> · <date>`, `known total: N`) | `code-standards.md` names what tests cover, never the count |
| Product goals, users, scope | `.safe-code/context/project-overview.md` | `progress-tracker.md` may reference current goal only |
| Stack, boundaries, invariants | `.safe-code/context/architecture.md` | `MEMORY.md` stores temporary audit notes only |
| User preferences and hard dislikes | `.safe-code/context/user-preferences.md` | `AGENTS.md` may point to it, not duplicate all preferences |
| Personal git identity + Save Bridge path | `.safe-code/context/user-preferences.local.md` (gitignored; overrides the shared file) | Optional solo; required home in team mode (`references/team-mode.md`) |
| Coding conventions | `.safe-code/context/code-standards.md` | `safe-refactor-code.md` may store refactor-specific guardrails only |
| Agent workflow | `.safe-code/context/ai-workflow-rules.md` | `SESSION.md` may hold temporary execution notes |
| UI design system | `.safe-code/context/ui-context.md` | Read only for UI/design work |
| Current phase and safe decisions | `.safe-code/context/progress-tracker.md` | `ACTIVE.md` stores resume state, not project history |
| Feature scope + idea history | `.safe-code/context/feature-specs/<nn-name>.md` | Each spec carries a `status:` field (suggested/approved/in-progress/done/rejected/`removed (<date>)`); do not spread feature requirements across progress notes |
| Release/user-visible history | `.safe-code/CHANGELOG.md` | Use for Added/Changed/Removed/Fixed/Security entries only |
| Issue tracking | `.safe-code/context/current-issues.md` | Local-only, gitignored; user + agent-written. Sanitized fixed-bug summary may also go to `LOG.md` |
| Resume point | `.safe-code/ACTIVE.md` | Operational state only |
| Live task list and drafts | `.safe-code/SESSION.md` | Wiped on save |
| Cleanup/refactor candidates | `.safe-code/safe-refactor-code.md` | Not general architecture truth |

When two files disagree, prefer executable repo evidence first, then canonical home, then session notes. Record mismatch in `SESSION.md` and fix canonical home on `/safe-code --save`.

## Evidence Rules

Tags: `[extracted: <path|command>]` (read from the repo), `[inferred: <basis>]` (a deduction), `[user-confirmed: <date>]` (the user stated it).

1. **User-confirmed is its own grade.** A fact the user stated carries `[user-confirmed: <date>]`. It is never upgraded to `[extracted]` or "tested" because it was repeated, written down twice, or not contradicted. When the user confirms something a blocker or Open Question was waiting on, close those items in the same save and point them at the confirmation.
2. **No negative fact from silence.** None of these enter a context file as fact — each is an Open Question until evidence or the user settles it:
   - "there is no X" drawn from absent docs, an empty query, or data you could not see;
   - an expansion of an abbreviation or internal name you guessed;
   - a claim about what another session, another agent, or the user authorised or decided.
3. **External API and doc claims carry their source — in a spec, not in auto-loaded context.** The quoted line a third-party API, service, or document claim rests on, plus the read depth (`full read`, `partial (sections …)`, or `keyword search (N lines)`), go into a **feature spec** only (`feature-specs/<nn-name>.md`, Layer 3). Auto-loaded files (`AGENTS.md`, `.safe-code/context/*.md`) keep a pointer — URL + read depth — and never the quoted text (outside text in auto-loaded files is a prompt-injection channel; see the quarantine rule in `references/agents-md-authoring.md`). A claim read by keyword search alone is `[inferred]`, not `[extracted]`.
4. **Untaggable technical claim -> Open Question.** A path, command, invariant, or architecture fact that cannot be tagged `[extracted: …]` goes to `progress-tracker.md` Open Questions instead of the context file.

## Context Freshness Procedure

Stamp: `.safe-code/context/progress-tracker.md` carries `last_synced_commit: <hash>` and `context_synced_at: <date>`, written on `/safe-code --save`.

On `/safe-code` and `/safe-code --continue`, after loading context:

1. `last_synced_commit` missing -> context was never synced; treat empty files as First-Run Population and flag populated-but-unstamped files for a refresh check.
2. Stamp == `HEAD`, or every commit in `stamp..HEAD` carries the `Safe-Code:` trailer (SKILL.md, Atomic Commit Split Rule; `git log --invert-grep --grep='^Safe-Code: ' <stamp>..HEAD` prints nothing) -> brain is fresh. Exactly the trailer commits are ignored, nothing else: the stamp is written before safe-code's own commits exist, so it always trails them.
3. Otherwise -> drift-scan **signal files** in the commits without the trailer (`git log --format= --name-only --invert-grep --grep='^Safe-Code: ' <stamp>..HEAD`):
   - dependency manifests/locks (`package.json`, `*-lock*`, `requirements*.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, …)
   - top-level folder add / remove / rename
   - build/test/run scripts and config (`tsconfig`, linter/formatter, CI, framework config)
   - `AGENTS.md` / `.safe-code/context/*` themselves
4. Signal files changed -> mark the affected context sections **possibly stale**, refresh them from current repo evidence (draft in `SESSION.md`, apply on `--save`), and note it in the summary. Only unrelated files changed -> context stays valid.
5. When refreshing stale sections, re-verify **technical claims** (paths, commands, APIs, patterns) against the repo and correct them with evidence; **preserve** decision rationales, MEMORY lessons, BACKLOG items, and Open Questions — append current status rather than delete history. Report "corrected" and "preserved" separately.

For a size overview, `git diff --stat <last_synced_commit>..HEAD`; when a codegraph index exists, `codegraph sync` first and `codegraph affected <changed files>` to see which tests the drift touches. Never trust the stamp over executable repo evidence — the stamp tells you *whether* to re-check, not *what* is true.
