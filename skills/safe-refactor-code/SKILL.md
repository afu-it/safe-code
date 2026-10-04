---
name: safe-refactor-code
description: "Refactor code safely in small verified slices while keeping repo continuity docs in sync. Uses the codegraph index for callers, impact radius, and affected tests when available. Use when an agent is asked to refactor, restructure, clean up, remove or replace code, modernize modules, or do follow-up hygiene in a repo."
metadata:
  version: "4.1"
---

# Safe Refactor Code

Refactor code in small verified slices, then update the repo's continuity files so future agents can resume without rereading the whole session.

## Core Rules

- Treat `AGENTS.md` at repo root as the main long-term repo memory. Preserve existing content and update it carefully instead of rewriting blindly.
- Keep agent-local `MEMORY.md` short. It is a working summary for the repo, not a replacement for any shared or tool-managed memory system.
- Keep `safe-refactor-code.md` focused on the repo's refactor rules, guardrails, and recurring cleanup workflow.
- `.safe-code/CHANGELOG.md`: under safe-code, only releasable changes, in safe-code's Keep-a-Changelog template (`## [Unreleased]` + typed subsections; the file is created on the first releasable change). Standalone, use today's dated section (`## [YYYY-MM-DD]`, below).
- Prefer additive or scoped edits to docs. Do not wipe user-written history unless the user explicitly asks.
- After refactors, scan for obvious dead code, unused imports, stale helpers, and outdated doc references before finishing.
- Use the codegraph index when available. Fall back to direct source search and verification when it is unavailable or empty.

## Graph-Aware Refactor Rules

- Start graph-assisted refactors with `codegraph explore "<refactor goal>"` (or `codegraph_explore`).
- Run `codegraph sync` before broad refactors (`$build-graph` when no index exists).
- Symbol renames have no graph preview: list `codegraph callers <old>` and `codegraph impact <old>` first, edit, then confirm with `rg "<old>"` -> 0 hits (plus a positive control on the new name).
- For broad or shared-code changes, run `codegraph impact <symbol>` before editing.
- For dead code exposed by the refactor, `codegraph callers <symbol>` empty is a candidate only (it resolves by name); delete only High-confidence candidates after `rg`, config, and dynamic-reference checks.
- Before final summary, run `codegraph sync` + `codegraph affected <changed files>` and run the tests it lists.

## Agent Compatibility

- Write this skill so any AI agent can follow it, not only one product or runtime.
- Prefer generic terms such as "agent", "current repo", and "available verification tools".
- If the host environment has its own global or shared memory system, treat that as separate from repo-local docs.
- If the current repo uses different handoff files, adapt carefully but preserve the same responsibilities.

## Step 0: Locate Doc Folder

Session and continuity docs live in a single agent-agnostic folder at the repo root:

```
doc folder = <repo-root>/.safe-code/
```

No agent detection is needed. Codex, Claude, Cursor, and Windsurf all share the same `.safe-code/` folder so continuity belongs to the repo, not the tool. Create `<repo-root>/.safe-code/` if it does not exist yet.

Doc file locations:

| File | Path |
|---|---|
| `AGENTS.md` | repo root (always) |
| `MEMORY.md` | `.safe-code/MEMORY.md` |
| `CHANGELOG.md` | `.safe-code/CHANGELOG.md` |
| `safe-refactor-code.md` | `.safe-code/safe-refactor-code.md` |

## Step 0.5: Assess and Write AGENTS.md

This step is **mandatory**. Run it before reading or touching any code — except under `/safe-code`: when that run already reconciled `AGENTS.md` (Step 3d: created, populated, reconciled, or audited `unchanged`), that reconciliation satisfies this step; do not repeat it.

> **Canonical authoring rules:** When running under `safe-code`, the single source of truth for how to write `AGENTS.md` is the safe-code skill's `references/agents-md-authoring.md` (decision test, investigation order, what to extract/exclude, minimum quality bar). Follow it instead of improvising. The compact rules below are the standalone fallback when that reference is not available.

> **Timing under safe-code:** when this skill runs under `/safe-code`, AGENTS.md *content* updates follow safe-code's Draft-Until-Save (draft in `.safe-code/SESSION.md`, apply on `/safe-code --save`; First-Run Population excepted). The mandatory-immediate write below applies when running standalone.

### Detect if AGENTS.md is effectively empty

Treat `AGENTS.md` as effectively empty if it contains **only**:
- HTML comment blocks `<!-- BEGIN:xxx --> ... <!-- END:xxx -->`
- Blank lines
- Auto-generated rules injected by tooling

Do not treat generated blocks as agent or human-written state. They are tooling artifacts, not project context.

### Detect project freshness

```
if AGENTS.md is missing OR effectively empty
    → fresh = true   (full project scan required)

if AGENTS.md has existing agent-written or human-written state sections
    → fresh = false  (update affected sections only)
```

### Write AGENTS.md — no skipping allowed

Regardless of `fresh` value, always update `AGENTS.md` before touching any code. This is not optional — standalone. Under `/safe-code`, the AGENTS.md reconciliation that run already did satisfies it (see above).

**If `fresh = true`**, scan the project and write a full orientation snapshot:

- **Stack** — languages, frameworks, major dependencies with versions if available
- **Folder structure** — key directories and what they own
- **Key files** — entry points, config files, critical modules
- **Conventions** — naming patterns, coding style, file organisation rules
- **Gotchas** — anything non-obvious a future agent must know before editing

