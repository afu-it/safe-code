---
name: build-graph
description: Build or update the code review knowledge graph. Use before safe-code audits, refactors, reviews, debugging, or when the graph may be stale.
argument-hint: "[full]"
---

# Build Graph

Build or incrementally update the persistent code knowledge graph for the current repository.

## Core Rules

- Start with `get_minimal_context_tool(task="build graph")` when available.
- Use `build_or_update_graph_tool()` for normal updates.
- Use `build_or_update_graph_tool(full_rebuild=True)` for first setup, branch switches, parser failures, or obviously stale graph state.
- Verify with `list_graph_stats_tool()` after building.
- If graph tools are unavailable, do not block the parent workflow. Report the missing graph and continue with manual repo inspection.

## Workflow

1. Check graph status with `list_graph_stats_tool()`.
2. If the graph has no files, nodes, edges, or last update, run a full build.
3. Otherwise run an incremental update.
4. Verify files, nodes, edges, languages, and update time.
5. Report build status and any parse or language coverage gaps.

## Output

```text
Graph: <built|updated|unavailable>
Files: <count>
Nodes: <count>
Edges: <count>
Languages: <list>
Notes: <parse gaps or fallback used>
```
