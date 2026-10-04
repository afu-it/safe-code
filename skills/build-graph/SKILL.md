---
name: build-graph
description: Build or update the codegraph code index for the current repository. Use before safe-code audits, refactors, reviews, debugging, or when the index may be stale.
argument-hint: "[full]"
---

# Build Graph

Build or incrementally update the persistent code index (codegraph, `.codegraph/` in the project root) for the current repository.

## Core Rules

- The tool is the `codegraph` CLI (npm `@colbymchenry/codegraph`). Check `codegraph --help` once; a missing subcommand -> skip it, never invent flags.
- Missing CLI -> do not install here. Report `Graph: unavailable` and let `/safe-code` handle the one-time install question (see the safe-code skill's `references/graph-integration.md`).
- Writes only `<project-root>/.codegraph/` (self-gitignored). Never run `codegraph install` unless the user answered yes to safe-code's one-time install question, and then only `--target <this agent> --location global --yes` (never `--target all`); never `uninstall`. Otherwise print the command (safe-code `references/graph-integration.md`).
- Telemetry: on first use in a session, print once: "codegraph sends anonymous usage stats; turn off with `codegraph telemetry off` or `DO_NOT_TRACK=1`." Never set it for the user.
- If the index cannot be built, do not block the parent workflow. Report it and continue with manual repo inspection.

## Workflow

1. No `.codegraph/` -> `codegraph init -y` from the project root (full build) — only when invoked to build (`/safe-code --codegraph`, or Step 3f with graph evidence in scope); an existing index is synced, never re-initialised.
2. `.codegraph/` exists -> `codegraph sync` (incremental). `full` argument, branch switch, or obviously wrong results -> `codegraph index` (full rebuild).
3. "Index is locked" from a crashed run -> `codegraph unlock`, retry once.
4. Verify with `codegraph status`: files, nodes, edges, languages, "Index is up to date".
5. Report build status and any language coverage gaps.

## Output

```text
Graph: <ready | stale | unavailable | partial>   (safe-code Step 8 vocabulary)
Files: <count>
Nodes: <count>
Edges: <count>
Languages: <list>
Notes: <coverage gaps, or fallback used: manual>
```