Preserve any existing generated blocks (`<!-- BEGIN:xxx -->`). Append the orientation snapshot after them — do not replace or remove tooling-injected content.

**If `fresh = false`**, update only the sections relevant to the upcoming refactor. Preserve all existing content outside those sections.

> `AGENTS.md` is the primary handoff document for any future agent entering this repo in a new context. Never skip this step.

## Workflow

### 1. Read Continuity Files First

After writing `AGENTS.md`, inspect these files when present:

- `AGENTS.md` at repo root (already written in Step 0.5)
- `.safe-code/safe-refactor-code.md`
- `.safe-code/MEMORY.md`
- `.safe-code/CHANGELOG.md`

If one is missing, create it only if the refactor work makes it useful.

Fallback for missing `AGENTS.md`:

- Prefer an existing equivalent file such as `CLAUDE.md`, `GEMINI.md`, or another repo handoff guide at root.
- If an equivalent exists, treat it as the main continuity document for this run.
- If no equivalent exists, create `AGENTS.md` only when the refactor changes architecture or handoff risk enough that future agents would benefit.

### 2. Plan With Graph Context When Available

Use this order:

1. `codegraph explore "<refactor goal>"`
2. `codegraph sync` if the index is stale (`$build-graph` if none exists)
3. `codegraph impact <symbol>` for files or symbols likely to affect callers
4. `codegraph callers|callees <symbol>` for changes that can affect runtime paths

If codegraph fails, record the failure briefly and continue with `rg`, imports, manifests, tests, and direct source reads.

### 3. Refactor in Safe Slices

- Prefer one subsystem or concern at a time.
- Preserve behavior unless the user asked for a behavior change.
- Verify each slice with the narrowest useful checks available: lint, type-check, tests, build, or targeted probe.
- If a refactor exposes dead code, remove obvious leftovers in the same area when confidence is high.
- If cleanup risk is non-trivial or the repo has many stale modules, map blast radius before deleting and flag low-confidence candidates instead of auto-removing.
- A refactor claimed to be "faster" or "lighter" needs a before-baseline measured under the same conditions; without one, report the claim as a hypothesis. "Fewer lines" is not performance evidence.
- Undo a slice by re-editing or from a backup; no destructive git in a checkout that may be shared — follow the safe-code skill's `references/multi-session.md` (Shared-checkout rules).

If widespread dead code is detected beyond the immediate refactor area, invoke the `codebase-pruner` skill for a full repo dead code audit.

### 4. Post-Change Review

Before syncing docs:

- Run `codegraph sync` + `codegraph affected <changed files>` if an index is available, and run the tests it lists when blast radius is non-trivial.
- Read changed files directly and remove accidental unused imports or stale exports.
- Run the narrowest useful verification command.

### 5. Sync Docs Before Finishing

After real code changes, update the continuity files in `.safe-code/` (and `AGENTS.md` at repo root). When running under safe-code, draft these updates in `.safe-code/SESSION.md` instead and apply them on `/safe-code --save`:

- `AGENTS.md` (repo root) — current state, key decisions, blockers, handoff notes
- `safe-refactor-code.md` — repo-specific refactor constraints and recurring cleanup rules
- `MEMORY.md` — short current snapshot, active caveats, important paths
- `CHANGELOG.md` — releasable changes only; under safe-code the Keep-a-Changelog template, standalone today's dated section

### 6. Keep Changelog Shape Stable

Under safe-code, follow its Keep-a-Changelog template (the safe-code skill's `references/doc-templates.md`) and add entries only for releasable changes. Standalone, use this dated structure:

```md
## [YYYY-MM-DD]

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...
```

- Reuse today's section if it already exists.
- Omit empty subsections when nothing belongs there.
- Do not add a changelog entry for read-only review or analysis turns.

### 7. Finish With a Hygiene Pass

Before closing:

- Remove unused imports introduced by the refactor.
- Remove helpers, exports, or files made dead by the refactor when confidence is high.
- Update stale file/path references in docs.
- Note any flagged but unremoved dead code in `safe-refactor-code.md` or `AGENTS.md`.

## What To Write

### `AGENTS.md` (repo root)

Update only the sections affected by the refactor. Prefer:

- Current repo state
- Important architectural decisions
- Known blockers or caveats
- Where future agents should start

### `safe-refactor-code.md`

Use this file for repo-specific refactor instructions such as:

- Safe areas to touch
- Dangerous files or generated outputs
- Required verification commands
- Cleanup conventions
- Recurring migration or sync pitfalls

### `MEMORY.md`

Keep this concise. Good contents:

- Active architecture snapshot
- Current source-of-truth files
- Known temporary workarounds
- Top follow-up items

### `CHANGELOG.md`

Record only meaningful repo changes. Keep entries user-facing and concise.

## Triggers

Typical requests that activate this skill:

- "safe refactor this repo"
- "clean up after this refactor"
- "update agents and changelog too"
- "remove dead code after changing this flow"
- "keep repo memory in sync while refactoring"
- "make this refactor safer for future agents"

## Design Vocabulary (use these terms exactly)

- **module** · **interface** (everything a caller must know — invariants, ordering, error modes — not just the signature) · **depth** (behaviour per unit of interface) · **seam** · **adapter** · **leverage** · **locality**.
- **Deletion test** for a suspected shallow module: imagine deleting it. If complexity vanishes, it was a pass-through — remove it. If complexity reappears across N callers, it earns its keep.
- One adapter is a hypothetical seam; two adapters is a real one. The interface is the test surface — needing to test past it means the module is the wrong shape.

