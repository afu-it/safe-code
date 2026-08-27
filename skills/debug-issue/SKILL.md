---
name: debug-issue
description: Systematically debug issues using graph-powered code navigation, recent-change detection, affected flows, and targeted verification.
---

# Debug Issue

Use the graph to trace suspected code paths and recent changes before editing.

## Core Rules

- Start with `get_minimal_context_tool(task="<bug or symptom>")`.
- Use graph navigation to find suspects, then read source files directly.
- Prefer one hypothesis at a time with a targeted verification command.
- If graph tools are unavailable, fall back to `rg`, tests, logs, and runtime probes.

## Workflow

0. Contention check first: another process/agent/worktree/tool on the same branch, DB, port, or session? (`git worktree list`, `lsof -i :<port>`, ask the user "is another tool on this?") — rule it out before any code hypothesis.
1. Search related symbols with `semantic_search_nodes_tool()`.
2. Trace callers and callees with `query_graph_tool(pattern="callers_of"|"callees_of")`.
3. Check entry paths with `get_affected_flows_tool()` or `get_flow_tool()`.
4. Run `detect_changes_tool()` when the bug may be regression-related.
5. Use `get_impact_radius_tool()` before patching suspected shared code.
6. Patch only the smallest confirmed cause.
7. Verify with focused tests, lint, type-check, or a targeted runtime probe.

## Output

Lead with:

- root cause
- changed files
- verification run
- remaining risk or missing coverage
