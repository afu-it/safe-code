# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is the **source repository for the `safe-code` agent skill** and its helper skills. The "product" is prompt-engineered Markdown — `SKILL.md` files plus `references/` — that ship to other projects via `npx skills add afu-it/safe-code`. There is **no build, compile, bundler, or package manager**; nothing here is executed except the bash scripts in `skills/safe-code/scripts/` (shipped with the skill) and `scripts/` (maintainer guards + root shims). Editing this repo means editing instructions an LLM will later follow, so prose precision, internal cross-references, and version consistency *are* the correctness surface.

> **Critical mental model — meta vs. consumer layout.** The `AGENTS.md` + `.safe-code/` + provider-bridge layout described in `README.md` is what the skill **produces inside a project that installs it**. It is **not** the layout of this repo. Do not scaffold `.safe-code/` here. This repo's own layout is `skills/`, `scripts/`, `references/`, and the docs below.

## Commands

No build or linters in the usual sense. The deterministic contract is bash, guarded by fixture tests (`bash tests/scripts/run.sh`, CI job `script-tests`):

```bash
# check.sh, migrate.sh, save-reminder.sh ship with the skill in skills/safe-code/scripts/
# (so `npx skills add` installs them); scripts/<name>.sh at the root are thin exec shims.
bash scripts/check.sh [project-root]      # shim -> skills/safe-code/scripts/check.sh: verify safe-code conventions in a TARGET project
bash scripts/migrate.sh                    # shim -> skills/safe-code/scripts/migrate.sh: preview legacy-layout migration (dry-run)
bash scripts/migrate.sh --apply [root]     # perform the migration (uses git mv when tracked)
bash scripts/check-version.sh              # MAINTAINER guard (root only, not shipped): assert version agrees across SKILL.md + README + examples
bash scripts/check-privacy.sh              # MAINTAINER guard (root only, CI job privacy-lint): fail on home paths, emails, token shapes in shipped files; a deliberate example opts out per line with `privacy-lint: allow`
bash tests/scripts/run.sh [-v]             # fixture tests for the three shipped scripts + shims (CI job script-tests; ubuntu + macOS /bin/bash 3.2; < 60s; -v shows failing output). Manual pre-release agent scenarios: tests/scenarios/README.md
bash scripts/save-reminder.sh              # shim -> skills/safe-code/scripts/save-reminder.sh (ships with the skill; opt-in SessionStart hook = brain brief + save reminder: one JSON line, brief in hookSpecificOutput.additionalContext, reminder in top-level systemMessage only when unsaved; `--no-brief` reminder only; `--plain` text for non-JSON hosts; stamp `.safe-code/.last-save`)
```

- `check.sh` is the only shipped script that "fails" (exit 1) — and only on its hard checks (today one; the summary counts them): a committed `.safe-code/context/current-issues.md` (it may hold secrets/logs). Everything else is an advisory warning. `check.sh` and `save-reminder.sh` locate the project root with the one rule in `references/monorepo.md` (nearest dir holding `.safe-code/`, never above the git toplevel; else the git toplevel), so they run against a *consumer* project, not this repo.
- Script edits: `bash tests/scripts/run.sh` (run it under `/bin/bash` too — CI covers bash 3.2 on macOS) plus `bash -n` and `shellcheck -S warning`. Skill prose edits: verify by `grep` (the implementation plans in `docs/superpowers/plans/` use exact-string `grep` assertions as their test harness) and by reading the changed prose end-to-end. Agent behaviour: the manual pre-release scenarios in `tests/scenarios/` (`build-fixture.sh [--team] [--adopt]` + `assert.sh`; cost tokens, not in CI).

## Architecture (the big picture)

**One orchestrator + seven analyze-first helpers.** `skills/safe-code/SKILL.md` (~515 lines; keep it at or under ~540 lines and 55,000 bytes — `wc -c`) is the entry skill exposing six commands — `/safe-code` (setup on a project without a brain — setup-fresh for a new repo, setup-adopt for an existing one — else a light resume / fresh pass), `--continue` (explicit resume, a light run), `--audit` (the full hygiene pass: dead code, config trust audit, refactor sweep), `--save` (finalize docs + retro + **local commit only, never push** + optional Save Bridge append), `--explain` (read-only briefing), `--codegraph [question]` (optional code graph via the external codegraph CLI, with a small health check; `--graphify` is a one-line alias). It orchestrates helper skills in `skills/{senior-dev,build-graph,explore-codebase,codebase-pruner,safe-refactor-code,review-changes,debug-issue}/`. Helpers are dispatched by a **`$helper-name` convention written inline in SKILL.md** (e.g. `$debug-issue`, `$codebase-pruner`). Helpers analyze first and never make broad changes just because `/safe-code` ran.

