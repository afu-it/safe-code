---
name: debug-issue
description: Systematically debug a symptom with a red-capable feedback loop, a minimised repro, ranked falsifiable hypotheses, tagged probes, and a regression test at the correct seam. Graph tools accelerate the search when present; they are never required.
---

# Debug Issue

Reproduce first, theorise second. A hypothesis formed before a failing command exists is a guess dressed as a plan.

## Phase 0: Contention check

Before any code hypothesis: is another process, agent, worktree, or the user's other tool touching the same branch, database, port, or session? (`git worktree list`, `lsof -i :<port>`, ask "is another tool on this?"). Rule it out first — flaky behaviour under contention looks exactly like a code bug.

## Phase 1: Build a red-capable loop

Build one command — a test, `curl`, CLI + fixture, headless script, replayed trace, or throwaway harness — that you have already run once and that goes **red on this exact symptom**. It must:

- assert the user's symptom, not "runs without erroring";
- be deterministic, seconds-fast, and runnable by you without the user;
- print only redacted output: secrets become `<REDACTED>`, credentials stay in env vars, captured artifacts (HAR, request dumps) are quoted only on the lines that carry the signal.

If you catch yourself reading code to build a theory before that command exists, stop. **No red-capable command, no hypothesis.** If you genuinely cannot build one, say so, list what you tried, and ask for the environment, a redacted artifact, or permission to instrument.

## Phase 2: Minimise

Shrink to the smallest scenario that still goes red: cut inputs, callers, config, data, and steps **one at a time**, re-running after each cut. Done when removing any remaining element turns it green. The minimal repro shrinks the hypothesis space and becomes the regression test.

## Phase 3: Ranked, falsifiable hypotheses

Generate 3–5 hypotheses before testing any — one hypothesis anchors on the first plausible idea. Each must state a prediction: "If X is the cause, then changing Y makes the bug disappear / changing Z makes it worse." No stateable prediction means it is a vibe: sharpen or discard. Show the ranked list to the user before probing (they re-rank instantly with domain knowledge); do not block on the answer if they are away.

Graph accelerators (optional, when `code-review-graph` tools are ready): `get_minimal_context_tool(task=<symptom>)`, `query_graph_tool(pattern="callers_of"|"callees_of")`, `get_affected_flows_tool()`, `detect_changes_tool()` for regressions, `get_impact_radius_tool()` before touching shared code. Without them: `rg`, tests, logs, runtime probes.

## Phase 4: Probe one variable at a time

Each probe maps to one Phase 3 prediction. Tag every temporary log with a unique prefix, e.g. `[DEBUG-a4f2]`, so cleanup is one grep. Prefer a debugger or REPL breakpoint over ten logs; never "log everything and grep".

## Phase 5: Fix at the correct seam

Write the regression test **before** the fix, at a seam where the test exercises the real bug pattern as it occurs at the call site. A too-shallow seam (a unit test that cannot replicate the chain that triggered the bug) gives false confidence. **If no correct seam exists, that is itself a finding**: record it in `MEMORY.md` — the architecture is preventing this bug from being locked down. Then patch only the smallest confirmed cause.

## Cleanup gate (before declaring done)

- [ ] the original repro no longer reproduces (run it, do not assume);
- [ ] the regression test passes, or the absence of a seam is documented;
- [ ] `grep -rn "\[DEBUG-" <src>` is empty and throwaway harnesses are deleted;
- [ ] the winning hypothesis is stated in the commit message so the next debugger learns.

## Output

Lead with: root cause (the hypothesis that survived, and which prediction confirmed it) · changed files · the red-capable command and its before/after result · remaining risk or missing coverage (including "no correct seam").
