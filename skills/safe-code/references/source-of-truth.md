# Source of Truth — Ownership Table + Context Freshness Procedure

Layer 3 detail for two SKILL.md sections: *Source-of-Truth Ownership* (the full per-fact table) and *Context Freshness Check* (the drift-scan procedure). Load this file when unsure where a fact canonically lives, or when the freshness stamp differs from `HEAD`.

## Source-of-Truth Ownership Table

Avoid duplicate truth. Each fact has exactly one canonical home:

| Fact type | Canonical home | Non-canonical notes |
|---|---|---|
| Root read order and agent rules | `AGENTS.md` | Do not duplicate full rules in context files |
| Product goals, users, scope | `.safe-code/context/project-overview.md` | `progress-tracker.md` may reference current goal only |
| Stack, boundaries, invariants | `.safe-code/context/architecture.md` | `MEMORY.md` stores temporary audit notes only |
| User preferences and hard dislikes | `.safe-code/context/user-preferences.md` | `AGENTS.md` may point to it, not duplicate all preferences |
| Coding conventions | `.safe-code/context/code-standards.md` | `safe-refactor-code.md` may store refactor-specific guardrails only |
| Agent workflow | `.safe-code/context/ai-workflow-rules.md` | `SESSION.md` may hold temporary execution notes |
| UI design system | `.safe-code/context/ui-context.md` | Read only for UI/design work |
| Current phase and safe decisions | `.safe-code/context/progress-tracker.md` | `ACTIVE.md` stores resume state, not project history |
| Feature scope + idea history | `.safe-code/context/feature-specs/<nn-name>.md` | Each spec carries a `status:` field (suggested/approved/in-progress/done/rejected); do not spread feature requirements across progress notes |
| Release/user-visible history | `.safe-code/CHANGELOG.md` | Use for Added/Changed/Removed/Fixed/Security entries only |
| Issue tracking | `.safe-code/context/current-issues.md` | Local-only, gitignored; user + agent-written. Sanitized fixed-bug summary may also go to `LOG.md` |
| Resume point | `.safe-code/ACTIVE.md` | Operational state only |
| Live task list and drafts | `.safe-code/SESSION.md` | Wiped on save |
| Cleanup/refactor candidates | `.safe-code/safe-refactor-code.md` | Not general architecture truth |

When two files disagree, prefer executable repo evidence first, then canonical home, then session notes. Record mismatch in `SESSION.md` and fix canonical home on `/safe-code --save`.

## Context Freshness Procedure

Stamp: `.safe-code/context/progress-tracker.md` carries `last_synced_commit: <hash>` and `context_synced_at: <date>`, written on `/safe-code --save`.

On `/safe-code` and `/safe-code --continue`, after loading context:

1. `last_synced_commit` missing -> context was never synced; treat empty files as First-Run Population and flag populated-but-unstamped files for a refresh check.
2. `last_synced_commit` == current `HEAD` -> brain is fresh; no refresh needed. Also fresh: `stamp..HEAD` contains only safe-code's own save commits (the stamp is written before those commits exist, so it always trails them — see rule 5).
3. They differ -> run a quick drift scan on **signal files** in `last_synced_commit..HEAD`:
   - dependency manifests/locks (`package.json`, `*-lock*`, `requirements*.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, …)
   - top-level folder add / remove / rename
   - build/test/run scripts and config (`tsconfig`, linter/formatter, CI, framework config)
   - `AGENTS.md` / `.safe-code/context/*` themselves
4. Signal files changed -> mark the affected context sections **possibly stale**, refresh them from current repo evidence (draft in `SESSION.md`, apply on `--save`), and note it in the summary. Only unrelated files changed -> context stays valid.
5. Ignore safe-code's own save commits in the drift window (the `--save` bookkeeping commits, e.g. `docs: sync .safe-code session files`) — the stamp is written before those commits exist, so they always trail it and are not real drift.
6. When refreshing stale sections, re-verify **technical claims** (paths, commands, APIs, patterns) against the repo and correct them with evidence; **preserve** decision rationales, MEMORY lessons, BACKLOG items, and Open Questions — append current status rather than delete history. Report "corrected" and "preserved" separately.

Use graph delta (`detect_changes_tool`) for the drift scan when graph tools are ready; otherwise fall back to `git diff --stat <last_synced_commit>..HEAD`. Never trust the stamp over executable repo evidence — the stamp tells you *whether* to re-check, not *what* is true.
