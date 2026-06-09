# safe-code skill tests

Behavioral tests for the `safe-code` skill, following the TDD-for-skills method
(`superpowers:writing-skills`): **watch an agent fail without the rule (RED),
add/keep the rule (GREEN), close loopholes (REFACTOR).** A rule only earns its
place if a baseline agent *without* it behaves wrong.

There is no automated runner. Each scenario is run by dispatching a subagent
twice — once with no safe-code context (baseline) and once with the relevant
SKILL.md excerpt — and comparing the two verdicts.

## Results — 2026-06-09 (7 invariants, baseline vs with-rule)

| Invariant | Baseline (no skill) | With rule | Rule changes behavior? |
|---|---|---|---|
| `--save` must not push | no push | no push | ❌ redundant |
| **Six-File Save** (update all six) | only-relevant | **all six** | ✅ **YES** |
| Atomic commit split | split | split | ❌ redundant |
| Draft-until-save | defer | defer | ❌ redundant |
| Provider bridge (no clobber) | preserve | preserve | ❌ redundant |
| Feature-spec gate | spec-first | spec-first | ❌ redundant |
| `current-issues.md` never committed | no | no | ❌ redundant |

**Headline: 6 of 7 rules are redundant with modern Claude's baseline behavior.**
Only the **Six-File Save Rule** changes what the agent does — baseline updates
only the docs that have real content (it calls forcing the others "hallucinated
noise"); the rule mandates all six with a date stamp on unchanged ones, a
deliberate *provable-completeness* choice (a stamp is not fake content).

### Honest caveat (don't over-read this)

These were **single-shot, low-pressure hypotheticals** ("what would you do?").
The writing-skills method calls for testing under *combined maximum pressure*
(time + sunk cost + authority + exhaustion + context loss). A rule that looks
redundant in a clean one-shot may still earn its place as a guardrail deep in a
long, pressured real session. So: **redundant here ≠ safe to delete** — it means
**safe to compress** (terse inline rule + detail in a reference), not remove.

## Implication for the slim-down (#2)

- Keep the **Six-File Save Rule** prominent and inline — it is load-bearing.
- The other rules can shrink to a one-line statement + a `references/` pointer:
  the behavior is already native, so a long in-body explanation is pure token cost.
- The real bulk to move to Layer-3 references is the **verbose Step 0–8
  procedures, templates, and examples**, not the rules. These hypotheticals do
  NOT cover step-procedure execution, so move only clear *detail* (templates,
  edge-case prose), never a decision point, and keep each move reversible.

## Not yet tested (optional future rounds)

- [ ] Pressure-stacked versions of the six redundant invariants (the real test).
- [ ] Layer-loading discipline (definitional — no baseline analog).
- [ ] Context-freshness drift scan and the closed-book self-test behaviors.

## How to run a scenario

1. Pick an invariant. Write a realistic task + pressure (time / sunk cost /
   authority / "just this once"), ideally several stacked.
2. Dispatch a subagent with NO safe-code context → record verdict (baseline).
3. Dispatch a subagent given ONLY the relevant SKILL.md excerpt → record verdict.
4. Baseline already complies → rule is redundant under that pressure level: note
   it, compress the rule, do not count it as hard coverage. Baseline fails and
   the rule fixes it → the rule earns its place; keep it inline and lock it here.
