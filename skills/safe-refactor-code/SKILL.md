---
name: safe-refactor-code
description: "Refactor code safely in small verified slices while keeping repo continuity docs in sync. Uses code-review graph tools for rename previews, impact radius, affected flows, and post-change review when available. Use when an agent is asked to refactor, restructure, clean up, remove or replace code, modernize modules, or do follow-up hygiene in a repo."
metadata:
  version: "4.0"
---

# Safe Refactor Code

Refactor code in small verified slices, then update the repo's continuity files so future agents can resume without rereading the whole session.

## Core Rules

- Treat `AGENTS.md` at repo root as the main long-term repo memory. Preserve existing content and update it carefully instead of rewriting blindly.
- Keep agent-local `MEMORY.md` short. It is a working summary for the repo, not a replacement for any shared or tool-managed memory system.
- Keep `safe-refactor-code.md` focused on the repo's refactor rules, guardrails, and recurring cleanup workflow.
- Update `.safe-code/CHANGELOG.md` on real code changes using today's section: `## [YYYY-MM-DD]`.
- Prefer additive or scoped edits to docs. Do not wipe user-written history unless the user explicitly asks.
- After refactors, scan for obvious dead code, unused imports, stale helpers, and outdated doc references before finishing.
- Use code-review graph tools when available. Fall back to direct source search and verification when graph tools are unavailable or empty.

## Graph-Aware Refactor Rules

- Start graph-assisted refactors with `get_minimal_context_tool(task="<refactor goal>")`.
- Update stale graphs with `build_or_update_graph_tool()` before broad refactors.
- For symbol renames, use `refactor_tool(mode="rename", old_name=<old>, new_name=<new>)` and inspect the preview before applying.
- Apply graph rename edits only with `apply_refactor_tool(refactor_id=<id>)` after preview review.
- For broad or shared-code changes, run `get_impact_radius_tool(detail_level="minimal")` before editing.
- For runtime path risk, run `get_affected_flows_tool()` before editing.
- For decomposition candidates, use `find_large_functions_tool()` or `refactor_tool(mode="suggest")`.
- For dead code exposed by the refactor, use `refactor_tool(mode="dead_code")`; delete only High-confidence candidates after config and dynamic-reference checks.
- Before final summary, run `detect_changes_tool(detail_level="minimal")` when graph tools are available.

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

This step is **mandatory**. Run it before reading or touching any code.

> **Canonical authoring rules:** When running under `safe-code`, the single source of truth for how to write `AGENTS.md` is the safe-code skill's `references/agents-md-authoring.md` (decision test, investigation order, what to extract/exclude, minimum quality bar). Follow it instead of improvising. The compact rules below are the standalone fallback when that reference is not available.

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

Regardless of `fresh` value, always update `AGENTS.md` before touching any code. This is not optional.

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

1. `get_minimal_context_tool(task="<refactor goal>")`
2. `build_or_update_graph_tool()` if the graph is empty or stale
3. `get_impact_radius_tool(detail_level="minimal")` for files or symbols likely to affect callers
4. `get_affected_flows_tool()` for changes that can affect runtime paths
5. `refactor_tool(mode="rename")`, `mode="suggest"`, or `mode="dead_code"` only when the operation matches the refactor goal

If graph tools fail, record the failure briefly and continue with `rg`, imports, manifests, tests, and direct source reads.

### 3. Refactor in Safe Slices

- Prefer one subsystem or concern at a time.
- Preserve behavior unless the user asked for a behavior change.
- Verify each slice with the narrowest useful checks available: lint, type-check, tests, build, or targeted probe.
- If a refactor exposes dead code, remove obvious leftovers in the same area when confidence is high.
- If cleanup risk is non-trivial or the repo has many stale modules, map blast radius before deleting and flag low-confidence candidates instead of auto-removing.

If widespread dead code is detected beyond the immediate refactor area, invoke the `codebase-pruner` skill for a full repo dead code audit.

### 4. Post-Change Review

Before syncing docs:

- Run `detect_changes_tool(detail_level="minimal")` if graph tools are available.
- Check `query_graph_tool(pattern="tests_for", target=<changed high-risk symbol>)` when graph risk or blast radius is non-trivial.
- Read changed files directly and remove accidental unused imports or stale exports.
- Run the narrowest useful verification command.

### 5. Sync Docs Before Finishing

After real code changes, update the continuity files in `.safe-code/` (and `AGENTS.md` at repo root):

- `AGENTS.md` (repo root) — current state, key decisions, blockers, handoff notes
- `safe-refactor-code.md` — repo-specific refactor constraints and recurring cleanup rules
- `MEMORY.md` — short current snapshot, active caveats, important paths
- `CHANGELOG.md` — today's dated section with Added, Changed, Fixed, Removed

### 6. Keep Changelog Shape Stable

Use this structure:

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
