---
name: codebase-pruner
description: Scan an entire codebase to detect and safely remove dead code such as unused functions, orphaned modules, unreferenced exports, stale configs, dead routes, and leftover workflow artifacts. Use when asked to clean up dead code, remove unused code, prune stale files, find orphaned modules, audit codebase bloat, or delete code left behind after a workflow or architecture change.
---

# Codebase Pruner

Audit a repo for dead code, estimate deletion risk, and remove only high-confidence candidates in small verified slices. Reason from real entrypoints, config references, and runtime wiring instead of guessing from filenames.

## Core Rules

- Treat dead code as code with no live path from any entrypoint, config reference, or runtime hook.
- Map references before deleting anything. One missed reference invalidates the deletion.
- Prefer `Audit` first. Use `Execute` only after the dead-code inventory is clear enough to act safely.
- If a candidate has dynamic dispatch risk, reflection risk, or external integration risk, flag it instead of deleting it automatically.
- Never delete generated files. Update the generator or generated output flow instead.
- Never mix pruning with unrelated feature work or refactors.
- Prefer narrow, reversible slices with verification after each slice.
- Use code-review graph tools when available. Treat graph output as evidence, not permission to delete.

## Graph-Aware Audit Path

Use this path before manual scanning when graph tools are available:

1. `get_minimal_context_tool(task="dead code audit")`
2. `build_or_update_graph_tool()` if the graph is empty or stale
3. `refactor_tool(mode="dead_code")` for unreferenced functions and classes
4. `query_graph_tool(pattern="importers_of", target=<file or module>)` for orphaned modules
5. `query_graph_tool(pattern="callers_of", target=<symbol>)` for functions and methods
6. `get_impact_radius_tool(detail_level="minimal")` before deleting any shared file
7. `detect_changes_tool(detail_level="minimal")` after edits

If graph tools are unavailable, empty, or fail, continue with the manual entrypoint and reference graph workflow below. Do not lower deletion confidence because graph data is missing.

## Step 0: Locate Doc Folder

Session and continuity docs live in a single agent-agnostic folder at the repo root:

```
doc folder = <repo-root>/.safe-code/
```

No agent detection is needed. Codex, Claude, Cursor, and Windsurf all share the same `.safe-code/` folder so continuity belongs to the repo, not the tool. Create `<repo-root>/.safe-code/` if it does not exist yet.

When flagging candidates that are not auto-deleted, write a note into `.safe-code/safe-refactor-code.md` so future agents do not rediscover the same uncertain candidates from scratch.

`AGENTS.md` at repo root is always updated when significant dead code is found or removed.

When running under safe-code, follow safe-code's Draft-Until-Save timing: draft these notes (and any `AGENTS.md` updates) in `.safe-code/SESSION.md` and let `/safe-code --save` apply them. Direct writes to `safe-refactor-code.md` and `AGENTS.md` are standalone behavior only.

## Modes

### Audit
Scan and report only. Produce a prioritized dead-code inventory with confidence and blast radius. This is the default mode.

### Dry-Run
Produce a deletion plan with ordered slices, rollback points, and verification commands. Do not edit files.

### Execute
Delete high-confidence candidates slice by slice with verification after each slice. Stop on failure.

### Targeted
Run the same workflow, but scoped to a file, directory, module, or subsystem.

## Workflow

### 1. Clarify Scope Only When Needed

Ask a question only if the scope is materially ambiguous. Otherwise discover the answers locally.

Resolve these questions if they matter:

- full repo or targeted area
- whether intentionally-unused compatibility code exists
- whether tests, fixtures, generated files, and build artifacts are in scope
- whether config files such as CI, Docker, cron, and env wiring are in scope

### 2. Map Live Entrypoints First

Build the list of roots before scanning for dead code.

Check these entrypoint classes:

- application entry files such as `main`, `server`, `index`, or CLI entry scripts
- framework-loaded files such as routes, middleware, plugins, and hooks
- `package.json` scripts, package exports, and bin entries
- test runner entry files when test-only code is relevant
- config-driven entrypoints from Dockerfiles, compose files, CI workflows, cron jobs, reverse proxies, and deploy scripts

If a file is named in config, treat that as a live reference until proven otherwise.

### 3. Build the Reference Graph

Traverse imports, requires, includes, re-exports, and config references from every entrypoint.

When a code-review graph is available, combine its candidates with manual evidence:

- Graph "no callers" plus no config or dynamic references -> possible High confidence.
- Graph "no callers" but dynamic dispatch, registry, route loader, reflection, package export, or config mention -> Medium or Low.
- Manual references found outside graph -> not dead until reconciled.
- Graph impact radius > 10 files -> stop and report before deletion.

For each candidate, classify it as:

- `Live`: reachable from an entrypoint or config reference
- `Dead (confirmed)`: no live path and no meaningful dynamic-reference risk
- `Dead (suspected)`: no static path found, but dynamic or external-reference risk exists
- `Excluded`: generated files, vendored dependencies, build output, or other out-of-scope material

Do not treat string-built imports, event registries, reflection-heavy systems, or plugin loaders as safe deletion targets unless you can prove they are unused.

