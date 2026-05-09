---
name: review-changes
description: Review working-tree, branch, or PR changes using graph change detection, blast-radius analysis, affected flows, and test coverage checks.
argument-hint: "[file | function | branch | PR number]"
---

# Review Changes

Perform a focused code review of changed code and its blast radius.

## Core Rules

- Use code-review stance: findings first, ordered by severity, with file and line references where possible.
- Start with `get_minimal_context_tool(task="review changes")`.
- Run `build_or_update_graph_tool()` before review if the graph is stale.
- Prefer `detect_changes_tool(detail_level="minimal")` for risk-scored deltas.
- Read full source only for changed or high-impact files.
- If graph tools are unavailable, review with `git diff`, `rg`, and direct file reads.

## Scope Modes

- No argument: review current working tree against default diff base.
- File or function argument: review that target and its graph impact.
- Branch argument: review branch diff against `main` or `master`.
- PR number: inspect the checked-out PR branch or use local git diff if available.

## Workflow

1. Identify diff base from argument or current branch.
2. Update graph incrementally.
3. Run `detect_changes_tool()` for changed files, impacted nodes, risk, and guidance.
4. Run `get_impact_radius_tool()` for high-risk changes.
5. Run `get_affected_flows_tool()` for critical path changes.
6. Use `query_graph_tool(pattern="tests_for", target=<symbol>)` for changed high-risk functions.
7. Read changed source snippets or full files where needed.
8. Report only actionable findings.

## Output

```text
Findings
- [severity] path:line - issue, impact, fix

Open questions
- ...

Summary
- Risk: <low|medium|high>
- Blast radius: <files/functions/flows>
- Tests checked: <commands or graph coverage>
```
