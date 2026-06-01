# safe-code reference: AGENTS.md template + authoring rules

> Loaded on demand by `/safe-code` during Step 1 (Initialize Doc Structure).
> Canonical home for AGENTS.md authoring discipline. Helper skills defer here when run under safe-code.

### `<project-root>/AGENTS.md`

Use this as the fallback shape for missing or thin files. Preserve generated blocks and verified existing project guidance.

```md
# AGENTS.md

## Read First
Read these files in order before implementation or architectural decisions:
1. `context/project-overview.md`
2. `context/architecture.md`
3. `context/user-preferences.md`
4. `context/code-standards.md`
5. `context/ai-workflow-rules.md`
6. `context/ui-context.md` if UI/design work
7. `context/progress-tracker.md`
8. Active spec in `context/feature-specs/` when implementing a feature

Do not read `context/current-issues.md` unless the user explicitly asks for debugging/issue analysis or references that file.

## User Preference Detection
- Always notice strong user preference language in chat.
- Treat phrases like `I don't want`, `aku taknak`, `tak nak`, `I want`, `aku nak`, `please remove`, `remove this`, `I don't like`, `aku tak suka`, `I prefer`, `aku prefer`, `make it like this`, `jangan`, `must`, `always`, and `never` as preference candidates.
- If preference is explicit and durable, draft an update for `context/user-preferences.md` in `SESSION.md`.
- If preference affects current work, follow it immediately unless it conflicts with safety or repo evidence.
- If preference is ambiguous, ask once or add it to `context/progress-tracker.md` Open Questions on save.
- Do not bury durable preferences only in chat, `LOG.md`, or `progress-tracker.md`.

## Feature Specs
- Feature specs live in `context/feature-specs/`.
- AI may draft feature specs from user intent, repo evidence, and context files.
- Do not implement a feature until there is an active spec, unless the user explicitly asks for a tiny direct edit.
- For new projects, create specs in planned build order: `01-design-system.md`, `02-editor.md`, etc.
- For existing or in-progress projects, create specs only for upcoming work or unclear areas.
- Each spec must include goal, scope, likely touched areas, acceptance checks, and out-of-scope items.

## Session State
Read before resuming safe-code work:
- `.agents/ACTIVE.md`
- `.agents/SESSION.md`

## Project Facts
<!-- Exact commands, env vars, setup gotchas, package manager, non-obvious repo facts. -->

## Key Rules
- Never read or write outside the project root.
- Keep context updates drafted during work and finalized on `/safe-code --save`.
- Verify before claiming completion.
- Do not commit or publish `context/current-issues.md`.
```

When creating, populating, or reconciling `AGENTS.md`, do not fill the template blindly. Follow authoring rules below.

---

#### AGENTS.md authoring rules (agent init style)

Create or update `AGENTS.md` for this repository.

The goal is a compact instruction file that helps future agent sessions avoid mistakes and ramp up quickly. Follow these rules instead of improvising.

If the user provides focus or constraints in the `/safe-code` request, honor them while still verifying facts from the repo. Examples: "focus on onboarding agents", "document test commands", "preserve Claude/Cursor rules", or "do not mention deployment".

**Decision test for every line**

- Every line must answer: "Would an agent likely miss this without help?" If not, leave it out.
- Prefer a smaller but accurate file over a long, vague one.

**How to investigate**

Always investigate the repo before editing `AGENTS.md`. Read the highest-value sources first, stopping when you have enough signal:

- `README*`, root manifests, workspace config, and lockfiles
  (for example: `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `pnpm-lock.yaml`, `bun.lockb`).
- Build, test, lint, formatter, typecheck, and codegen config
  (for example: `next.config.*`, `vite.config.*`, `tsconfig.json`, `eslint*`, `prettier*`, `tailwind.config.*`, `postcss.config.*`).
- CI workflows, pre-commit hooks, and task runners
  (for example: `.github/workflows`, `.husky/`, `.lintstagedrc*`, `lefthook.yml`, `justfile`, `Makefile`, `flake.nix`, Git hooks, monorepo task tools).
- Existing instruction files
  (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`, or equivalents).

If architecture is still unclear after reading config and docs, inspect a **small** number of representative code files to find the real entrypoints, package boundaries, and execution flow. Prefer files that explain how the system is wired together over random leaf files.

**Source-of-truth rule**

