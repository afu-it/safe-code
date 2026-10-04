---
name: debug-issue
description: Systematically debug a symptom with a red-capable feedback loop, a minimised repro, ranked falsifiable hypotheses, tagged probes, and a regression test at the correct seam. Graph tools accelerate the search when present; they are never required.
---

# Debug Issue

Reproduce first, theorise second. A hypothesis formed before a failing command exists is a guess dressed as a plan.

## Phase 0: Contention and real state

Before any code hypothesis: is another process, agent, worktree, or the user's other tool touching the same branch, database, port, session, or shared credential/token store? (`git worktree list`, `lsof -i :<port>`, ask "is another tool on this?"). Rule it out first — flaky behaviour under contention looks exactly like a code bug, and two clients refreshing the same rotating token invalidate each other.

- When you have read access, look at the real failing record, user, or job state (read-only) before hypothesising — it often names the cause outright.
- Never blind-retry a side-effecting call (POST, send, payment, migration) that failed part-way: read the remote state first, because the first attempt may have half-succeeded.

## Phase 1: Build a red-capable loop

Build one command — a test, `curl`, CLI + fixture, headless script, replayed trace, or throwaway harness — that you have already run once and that goes **red on this exact symptom**. It must:

- assert the user's symptom, not "runs without erroring";
- be deterministic, seconds-fast, and runnable by you without the user;
- print only redacted output: secrets become `<REDACTED>`, credentials stay in env vars, captured artifacts (HAR, request dumps) are quoted only on the lines that carry the signal.

If you catch yourself reading code to build a theory before that command exists, stop. **No red-capable command, no hypothesis.** If you genuinely cannot build one, say so, list what you tried, and ask for the environment, a redacted artifact, or permission to instrument.

## Phase 2: Minimise

Shrink to the smallest scenario that still goes red: cut inputs, callers, config, data, and steps **one at a time**, re-running after each cut. Done when removing any remaining element turns it green. The minimal repro shrinks the hypothesis space and becomes the regression test.

## Phase 3: Ranked, falsifiable hypotheses

Generate 3–5 hypotheses before testing any — one hypothesis anchors on the first plausible idea. For a once-only failure with fixed inputs, rank "what varies between runs" high: clock ties, unordered reads (an `ORDER BY` that does not end on a unique column), concurrency, cache or retry state. Each must state a prediction: "If X is the cause, then changing Y makes the bug disappear / changing Z makes it worse." No stateable prediction means it is a vibe: sharpen or discard. Show the ranked list to the user before probing (they re-rank instantly with domain knowledge); do not block on the answer if they are away.

Graph accelerators (optional, when a codegraph index is ready): `codegraph explore "<symptom>"` (or `codegraph_explore`), `codegraph callers|callees <symbol>`, `codegraph affected <recently changed files>` for regressions, `codegraph impact <symbol>` before touching shared code. Without them: `rg`, tests, logs, runtime probes.

## Phase 4: Probe one variable at a time

Each probe maps to one Phase 3 prediction. Record each falsified hypothesis and each failed fix as one line in `MEMORY.md` (drafted in `SESSION.md` under safe-code) so no one re-runs them. Tag every temporary log with a unique prefix, e.g. `[DEBUG-a4f2]`, so cleanup is one grep. Prefer a debugger or REPL breakpoint over ten logs; never "log everything and grep".

## Phase 5: Fix at the correct seam

Write the regression test **before** the fix, at a seam where the test exercises the real bug pattern as it occurs at the call site. A too-shallow seam (a unit test that cannot replicate the chain that triggered the bug) gives false confidence. **If no correct seam exists, that is itself a finding**: record it in `MEMORY.md` — the architecture is preventing this bug from being locked down. Then patch only the smallest confirmed cause.

## Cleanup gate (before declaring done)

- [ ] the original repro no longer reproduces (run it, do not assume);
- [ ] the regression test was seen failing without the fix (bypass the fix in place -> red -> restore; no destructive git in a shared checkout — the safe-code skill's `references/multi-session.md`, Shared-checkout rules) and passes with it, or the absence of a seam is documented — a test never seen red proves nothing;
- [ ] `grep -rn "\[DEBUG-" <src>` is empty and throwaway harnesses are deleted;
- [ ] cleanup closes only the windows, tabs, daemons, and locks this task opened — never the user's; a stale lock is removed only after proving no live process owns it;
- [ ] the winning hypothesis is stated in the commit message so the next debugger learns.

## Output

Lead with: root cause (the hypothesis that survived, and which prediction confirmed it) · changed files · the red-capable command and its before/after result · remaining risk or missing coverage (including "no correct seam").
