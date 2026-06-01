---
name: explore-codebase
description: Navigate and understand codebase structure using the code-review graph. Use for repo orientation, AGENTS.md authoring, architecture mapping, or finding relevant code.
---

# Explore Codebase

Use the code-review graph to understand the repository before editing.

## Core Rules

- Always start with `get_minimal_context_tool(task="<your task>")`.
- Use `detail_level="minimal"` unless more detail is needed.
- Prefer graph results for architecture, communities, flows, hubs, bridges, and impact paths.
- If graph tools are unavailable or empty, continue with `rg`, manifests, README files, and config inspection.

## Workflow

1. Get compact context with `get_minimal_context_tool`.
2. Build or update the graph if it is empty or stale.
3. Use `get_architecture_overview_tool()` for major boundaries.
4. Use `list_communities_tool(detail_level="minimal")` to identify modules.
5. Use `list_flows_tool(detail_level="minimal")` for execution paths.
6. Use `get_hub_nodes_tool()` and `get_bridge_nodes_tool()` for risky chokepoints.
7. Use `semantic_search_nodes_tool()` or `query_graph_tool()` to narrow to specific symbols.

## AGENTS.md Use

When helping safe-code write or reconcile `AGENTS.md`, follow the canonical authoring rules in the safe-code skill's `references/agents-md-authoring.md` (decision test, investigation order, what to extract/exclude). This skill's job is to supply graph-backed facts that feed those rules, not to define a separate authoring process.

Prefer graph-backed facts:

- major communities and files
- entry points and flows
- hub or bridge files that need caution
- languages detected by the graph
- missing tests or untested hotspots from knowledge-gap tools

Do not copy raw graph dumps into docs. Convert them into compact handoff facts.
