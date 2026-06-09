# safe-code Skill Hardening Plan (#2 slim-down + #3 behavioral tests)

> Status: **#3 started** (baseline run recorded, scaffold in `tests/safe-code/`).
> **#2 is gated on #3** — do not start it until the test suite below is green.

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

## Risks

- Moving a rule (not just detail) into a deferred reference can silently disable it
  if its trigger never fires. Only move *detail*; rules stay inline.
- Over-aggressive trimming hurts the very anti-hallucination guarantees the skill sells.
  Stop when load is reasonable, not when a word target is hit.
