---
name: explore-codebase
description: Navigate and understand codebase structure using the codegraph index. Use for repo orientation, AGENTS.md authoring, architecture mapping, or finding relevant code.
---

# Explore Codebase

Use the codegraph index to understand the repository before editing.

## Core Rules

- Prefer the host's MCP tools when exposed (`codegraph_explore`, `codegraph_node`); otherwise the same output comes from the CLI (`codegraph explore`, `codegraph node`).
- Prefer graph results for entry points, call paths, dependents, and impact; confirm anything load-bearing by reading the source it points at.
- If the index is missing or stale, run `$build-graph` first. If codegraph is unavailable or empty, continue with `rg`, manifests, README files, and config inspection.

## Workflow

1. Build or sync the index if it is empty or stale (`$build-graph`).
2. `codegraph files --format grouped` for the module layout.
3. `codegraph explore "<task or area>"` for the relevant symbols' source plus call paths in one shot; `codegraph context "<task>"` for a task-shaped bundle.
4. `codegraph node -f <file> --symbols-only` for a file's symbols and who depends on it (hubs = files "used by" many others).
5. `codegraph callers|callees <symbol>` and `codegraph impact <symbol>` to narrow to specific symbols and risky chokepoints.

## AGENTS.md Use

When helping safe-code write or reconcile `AGENTS.md`, follow the canonical authoring rules in the safe-code skill's `references/agents-md-authoring.md` (decision test, investigation order, what to extract/exclude). This skill's job is to supply graph-backed facts that feed those rules, not to define a separate authoring process.

Prefer graph-backed facts:

- major modules and files
- entry points and call paths
- hub files that many others depend on (need caution)
- languages detected by the index
- untested hotspots (source files `codegraph affected` maps to no test)

Do not copy raw graph dumps into docs. Convert them into compact handoff facts.
