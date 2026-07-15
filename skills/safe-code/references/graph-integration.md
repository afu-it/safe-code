# safe-code reference: graph integration (Step 3f detail)

> Loaded on demand by Step 3f (Layer 3). The binding rules — accelerator never overrides
> safety, project-local `.mcp.json` only, graceful manual fallback — live inline in
> SKILL.md; this file holds the detection order, bootstrap block, and call sequence.

## Detection and bootstrap

1. Detect graph access:
   - MCP graph tools already available
   - `code-review-graph` command available
   - `uvx` command available
   - existing `<project-root>/.mcp.json`
2. If MCP graph tools are missing but `uvx` exists, auto-create or update project-local `.mcp.json`:

   ```json
   {
     "mcpServers": {
       "code-review-graph": {
         "command": "uvx",
         "args": ["code-review-graph", "serve"]
       }
     }
   }
   ```

   Preserve existing MCP servers when updating `.mcp.json`.
3. If `code-review-graph` is installed locally but MCP tools are not exposed, record `Graph: command available` and continue with manual scans for this run — no CLI call sequence is defined for this skill, so do not invent one. The bootstrapped `.mcp.json` exposes the MCP tools in the next session.
4. Do not run `pipx install`, edit global MCP files, or write outside the project root automatically.

## Build sequence (when MCP graph tools are available)

Automatically run `$build-graph`:

- `get_minimal_context_tool(task="safe-code hygiene pass")`
- `build_or_update_graph_tool()` if the graph is stale or empty
- `list_graph_stats_tool()` to confirm files, nodes, edges, and languages

## Fallback and partial coverage

- If graph tools are unavailable, empty, or fail, record `Graph: unavailable` and continue with manual scans.
- If graph coverage is partial, use graph findings only for covered languages and keep manual entrypoint/config checks.
