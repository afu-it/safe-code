# safe-code reference: graph integration (Step 3f + --graphify detail)

> Loaded on demand by Step 3f and by `/safe-code --graphify` (Layer 3). The binding rules
> — accelerator never overrides safety, project-local `.mcp.json` only, graceful manual
> fallback, graphify only on its explicit flag — live inline in SKILL.md; this file holds
> the detection orders, bootstrap block, call sequences, and the graphify harvest mapping.

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

---

## Graphify Pipeline (`/safe-code --graphify` detail)

### Detection order (first hit wins)

1. `$graphify` skill available on the host -> dispatch it as a helper with the project root (build) or the question (query); it manages its own pipeline and outputs. **Identity check first**: only dispatch if the skill's own description matches the knowledge-graph purpose (maps input into a queryable knowledge graph); a same-named skill that describes something else is a name collision — skip to branch 2.
2. `graphify` CLI on PATH (`command -v graphify`) -> drive the CLI directly.
3. `uv` available but no graphify -> offer ONCE: `uv tool install graphifyy` (yes, two y's — that is the real PyPI name; do not "correct" it to a different package). The `--graphify` flag is user intent, but installing a PyPI package is a supply-chain decision — ask before the first install and record accept/decline in `user-preferences.md` (a recorded decline is durable: suggest manual install instead of re-offering). **Cannot ask this session (autonomous/non-interactive)** -> treat as declined *for this run only*: do NOT install, do NOT record anything in `user-preferences.md`, fall through to branch 4.
4. None of the above -> record `Graphify: unavailable`, print the install hint, and continue the run without it.

### Build sequence (CLI path)

The **full** pipeline (semantic extraction of docs/PDFs/images) lives in the `$graphify` skill, not the CLI — the CLI has no full-build subcommand (`graphify .` is NOT a valid command). On the CLI-only branch, build the deterministic code graph:

1. Ensure `graphify-out/.gitignore` exists containing `*` (create if missing — same self-gitignore pattern as `.code-review-graph/`).
2. Run `graphify update .` from the project root — the no-LLM AST extractor; needs no API key, never prompt for one. Note in output that docs/PDFs were not semantically extracted (that needs the `$graphify` skill).
3. Verify `graphify-out/graph.json` exists (a `GRAPH_REPORT.md` may or may not be produced on this path). Missing or errored -> record `Graphify: failed (<reason>)` and continue; a failed build never blocks the run.
4. A standalone `--graphify` run has no Step 8 banner: end with one summary line — `Graphify: built — <files> files, <nodes> nodes, <edges> edges, <communities> communities`. The Step 8 `Graph:` line applies only when a full pass runs in the same session.

### Query sequence (CLI path)

`graphify query "<question>"` — read-only, no build, no edits. When the question implies it, the agent may internally use `graphify path "<A>" "<B>"` (how two things connect) or `graphify explain "<node>"` (one concept); the user-facing surface remains the single question form.

### Harvest mapping (build mode; all draft-until-save)

| graphify output | Goes to |
|---|---|
| God nodes + communities (`GRAPH_REPORT.md`) | `architecture.md` Navigation map refresh |
| Surprising connections + suggested questions | `progress-tracker.md` Open Questions candidates |
| Files/nodes/edges/communities stats | Step 8 banner `Graph:` line |
| God-node list | Context Self-Test seed questions (`references/first-run.md`) |

Evidence-tag discipline: only graphify edges tagged `EXTRACTED` may back an `[extracted: graphify-out/graph.json]` claim; `INFERRED`/`AMBIGUOUS` edges harvest as `[inferred: graphify <relation>]` or become Open Questions — graphify's own confidence labels map directly onto safe-code's Evidence Tags.

Harvest only what is real: skip any output section that is empty or placeholder (no god nodes, unnamed `Community N` groups with no listed members — common on small corpora). Never write placeholder community labels into `architecture.md`; an empty harvest is a valid outcome (`Graphify: built, nothing worth harvesting`).

### Corpus exclusions

Never feed graphify: `.safe-code/context/current-issues.md` (may hold secrets/raw logs), `graphify-out/` itself, and anything already gitignored as sensitive. Enforcement is per-branch: the CLI code-graph path ignores markdown anyway; on the `$graphify` skill path, pass the exclusion explicitly in the dispatch instructions, and never paste `current-issues.md` content into any prompt.
