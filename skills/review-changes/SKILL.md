---
name: review-changes
description: Review working-tree, branch, or PR changes on two separate axes — Standards (repo conventions + a smell baseline) and Spec (does it do what the active feature spec asked) — with blast-radius and test-coverage checks. Graph tools accelerate when present; never required.
argument-hint: "[file | function | branch | PR number]"
---

# Review Changes

Two axes, never merged. Code can pass one and fail the other, and merging lets one mask the other.

## Inputs

- The diff: no argument -> working tree vs the default diff base; file/function -> that target and its impact; branch -> vs `main`/`master`; PR number -> the checked-out PR branch or local diff.
- `.safe-code/context/code-standards.md` (documented repo standards).
- The active spec, if any: `.safe-code/context/feature-specs/<NN>-*.md` with `status: in-progress` (or the one the user names).
- Graph accelerators when ready: `detect_changes_tool(detail_level="minimal")` for risk-scored deltas, `get_impact_radius_tool()` for high-risk changes, `get_affected_flows_tool()` for critical paths, `query_graph_tool(pattern="tests_for", target=<symbol>)`. Without them: `git diff`, `rg`, direct reads. Read full source only for changed or high-impact files.

## Axis 1 — Standards

Does the change follow the documented standards, and does it avoid the smell baseline?

Smell baseline (Fowler), always carried against the diff: Mysterious Name · Duplicated Code · Feature Envy · Data Clumps · Primitive Obsession · Repeated Switches · Shotgun Surgery · Divergent Change · Speculative Generality · Message Chains · Middle Man · Refused Bequest.

Binding rules: a documented repo standard always overrides the baseline; every smell is a labelled judgement call ("possible Feature Envy"), never a hard violation; skip anything tooling (lint, type-check, formatter) already enforces.

Test shapes to reject on this axis: **implementation-coupled** (mocks internal collaborators or asserts through a side channel — the tell is that it breaks on refactor while behaviour is unchanged); **tautological** (the assertion recomputes the expected value the way the code does, so it passes by construction — expected values must come from an independent source: a known-good literal, a worked example, the spec); **horizontally sliced** (all tests first, then all implementation — it verifies imagined behaviour).

## Axis 2 — Spec

Only when an active spec exists; otherwise report `Spec: no active spec`. Does the change implement what the spec asked?

- **Missing**: a requirement in the spec with no corresponding change.
- **Scope creep**: a change no requirement asked for (note it; it may be prefactoring, which is fine if labelled).
- **Wrongly implemented**: the requirement is addressed but the behaviour differs from the spec's Design / Verify When Done.

## Output

```text
## Standards
- [severity] path:line - issue, impact, fix
Worst issue: <one line, or none>

## Spec
- [missing | creep | wrong] <requirement or change> - detail
Worst issue: <one line, or "no active spec">

## Summary
- Risk: <low|medium|high>
- Blast radius: <files/functions/flows>
- Tests checked: <commands or graph coverage>
- Open questions: <or none>
```

Findings first, ordered by severity **within** each axis; never re-rank across axes. Report only actionable findings.