- Prefer executable sources of truth over prose. If docs conflict with scripts or config, trust the executable source.
- Do not document anything you could not verify directly from the repo or from clearly trustworthy instruction files.

**What to extract**

Focus on high-signal facts that materially change how an agent should work in this repo:

- Exact developer commands, especially non-obvious ones
  (dev, build, lint, typecheck, unit tests, integration tests, migrations, codegen, seeding).
- Missing expected commands when that absence matters
  (for example: no `test` script, no `typecheck` script, no migration command wrapper).
- How to run a single test, a single package, or a focused verification step.
- Required command order when it matters (for example: `lint → typecheck → test`).
- Setup prerequisites and required environment variables, especially database URLs, auth secrets, API keys, local services, and seed data.
- Monorepo or multi-package layout: package boundaries, major directories, and real app/library entrypoints.
- Framework or toolchain quirks: generated code, migrations, codegen outputs, build artefacts, special env loading, dev server behaviour, infra deploy flow.
- Repo-specific style or workflow conventions that differ from common defaults.
- Testing quirks: fixtures, integration test prerequisites, required services, snapshot workflows, slow or flaky suites.
- Important constraints from existing instruction files that are still correct and useful.

Good AGENTS.md content is hard-earned context that usually required reading multiple files to infer.

**What to exclude**

Do **not** put these into `AGENTS.md`:

- Generic language or framework advice.
- Long tutorials, how-tos, or exhaustive file trees.
- Obvious conventions that any competent developer or model would already know.
- Speculative statements, guesses, or anything not verified from the repo.
- Content that belongs in another dedicated document already referenced from config.
- Tool-specific config files unless they matter to universal agent handoff.

When in doubt, omit.

**Behaviour when AGENTS.md is missing vs existing**

- If `AGENTS.md` is **missing**, effectively empty, or thin:
  - Create or repopulate it using the authoring rules above and the template as a fallback shape.
  - Include only sections backed by real, verified project details from the investigation above.
  - Preserve any existing generated comment blocks at the top and append your sections after them.
  - Ensure the result is useful as a first-read handoff for another AI agent without requiring it to inspect every config file first.
- If `AGENTS.md` already contains real project context:
  - Improve it in place rather than rewriting blindly.
  - Preserve guidance that is still correct and high-signal.
  - Delete or rewrite content that is clearly stale, generic, or contradicted by the current codebase.
  - Reconcile differences in favour of executable sources (config, scripts, CI) while keeping any still-valid nuance from older instructions.
  - Add missing high-signal facts discovered during investigation, even when the existing file is not empty.
  - Do not report "AGENTS.md already has real project context, so it was not rewritten" as the decision. The required decision is whether it was `reconciled` or audited and `unchanged`, with a short reason.

**Minimum quality bar after writing**

Before marking `AGENTS.md` done, verify it answers these for the current repo:

- What is this project and who/what uses it?
- What exact commands should an agent run for dev, build, lint, typecheck, tests, migrations, codegen, or seeds when those exist?
- What expected commands are intentionally absent or must be run through `npx`/tooling instead?
- What env vars, local services, databases, or setup prerequisites are required?
- What verification order should an agent use before claiming work is done?
- What are the true runtime/framework/database/auth/i18n/styling/package-manager facts?
- What directories and files are real entrypoints or source-of-truth wiring?
- What repo-specific gotchas would an agent likely miss without this file?
- Are any existing `AGENTS.md` claims contradicted by executable sources?
- What existing instruction files or generated blocks must be preserved?

If two or more answers are missing and discoverable from the repo, keep editing `AGENTS.md`; do not mark it `unchanged`, and do not finish with only a one-line reconciliation.

If any existing `AGENTS.md` claim is contradicted by executable sources, fix that claim before finishing even when the file is otherwise compact and useful.

**Questions to the user**

- Only ask the user questions if the repo genuinely cannot answer something important:
  - Undocumented team conventions or policies.
  - Branch / PR / release expectations.
  - Setup or test prerequisites that are known but not written down.
- Ask at most one short batch of questions if needed.
- Do **not** ask about anything the repo already makes clear.

**Length and density**

- For small repos, keep `AGENTS.md` short but ensure all critical commands, structure, and constraints are covered.
- For larger repos, summarize only the structural facts and workflows that actually change how an agent should work.
- Prefer short sections and bullets over long paragraphs.