**Three-layer context-economy loading** (`## Loading Layers` in SKILL.md) is the load-bearing design constraint:
- **Layer 1 (Entry)** — read every session.
- **Layer 2 (Resume)** — loaded on `--continue` / auto-continue when saved state exists.
- **Layer 3 (Detail)** — `skills/safe-code/references/*.md`, loaded only when a specific step triggers it.

Because of this, **never inline template bodies or long detail into `SKILL.md`** — put them in `references/` and point at them with a "Layer 3 Trigger" line. The reference files have specific ownership:
- `references/agents-md-authoring.md` — the **single source of truth** for how `AGENTS.md` is authored; helper skills defer to it.
- `references/doc-templates.md` — fallback shapes for every `.safe-code/` context + session file, incl. the `SESSION.md` carry-forward shape `--save` wipes to; a section guide at the top says which section each step reads (missing files only).
- `references/examples.md` — worked end-to-end runs and anti-patterns.
- `references/agent-config-audit.md` — patterns + High/Medium/Info classification for Step 4b (Agent Config Trust Audit), loaded only when that step runs.
- `references/save-procedure.md` — atomic-split mechanics, Last Session shapes, LOG trim procedure, per-file sync table, Session-File Discipline, Graveyard hashes, Retro, Save Bridge; loaded on `--save` only.
- `references/final-banner.md` — the Step 8 banner's full line set and vocabulary (incl. the `Graph:` status vocabulary); loaded only right before the banner prints.
- `references/legacy-migration.md` — legacy detection list + per-location migration steps; loaded when a legacy layout is detected.
- `references/graph-integration.md` — codegraph detection/install lines, health check, build/sync sequence (Step 3f), command map, the Step 4 dead-code derivation loop, and the `--codegraph` harvest mapping.
- `references/first-run.md` — First-Run Population table + Context Self-Test question set/grading; loaded on a first run or when the self-test triggers.
- `references/source-of-truth.md` — full source-of-truth ownership table + context-freshness drift procedure; loaded when fact ownership is unclear or the freshness stamp differs from `HEAD`.
- `references/git-identity.md` — Step 3e Identity + Account Guard procedure (leak shapes, `gh` account mismatch, the push-once command to print — never switch the user's active account); loaded before the first commit of a run.
- `references/audit-checks.md` — report-only repo checks (setup/audit runs), remote buckets, helper execution mode (subagent dispatch).
- `references/team-mode.md` — team-mode detection (>1 non-bot author in 90 days, or `team: on|off`), committed vs per-developer split + `.gitignore` lines, `user-preferences.local.md` (personal `## Git Identity` / `diary_path`, gitignored, overrides the shared file), merge-friendly writing.
- `references/adopt.md` — setup-adopt (existing project, first run): fresh/adopt detection (≥ 20 commits or ≥ 30 source files), read-only import of existing agent memory (`CLAUDE.md`, `.cursorrules`, ADRs, …) with `[extracted: <file>:<line>]` tags, bounded git-history mining, the large-repo scope cap + `Coverage: ~N%`, the `safe-code/adopt` branch suggestion, and the user-WIP question.
- `references/monorepo.md` — project-root rule (nearest dir with `.safe-code/`, else git toplevel), package-root detection, nested package `AGENTS.md`.
- `references/doc-templates.md` is the one home of the Provider Bridge host table + rules (SKILL.md keeps a short summary). `references/save-reminder-hook.md` holds the hook offer: command per install type, the `SessionStart` JSON shape, merge steps — loaded only when the offer can be answered (interactive); the full hook contract is the script header.
- `references/agents-md-authoring.md` opens with a section guide (Template / Authoring rules / Verified Commands / Brain Budget / Quality bar) so a step reads only what it needs.
- Single home per duplicated rule: shared-checkout git bans -> `references/multi-session.md` (Shared-checkout rules); `rm` -> backups and deploy-CLI rules -> SKILL.md Safety Invariants; local-only brain detection (`git check-ignore -q --no-index .safe-code/` or `.safe-code/context/`; a `SESSION.md`-only ignore means team mode) -> SKILL.md Local-Only Brain; team-mode detection -> `references/team-mode.md`; project-root rule -> `references/monorepo.md`. Everything else points at these in one line.
- `references/verification.md` (check annotations, scan proof, slice standard, smoke-verify detail), `references/multi-session.md` (shared-checkout detection + staging), `references/save-reminder-hook.md` (hook offer detail), `references/feature-specs.md` (spec writing/flipping) — moved out of SKILL.md in 5.0; each has a Layer 3 trigger line. `verification.md` points Smoke-Verify at `AGENTS.md ## Commands` (`verified: <sha> · <date>`, `known total: N`), the single home of runnable commands and the test total.

**The output contract the skill generates** (read `README.md` "What it writes in your project" for the full picture): exactly two root artifacts in a consumer project — `AGENTS.md` (canonical entry) + a single `.safe-code/` folder holding `context/` (long-term project brain) and six session files (`ACTIVE`, `SESSION`, `LOG`, `BACKLOG`, `MEMORY`, `safe-refactor-code`). Since 5.0 `AGENTS.md` is the only default root output; a thin provider-bridge pointer (no state) is written only for the running host and only when it does not read `AGENTS.md`: `CLAUDE.md` under Claude Code (its native `AGENTS.md` read switches off when any parent `CLAUDE.md` exists); Gemini CLI gets a printed `.gemini/settings.json` `context.fileName` snippet, never a `GEMINI.md`; every other host is native. Undetectable host -> `AGENTS.md` only plus a report line naming those two exceptions. Older `GEMINI.md` / Copilot / Cursor / `.clinerules/` bridges are left in place and still recognised by `check.sh` and migration, but never expected. Every command auto-migrates legacy layouts (`.codex/agents`, v3 `.agents/` + root `context/`) into `.safe-code/`.

**Graph tool:** codegraph (npm `@colbymchenry/codegraph`) is the only graph tool since 5.0 — it replaced graphify and code-review-graph everywhere. The `build-graph` helper produces `.codegraph/` in a consumer project (self-gitignored). This repo's own `.code-review-graph/` dir is legacy from the old tool: unused, left in place.

## Conventions that span multiple files (get these right)

- **Version bumps are not single-edit.** A version string lives in these places, which must move together: `SKILL.md` frontmatter `version:`; the two Step 8 banners (`=== safe-code vX.Y session complete ===` and the `=== safe-code vX.Y session ended · … ===` variant); the `README.md` H1 (`# safe-code vX.Y`), badge, and sample banners; the `README.md` "What's New" section (latest 2–3 releases) and the root `CHANGELOG.md` entry; and the close-out banners in `skills/safe-code/references/examples.md`. Versions are `MAJOR.MINOR` (e.g. `5.0`; a third part is accepted). The `Safe-Code: <version>` commit trailer and the `references/final-banner.md` full banner use `<version>`, never a literal number. `check-version.sh` guards all of them except "What's New" and `CHANGELOG.md` (prose — check by hand). A version change that only touches the frontmatter is incomplete — run `bash scripts/check-version.sh` (source of truth = `SKILL.md` frontmatter; it fails on any mismatch, including the examples banner) and grep the repo for the old number before considering it done. (`safe-refactor-code/SKILL.md` carries its own `metadata.version` and can lag intentionally.)
- **`skills/safe-code/scripts/check.sh` and `migrate.sh` encode SKILL.md's conventions.** If you add, rename, or move a session file or `context/` file in SKILL.md, update the hardcoded file lists in both scripts so the deterministic contract stays in sync with the prose.
- **`--save` never pushes.** Any edit that touches the save flow must preserve "local commit only." (Since v4.2 the save splits into atomic conventional commits — still local-only.)
- **Ideas come in through a grill, not a drip.** Candidate rules from other skills or from incident logs are batched, discussed (scope, conflicts with existing principles: Proportional Ceremony, six-file limit, never-blocking hooks, Scope Rule), and shipped as ONE release, dogfooded on a real project before push. Conflicting ideas are dropped, not bent in.
  - 5.0 shipped without a project dogfood by maintainer decision; replaced by script fixtures + adversarial read. (It was drafted as v4.17 and renumbered 5.0 because default behaviour changed: plain `/safe-code` is a light resume, the sweep moved to `--audit`.)
- **Public audience.** Shipped files (`skills/`, `README.md`, `TUTORIAL-*.md`, `integrations/`) are read by strangers: no personal names, client/project names, home paths, emails, or private memory systems; field incidents become one-clause generic rationales; tool names only as examples.
- **Tutorials are bilingual.** `TUTORIAL-EN.md` and `TUTORIAL-BM.md` are parallel; user-facing behavior changes should update both.
- **`docs/superpowers/{specs,plans}/`** hold dated design specs and implementation plans (spec-first workflow). A plan's steps are exact-string `Edit` + `grep`-verify pairs — follow them literally rather than paraphrasing.
