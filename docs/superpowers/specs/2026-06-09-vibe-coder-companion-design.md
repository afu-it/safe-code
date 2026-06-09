# safe-code v4.3 — Vibe-Coder Companion (design)

**Goal:** Four small, independent enhancements that make safe-code more useful to a
full-time vibe coder (directs AI, can't read code deeply, can't catch hallucination).
Each is additive; none changes an existing rule. Ship as separate atomic commits.

**Non-goals:** No builder features (safe-code stays a brain + janitor, not a contractor).
No full app-driving (that is the `/run` skill). No auto-commit automation.

---

## Feature 1 — Auto-save reminder hook (remind + nudge, opt-in)

A host hook that warns at session end when there is unsaved safe-code work, so a vibe
coder never loses context by forgetting `/safe-code --save`. **Never commits or saves
by itself** (decision: "remind + nudge").

- `scripts/save-reminder.sh` — deterministic, reusable, self-locating:
  - No `.safe-code/` in the project → exit 0 silently (project doesn't use safe-code).
  - Unsaved-work signal = `git status --porcelain .safe-code/` is non-empty, OR
    `.safe-code/SESSION.md` contains an unfinished task marker (`[ ]` / `[~]`).
  - Unsaved → print a one-line reminder; exit 0 (non-blocking, never fails the session).
- `integrations/claude-code/hooks.example.json` — a `Stop` hook calling the script.
  Opt-in: the user pastes it into their own settings; safe-code never auto-installs it.
- Documented in README ("Optional: never-lose-context reminder") + CLAUDE.md.
- Other hosts: the script is host-agnostic; only the wiring differs (documented).

**Test:** run `save-reminder.sh` against (a) a dir with no `.safe-code/` → silent, (b) a
dir with a clean saved state → silent, (c) a dir with a dirty `.safe-code/` → reminder.

## Feature 2 — `/safe-code --explain` (read-only project read-back)

A vibe coder forgets what their own app does. This reads the project brain back in plain
language. **Read-only: no edits, no commits, no save.**

- Command Recognition: map `--explain`, `explain`, `explain my project`, `apa projek`,
  `what does my app do` → explain mode.
- New section "Command: `/safe-code --explain`":
  - Load Layer 1 context (`project-overview`, `architecture`, `progress-tracker`).
  - Produce a plain-language briefing: what the app does + for whom, the stack in plain
    terms, current state, what's in progress, and open questions — no jargon dumps.
  - If `.safe-code/context/` is missing/empty → say so and suggest running `/safe-code`.
- **Test (subagent):** given the --explain instruction + a sample brain, the agent reads
  it back plainly and makes zero edit/commit tool calls.

## Feature 3 — Smoke-verify after changes (extend Step 7)

After code changes, confirm nothing obviously broke — closes the "vibe coder can't tell
it's broken" gap.

- In Step 7, after `$review-changes`: if code changed AND a build/test/run command is
  known (from `code-standards.md` / `architecture.md`), run it as a smoke check.
  - Pass → note in the final summary. Fail → route to `$debug-issue`.
  - No known command → record `smoke-verify: no command available` in the summary.
- Never invent a command; only run a documented one. Running tests/builds does not mutate
  source, so this stays inside existing safety.

## Feature 4 — Plain-language LOG recap (extend LOG format)

The committed history (`LOG.md`) is typed/technical; a vibe coder can't read it.

- Each `--save` LOG entry gains a `plain:` line — one sentence a non-coder understands.
- Update `references/doc-templates.md` LOG entry format + the Six-File Save Rule note.

---

## Cross-cutting

- **Version → 4.3** in every live spot (SKILL.md frontmatter + Step 8 banner, README
  badge + new What's New entry, both tutorials' command list gains `--explain`).
  `scripts/check-version.sh` must pass.
- Build order: F1 (hook, no skill risk) → F4 (LOG, additive) → F3 (Step 7, additive) →
  F2 (new command, tested) → version bump + docs. Separate atomic commits, local-only.
- 3 features touch live SKILL.md; only #2 changes a decision path, so only #2 needs a
  subagent test. #1/#3/#4 are additive and verified by reading + `check-version.sh`.