### 4. Classify Candidate Type

Common categories:

- orphaned modules
- unused exports
- dead functions
- stale routes
- legacy adapters
- commented-out blocks
- stale configs
- orphaned tests
- abandoned feature flags
- dead env vars

This helps order the work from safest to riskiest.

### 5. Estimate Blast Radius

For every candidate:

1. Search for direct references.
2. Search for indirect references such as re-exports, dynamic names, reflection, generated references, and config mentions.
3. Count the affected files or systems.
4. Classify blast radius:
   - `Zero`: nothing references it
   - `Local`: same module only
   - `Cross-module`: multiple subsystems
   - `External`: referenced by config, CI, Docker, or outside consumers

When blast radius is not zero, update callers first and delete only after the updated graph is clean.

### 6. Score Confidence

Use these deletion thresholds:

- `High`: zero references, no dynamic risk, no config mentions
- `Medium`: zero static references, but dynamic patterns exist nearby
- `Low`: only weak evidence such as string mentions, docs, or naming collisions

Only auto-delete `High` confidence candidates in `Execute` mode. Flag `Medium` and `Low` unless the user explicitly asks for a riskier pass.

### 7. Plan Slices

Express removals as small, ordered slices. Each slice must include:

- narrow goal
- touched files
- preserved invariant
- verification command
- rollback action

Preferred order:

1. commented-out blocks
2. orphaned tests for already-deleted modules
3. unused exports within a module
4. dead functions within a module
5. orphaned modules
6. stale routes
7. legacy adapters
8. stale configs

Do not combine multiple risky categories into one slice.

### 8. Run the Pre-Delete Check

Before deleting a slice, verify:

- the worktree state is understood
- the candidate was scanned against the full relevant graph
- graph callers/importers/impact were checked when graph tools are available
- generated references were refreshed if needed
- the candidate is not part of a package export, plugin registry, deploy script, or runtime registration path

If the worktree is dirty and deletion would be risky, prefer `Audit` or `Dry-Run` unless the user clearly wants execution on top of local changes.

### 9. Execute With Verification

After each slice:

1. run the narrowest useful verification
2. fix one clear follow-up issue if the deletion exposed something small
3. stop if the slice does not stabilize quickly

Prefer checks such as:

- lint
- type-check
- targeted tests
- focused build or compile probe
- targeted runtime/manual probe when automation is absent

If verification fails and the issue is not immediately repairable, roll back that slice only and report the blocker.

### 10. Summarize Clearly

Return:

- active agent detected and doc folder used
- files scanned and entrypoints mapped
- candidates found by category and confidence
- removals completed
- flagged candidates not removed and why
- verification run per slice
- remaining risks or dynamic-reference uncertainties

## Output Shapes

### Audit Output

```text
Doc folder: .safe-code/
Entrypoints mapped: 7
Files scanned: 184

Dead code inventory:
[HIGH] Orphaned module: src/adapters/old-client.ts - no live imports or config references
[HIGH] Dead function: src/utils/date.ts:legacyFormatDate - 0 callers
[MEDIUM] Suspected dead: src/handlers/webhook-v1.ts:handleEvent - dynamic dispatch risk
[LOW] Stale env var: OLD_REDIS_URL - not read in scanned files

Total confirmed dead: 2
Total suspected dead: 2
Recommended next step: Dry-Run
```

### Dry-Run Output

```text
Removal plan:
Slice 1 - Remove commented-out blocks in src/utils/date.ts
  Files: src/utils/date.ts
  Invariant: no behavior change
  Verification: npm run lint
  Rollback: restore touched file from VCS or local backup

Slice 2 - Remove orphaned module src/adapters/old-client.ts
  Files: src/adapters/old-client.ts
  Invariant: no live caller exists
  Verification: import scan + npm run lint
  Rollback: restore touched file from VCS or local backup

Flagged for manual review:
  src/handlers/webhook-v1.ts:handleEvent - dynamic dispatch risk
  → noted in .safe-code/safe-refactor-code.md
```

### Execute Output

```text
Slice 1 complete: removed commented-out blocks in src/utils/date.ts
  Verification: lint passed

Slice 2 complete: removed src/adapters/old-client.ts
  Verification: lint passed, import scan clean

Summary:
  Agent: docs saved to .safe-code/
  Removed: 1 file, 1 function, 5 commented blocks
  Flagged: 1 candidate (noted in .safe-code/safe-refactor-code.md)
```

## Hard Rules

- Never delete a file with unresolved dynamic-reference risk without explicit user approval.
- Never delete generated files.
- Never delete a module exposed via package exports or public API without verifying consumer risk.
- Never delete code named by CI, Docker, cron, deploy scripts, or runtime config without checking those references directly.
- Never continue past a failing verification.
- Never assume "unused today" means safe to remove; check runtime wiring and recent intent where relevant.

## Escalation

If widespread dead code appears beyond the user's requested area, switch to full-repo `Audit` mode before deleting more. Always note flagged but unremoved candidates in `.safe-code/safe-refactor-code.md` so future agents do not rediscover the same uncertain candidates from scratch.
