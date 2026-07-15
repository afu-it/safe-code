# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is the **source repository for the `safe-code` agent skill** and its helper skills. The "product" is prompt-engineered Markdown — `SKILL.md` files plus `references/` — that ship to other projects via `npx skills add afu-it/safe-code`. There is **no build, compile, bundler, or package manager**; nothing here is executed except the bash scripts in `scripts/`. Editing this repo means editing instructions an LLM will later follow, so prose precision, internal cross-references, and version consistency *are* the correctness surface.

> **Critical mental model — meta vs. consumer layout.** The `AGENTS.md` + `.safe-code/` + provider-bridge layout described in `README.md` is what the skill **produces inside a project that installs it**. It is **not** the layout of this repo. Do not scaffold `.safe-code/` here. This repo's own layout is `skills/`, `scripts/`, `references/`, and the docs below.

## Commands

There are no tests or linters in the usual sense. The deterministic contract is bash:

```bash
bash scripts/check.sh [project-root]      # verify safe-code conventions in a TARGET project
bash scripts/migrate.sh                    # preview legacy-layout migration (dry-run)
bash scripts/migrate.sh --apply [root]     # perform the migration (uses git mv when tracked)
bash scripts/check-version.sh              # MAINTAINER guard: assert version agrees across SKILL.md + README + examples
bash scripts/save-reminder.sh              # session-end hook helper (opt-in; see integrations/claude-code/)
```

- `check.sh` is the only thing that "fails" (exit 1) — and only on one hard check: a committed `.safe-code/context/current-issues.md` (it may hold secrets/logs). Everything else is an advisory warning. Both scripts locate the project root by walking up to the git toplevel / a safe-code marker, so they run against a *consumer* project, not this repo.
- To sanity-check skill edits there is no runner — verify by `grep` (the implementation plans in `docs/superpowers/plans/` use exact-string `grep` assertions as their test harness) and by reading the changed prose end-to-end.

## Architecture (the big picture)

**One orchestrator + seven analyze-first helpers.** `skills/safe-code/SKILL.md` (~955 lines) is the entry skill exposing three commands — `/safe-code` (setup / auto-resume / fresh pass), `/safe-code --continue` (explicit resume), `/safe-code --save` (finalize docs + **local commit only, never push**). It orchestrates helper skills in `skills/{senior-dev,build-graph,explore-codebase,codebase-pruner,safe-refactor-code,review-changes,debug-issue}/`. Helpers are dispatched by a **`$helper-name` convention written inline in SKILL.md** (e.g. `$debug-issue`, `$codebase-pruner`). Helpers analyze first and never make broad changes just because `/safe-code` ran.

**Three-layer context-economy loading** (`## Loading Layers` in SKILL.md) is the load-bearing design constraint:
- **Layer 1 (Entry)** — read every session.
- **Layer 2 (Resume)** — loaded on `--continue` / auto-continue when saved state exists.
- **Layer 3 (Detail)** — `skills/safe-code/references/*.md`, loaded only when a specific step triggers it.

Because of this, **never inline template bodies or long detail into `SKILL.md`** — put them in `references/` and point at them with a "Layer 3 Trigger" line. The reference files have specific ownership:
- `references/agents-md-authoring.md` — the **single source of truth** for how `AGENTS.md` is authored; helper skills defer to it.
- `references/doc-templates.md` — fallback shapes for every `.safe-code/` context + session file.
- `references/examples.md` — worked end-to-end runs and anti-patterns.
- `references/agent-config-audit.md` — patterns + High/Medium/Info classification for Step 4b (Agent Config Trust Audit), loaded only when that step runs.
- `references/save-procedure.md` — atomic-split mechanics, Last Session shapes, LOG trim procedure, per-file sync table; loaded on `--save`.
- `references/legacy-migration.md` — legacy detection list + per-location migration steps; loaded when a legacy layout is detected.
- `references/graph-integration.md` — `.mcp.json` bootstrap block + graph build sequence; loaded at Step 3f.
- `references/first-run.md` — First-Run Population table + Context Self-Test question set/grading; loaded on a first run or when the self-test triggers.

**The output contract the skill generates** (read `README.md` "Context + Session Docs" for the full picture): exactly two root artifacts in a consumer project — `AGENTS.md` (canonical entry) + a single `.safe-code/` folder holding `context/` (long-term project brain) and six session files (`ACTIVE`, `SESSION`, `LOG`, `BACKLOG`, `MEMORY`, `safe-refactor-code`). Thin provider-bridge pointers (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`) redirect each host to that same brain and hold no state. Every command auto-migrates legacy layouts (`.codex/agents`, v3 `.agents/` + root `context/`) into `.safe-code/`.

`.code-review-graph/graph.db` is the on-demand code-review knowledge graph the `build-graph` helper produces; it is gitignored via its own `.code-review-graph/.gitignore`.

## Conventions that span multiple files (get these right)

- **Version bumps are not single-edit.** A version string lives in five places that must move together: `SKILL.md` frontmatter `version:`, the Step 8 summary banner (`=== safe-code vX.Y session complete ===`), the `README.md` badge, the `README.md` "What's New" section, and the close-out banner in `skills/safe-code/references/examples.md`. A version change that only touches the frontmatter is incomplete — run `bash scripts/check-version.sh` (source of truth = `SKILL.md` frontmatter; it fails on any mismatch, including the examples banner) and grep the repo for the old number before considering it done. (`safe-refactor-code/SKILL.md` carries its own `metadata.version` and can lag intentionally.)
- **`scripts/check.sh` and `scripts/migrate.sh` encode SKILL.md's conventions.** If you add, rename, or move a session file or `context/` file in SKILL.md, update the hardcoded file lists in both scripts so the deterministic contract stays in sync with the prose.
- **`--save` never pushes.** Any edit that touches the save flow must preserve "local commit only." (Since v4.2 the save splits into atomic conventional commits — still local-only.)
- **Tutorials are bilingual.** `TUTORIAL-EN.md` and `TUTORIAL-BM.md` are parallel; user-facing behavior changes should update both.
- **`docs/superpowers/{specs,plans}/`** hold dated design specs and implementation plans (spec-first workflow). A plan's steps are exact-string `Edit` + `grep`-verify pairs — follow them literally rather than paraphrasing.
