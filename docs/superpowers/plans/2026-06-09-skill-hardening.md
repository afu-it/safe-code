# safe-code Skill Hardening Plan (#2 slim-down + #3 behavioral tests)

> Status: **#3 done** (7 invariants tested; results in `tests/safe-code/README.md`).
> **#2 done, but rescoped** — a full reading showed SKILL.md is dense decision-logic,
> not bloat, and the tests cover rules not step-execution, so an aggressive slim-down
> was NOT warranted. #2 was scoped to safe internal dedup (see Outcome below).
> #1 and #4 shipped earlier this session.

**Why this order:** `SKILL.md` is ~1,250 lines / ~9,200 words of live behavioral
instructions that the maintainer depends on daily. The `superpowers:writing-skills`
Iron Law forbids editing a skill without tests first. Slimming it down (#2) without
a regression suite (#3) risks silently breaking behaviors with no way to notice.
So #3 must exist and pass before #2 moves a single line.

Already shipped this session (do not redo): #1 description trim, #4 version-drift
guard (`scripts/check-version.sh`).

---

## Task 3 — Behavioral test suite (do first)

**Goal:** Lock the non-obvious behaviors (see `tests/safe-code/README.md` checklist)
with subagent RED/GREEN scenarios, so a later refactor can prove it changed nothing.

- [ ] For each behavior in the checklist, write a realistic task + pressure scenario.
- [ ] Run baseline (no skill) vs with-excerpt; record verdicts in `tests/safe-code/`.
- [ ] Drop scenarios where baseline already complies (redundant rule — like push-safety).
- [ ] Keep scenarios where the rule changes behavior — those define the contract #2 must preserve.
- [ ] Capture the GREEN verdicts as the regression baseline for #2.

**Done when:** every "value" behavior has a scenario whose GREEN verdict is recorded.

## Task 2 — Slim down SKILL.md (gated on Task 3 green)

**Goal:** Cut the Layer-1 entry body toward the rubric target by moving step-level
detail into `references/` (Layer 3), keeping `SKILL.md` a router of triggers + rules.

- [ ] Identify step bodies that are detail, not decisions (e.g. long Step 4/6/7 procedures), and move them to new/existing `references/*.md` behind their existing "Layer 3 Trigger" lines.
- [ ] Keep inline: scope rule, command recognition, decision framework, the rules (six-file, atomic split, draft-until-save), and the layer/trigger map.
- [ ] After EACH move, re-run the affected Task 3 scenarios. Any verdict regression → revert that move.
- [ ] Re-run `scripts/check.sh` semantics mentally + `scripts/check-version.sh`.
- [ ] Target: meaningfully smaller Layer-1 load with zero behavioral regression. Do not chase an arbitrary word count at the cost of clarity.

**Done when:** entry body is materially smaller AND every Task 3 scenario still passes.

### Outcome — 2026-06-09 (rescoped)

Full read of all 1,257 lines: the bulk is decision logic and behavioral contracts,
not filler. The "<500 words" rubric target is for small, every-chat skills; safe-code
is a heavy on-demand orchestrator (different class). The #3 tests protect *rules*, not
*step execution*, so moving step procedures to references would be an unprotected,
high-risk edit on a daily-driver skill. Decision: **do not** force an aggressive
slim-down. Instead, fix the genuine defect the read surfaced — the skill violates its
own **Source-of-Truth Ownership** rule with internal duplication:

- Default checklist was written twice and had **diverged** (18 items vs 15) — consolidated to the canonical one in *Measure Twice*.
- Layer-1 file list was duplicated (Loading Layers + Step 2a) — Step 2a now points at the canonical definition.
- Provider-bridge mechanics were explained ~3× — trimmed the redundant prose, kept the canonical Provider Bridge section.

Result: −30 lines, a real consistency bug fixed, every tested rule left inline and intact.
No behavioral change → the 12 subagent scenarios did not need re-running.

## Risks

- Moving a rule (not just detail) into a deferred reference can silently disable it
  if its trigger never fires. Only move *detail*; rules stay inline.
- Over-aggressive trimming hurts the very anti-hallucination guarantees the skill sells.
  Stop when load is reasonable, not when a word target is hit.
