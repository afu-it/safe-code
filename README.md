# safe-code

> **Spec-first repo hygiene.** Project context, session memory, safe cleanup, and clean handoff in three commands.

[![version](https://img.shields.io/badge/version-4.5-teal?style=flat-square)](./skills/safe-code/SKILL.md)
[![works with](https://img.shields.io/badge/works%20with-Codex%20%7C%20Claude%20%7C%20Cursor%20%7C%20Windsurf-blue?style=flat-square)](#)
[![license](https://img.shields.io/badge/license-MIT-green?style=flat-square)](#)

---

## Install

```bash
# Install into your current project
npx skills add afu-it/safe-code

# Install globally (all projects)
npx skills add afu-it/safe-code -g

# Preview before installing
npx skills add afu-it/safe-code --list
```

Works with **Codex, Claude Code, Cursor, Windsurf**, and 40+ other agents.

---

## Commands

| Command | What it does |
|---|---|
| `/safe-code` | Setup, auto-resume saved work, or run a fresh hygiene pass |
| `/safe-code --continue` | Explicitly resume saved work |
| `/safe-code --save` | Finalize context/docs, commit locally, and close session |
| `/safe-code --explain` | Read-only: explain the project back in plain language (no changes) |

If users forget `--continue`, `/safe-code` auto-detects saved unfinished state and resumes.

### Verify (optional)

The conventions above are normally maintained by the agent. To check them deterministically — for a human, a CI step, or the agent itself — run the bundled script from anywhere inside the project:

```bash
bash scripts/check.sh
```

It verifies `AGENTS.md` and the `.safe-code/` folder (context files + six session docs) exist, checks the provider-bridge pointers (`CLAUDE.md`, `GEMINI.md`, Copilot, Cursor) point at the brain, flags a stale `SESSION.md`, detects legacy layouts to migrate (`.codex/agents`, v3 `.agents/` + root `context/`), and **fails** (exit 1) if `.safe-code/context/current-issues.md` was accidentally committed. Warnings are advisory; only that hard check fails the run.

Upgrading from an older install? `/safe-code` migrates automatically on its next run, or do it deterministically:

```bash
bash scripts/migrate.sh           # preview (dry-run)
bash scripts/migrate.sh --apply   # move files (uses git mv when tracked)
```

It moves everything into `.safe-code/`, patches old config (`.gitignore` entry, `AGENTS.md` paths) to the new version, never overwrites existing `.safe-code/` files, uses `git mv` to preserve history, and removes the emptied legacy folders afterward — including old `.codex/` folders.

---

## How It Works

```
/safe-code
```

```
 Step 0  →  Locate project root (single agent-agnostic `.safe-code/` folder)
 Step 1  →  Create/reconcile AGENTS.md + host bridge + .safe-code/ docs; migrate legacy layouts
 Step 2  →  Load context layers + detect saved session (auto-resume)
 Step 3  →  Git rollback safety, run profile, graph readiness, helper routing
 Step 4  →  Audit dead code (4b: agent-config trust audit)
 Step 5  →  Pre-plan safety check → execution mode A/B/C
 Step 6  →  Execute high-confidence removals slice by slice, verify each
 Step 7  →  Refactor when in scope; review + smoke-verify; draft doc updates
 Step 8  →  Final summary
--save   →  Apply final context/docs + atomic local commits only
```

Nothing is pushed. Nothing risky is deleted without rollback evidence.

---

## Context + Session Docs

Every project's source of truth is `AGENTS.md` + one `.safe-code/` folder. safe-code also writes a thin **provider-bridge pointer** for the host you're running in (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, or `.cursor/rules/safe-code.mdc`) so that host loads the same brain without auto-reading `AGENTS.md`. Other hosts' bridges accrue lazily — each is written the first time you run safe-code under it — so the repo only carries bridges for tools you actually use, with no `.codex/`/`.claude/`/`.agents/` state clutter.

```text
your-project/
├── AGENTS.md                    # canonical entry point + Read First order (source of truth)
├── CLAUDE.md                    # ┐ provider bridges: thin pointers to AGENTS.md so each
├── GEMINI.md                    # │ host (Claude, Gemini, Copilot, Cursor) auto-loads the
├── .github/copilot-instructions.md  # │ same brain — they hold no state, just redirect
├── .cursor/rules/safe-code.mdc  # ┘
└── .safe-code/                  # project brain + all session state
    ├── ACTIVE.md                # ┐
    ├── SESSION.md               # │
    ├── LOG.md                   # │ six session files — ALL updated
    ├── BACKLOG.md               # │ on every /safe-code --save
    ├── MEMORY.md                # │
    ├── safe-refactor-code.md    # ┘
    ├── CHANGELOG.md
    └── context/
        ├── project-overview.md
        ├── architecture.md
        ├── user-preferences.md
        ├── code-standards.md
        ├── ai-workflow-rules.md
        ├── ui-context.md
        ├── progress-tracker.md
        ├── current-issues.md    # issue tracker: user + AI; local-only, gitignored
        └── feature-specs/
            └── 00-template.md
```

- `AGENTS.md` is the canonical entry point — its Read First section points into `.safe-code/`. Because not every host auto-reads `AGENTS.md` (Claude reads `CLAUDE.md`, Gemini `GEMINI.md`, Copilot `.github/copilot-instructions.md`, Cursor `.cursor/rules/`), safe-code writes a thin pointer for the host it is currently running in, so that provider lands on the same brain. The other hosts' pointers are written lazily the first time you run safe-code under each.
- `.safe-code/context/` is canonical long-term project brain.
- `.safe-code/context/user-preferences.md` stores explicit durable user preferences, like “SVG icons only, no emoji icons”.
- Agents watch for strong preference language like `I don't want`, `aku taknak`, `I prefer`, `please remove`, `jangan`, `always`, and `never`.
- `.safe-code/context/feature-specs/` holds AI-written specs (one unit per file), each with a `status:` field — new ideas land as `status: suggested` so they stay referrable history.
- `.safe-code/context/current-issues.md` is a shared issue tracker (user + AI), local-only and never committed; the agent appends an entry when you report an error and flips it to resolved once fixed.
- The six session files are runtime/session memory, shared across agents.

---

## Draft Until Save

During work, safe-code drafts persistent documentation changes in `SESSION.md`.

`/safe-code --save` applies final updates to:

- `.safe-code/context/*.md`
- `AGENTS.md`
- **all six session files, every save** (Six-File Save Rule): `ACTIVE.md`, `SESSION.md` (wiped), `LOG.md` (entry appended), `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md` — files with no new content get a fresh date stamp
- `.safe-code/CHANGELOG.md` only for releasable changes

Exceptions written before save:

- missing scaffold files/folders
- `/.safe-code/context/current-issues.md` gitignore rule
- active feature specs in `.safe-code/context/feature-specs/`
- code changes required by user task

---

## Existing Projects and Old Method Migration

safe-code works for blank, in-progress, finished, and old safe-code projects.

For existing projects:

- reads repo evidence first: README, manifests, routes, schemas, tests, configs
- backfills context files only from proven facts
- on the first run, writes AGENTS.md + evidence-derived context files immediately (not deferred to `--save`) so agents have real context right away
- places unknown facts in `.safe-code/context/progress-tracker.md` Open Questions
- creates feature specs for upcoming work, bugs, refactors, or missing docs, and logs new feature ideas as `status: suggested` specs

For old safe-code projects, every command (`/safe-code`, `--continue`, `--save`) detects old setup config and updates it to the new version:

- moves session docs from `.codex/agents/` (pre-v3) or `.agents/` (v3) into `.safe-code/`
- moves v3 root `context/` and `CHANGELOG.md` into `.safe-code/`
- patches old config: `.gitignore` entry and `AGENTS.md` path references
- removes the emptied legacy folders — your repo ends up with just `AGENTS.md` + `.safe-code/`
- never overwrites existing files; conflicts are reported for manual merge

---

## Feature Specs

Feature specs are written by AI from user intent + context + repo evidence.

Example:

```text
.safe-code/context/feature-specs/
├── 01-design-system.md
├── 02-editor.md
└── 03-auth.md
```

Each spec includes:

- `status:` (suggested / approved / in-progress / done / rejected) + created date
- goal
- scope and out-of-scope
- design/behavior
- likely touched files or areas
- dependencies
- verification checklist

Every new feature idea is captured as a `status: suggested` spec — referrable history you can later approve, build, or reject (rejected specs are kept so the idea is not re-suggested). safe-code should not implement feature work without an active spec unless the user asks for a tiny direct edit.

---

## Current Issues

`.safe-code/context/current-issues.md` is a shared issue tracker. The user pastes raw context, and the agent appends an entry whenever you report a problem — triggers like "fix this", "failed", "got error", or a pasted stack trace — then flips it to resolved (with root cause + fix) once solved.

It stays gitignored:

```gitignore
/.safe-code/context/current-issues.md
```

Because it can hold secrets and raw logs, the agent never copies its content into any committed file. A sanitized one-line summary of each fixed bug goes to `LOG.md` instead — that is the committed history.

Agents do not read this file during normal work — only on an issue trigger or when you reference it.

---

## Helper Skills

Users normally call only `/safe-code`.

| Skill | Role | Called by safe-code? |
|---|---|---|
| `senior-dev` | Task lists, adversarial strategy, clean repo discipline | Yes |
| `build-graph` | Graph build/update when available | Yes |
| `explore-codebase` | Repo orientation and facts | Yes |
| `codebase-pruner` | Dead-code analysis and scoped cleanup | When in scope |
| `safe-refactor-code` | Refactor with impact checks | When in scope |
| `review-changes` | Delta review before final summary | After edits/risk |
| `debug-issue` | Failure/regression tracing | On failures/bugs |

Helper skills analyze first and never make broad changes merely because `/safe-code` ran.

---

## Execution Modes

| Mode | When | What happens |
|---|---|---|
| **A — Auto** | Git clean, high-confidence, reversible | Runs scoped plan |
| **B — Ask** | Dirty worktree, borderline, broad scope | Shows plan, waits |
| **C — Plan only** | No rollback, orientation/audit, or requested | Findings only |

---

## What's New

**v4.5** — slim & consistent.

- **Slimmer skill, same rules** — `SKILL.md` drops ~25% of its weight (1269 → ~945 lines): rare-path procedure detail (atomic-split mechanics, legacy migration steps, graph bootstrap, first-run population + context self-test) moved into four new Layer-3 references (`save-procedure.md`, `legacy-migration.md`, `graph-integration.md`, `first-run.md`) loaded only when those steps actually run. Every decision point and hard invariant stays inline; the Six-File Save Rule is untouched. A new Safety Invariants section replaces six scattered repeats of the same rules.
- **Grounding Rules in AGENTS.md** — the generated `AGENTS.md` now carries an anti-hallucination section every host loads on every session: cite context or code for project claims, verify files/functions exist before referencing them, record gaps as Open Questions instead of guessing, and trust repo evidence over docs.
- **Contradictions fixed** — worked examples caught up to v4.2+ behavior (atomic commits, agent-written issue entries), the README step map matches SKILL.md again, and the "deprecated command forms" section (which conflicted with Command Recognition) is gone.
- **Helper timing harmonized** — `codebase-pruner` and `safe-refactor-code` now explicitly follow safe-code's Draft-Until-Save when orchestrated; direct doc writes are standalone-only behavior.
- **check-version.sh** now also asserts the `examples.md` close-out banner, so worked examples can't silently go stale again.

**v4.4** — per-host provider bridges. safe-code now writes only the bridge for the host you're running in; other hosts' bridges accrue lazily when you run it under them. `AGENTS.md` is still always written, and an undetectable host falls back to writing all four (v4.3 parity). Keeps repos free of unused `GEMINI.md`/Copilot/Cursor files for single-tool users.

**v4.3** — vibe-coder companion.

- **`/safe-code --explain`** — a read-only command (also triggers on "explain my project") that reads the project brain back in plain language: what the app does, the stack in plain terms, current state, what's in progress, and open questions. No edits, no commits — for when you forget what your own project does.
- **Smoke-verify after changes** — when code changed, safe-code runs the project's *documented* build/test command as a smoke check before the summary (routing failures to debugging); if none is known it says so. It never invents a command or drives the app.
- **Plain-language LOG recap** — every `--save` LOG entry now carries a `plain:` one-line recap a non-coder can read, so the committed history is legible.
- **Never-lose-context reminder (opt-in)** — an optional Claude Code hook (`integrations/claude-code/`) that nudges you to run `/safe-code --save` when a session ends with unsaved work. It only reminds — never commits.

**v4.2** — atomic commits on save.

- **Atomic Commit Split** — `/safe-code --save` now splits one session into several atomic conventional commits grouped by logical change (code/behavior tasks first, then one final `docs:` bookkeeping commit for the `.safe-code/` session files), instead of one mixed commit. Tasks are annotated at completion with their touched paths + commit type so each maps cleanly to one commit. The commit gate is unchanged — still local-only, never pushed — and the split degrades safely to the old single-commit behavior when changes cannot be cleanly separated (logged as `atomic split skipped: <reason>`).

**v4.1** — portable project brain: proactive context, cross-provider bridges, issue tracking, idea history, freshness checks, and a context self-test.

- **First-Run Population** — the first `/safe-code` run now writes `AGENTS.md` and evidence-derived context files (`project-overview`, `architecture`, `code-standards`, `progress-tracker`) immediately instead of deferring to `--save`, so any agent has real project context from the start and stops hallucinating. Conversation-only files (`user-preferences`) and UI files stay template until there is evidence.
- **Provider Bridge** — `AGENTS.md` is not auto-read by every host, so safe-code now writes thin pointer files for each major provider (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`) that redirect to `AGENTS.md` + `.safe-code/context/`. A fresh chat in Claude, Gemini, Copilot, or Cursor loads the same project brain without invoking the skill. Pointers hold no state and never overwrite an existing host file.
- **Navigation map** — `architecture.md` now carries a "Where Things Live" map (entry points, routes, data, config, tests, where to add a feature) so a fresh agent jumps straight to the right file instead of re-scanning the whole codebase.
- **Context Freshness Check** — `progress-tracker.md` stamps `last_synced_commit`; on each run safe-code drift-scans signal files (deps, folders, scripts, config) since that commit and refreshes stale context, so a new chat never reads an outdated brain.
- **Issue Tracking Rule** — when you report a problem ("fix this", "failed", "got error", a pasted stack trace), the agent appends an entry to the local-only `current-issues.md` and flips it to resolved once fixed. The file stays gitignored; a sanitized summary of each fix lands in `LOG.md` as committed history.
- **Feature Suggestion Rule** — every new feature idea is captured as a `status: suggested` feature-spec (status: suggested/approved/in-progress/done/rejected). Ideas become referrable history; rejected specs are kept so the same idea is not re-suggested.
- **Context Self-Test** — after writing context, safe-code runs a closed-book quiz: a fresh context-only subagent answers Day-1 questions citing the context section as evidence, and a second subagent tries to refute. Gaps are filled from the code or raised as Open Questions, so the brain is *proven* sufficient, not just present.

**v4.0** — one universal `.safe-code/` folder (breaking change).

- **Breaking:** everything safe-code manages now lives in a single `.safe-code/` folder at the project root — the six session files, `CHANGELOG.md`, and `context/` all inside it. Only `AGENTS.md` stays at root as the universal entry point every AI host auto-reads. `/safe-code` creates exactly two root artifacts and nothing else — no more `.codex/`, `.claude/`, or `.agents/` folders in your repo.
- **Auto-migration on every command** — `/safe-code`, `--continue`, and `--save` all detect old setup config (pre-v3 `.codex/agents/` etc., v3 `.agents/` + root `context/`), move it into `.safe-code/`, patch `.gitignore` and `AGENTS.md` paths to the new version, and remove the emptied legacy folders. `bash scripts/migrate.sh --apply` does the same deterministically.
- **Six-File Save Rule** — every `/safe-code --save` now updates all six session files (`ACTIVE.md`, `SESSION.md`, `LOG.md`, `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md`); files with no new content get a fresh date stamp so every save is provably complete.

**v3.2** — context economy for long runs.

- **Helper Execution Mode** — when the host supports fresh-context subagents (Claude Code Agent tool, Codex subtasks), read-only helpers (`$explore-codebase`, pruner audit, Step 4b config scan, review analysis) dispatch as subagents and return summaries, keeping the main context lean. Write-capable helpers stay inline. No subagent support → identical inline behavior as before.
- **Context Checkpoint Rule** — `SESSION.md` is updated at phase boundaries (orientation/audit/config-audit done, each verified slice) and on context-pressure signals, so `ACTIVE.md` auto-resume survives mid-run compaction or session death. High pressure mid-run → checkpoint, then suggest `--save` + `--continue` in a fresh session instead of pushing through degraded context.

**v3.1** — agent config trust audit.

- New **Step 4b: Agent Config Trust Audit** — Audit/Cleanup profiles now scan repo-controlled agent config (`.claude/`, `.mcp.json`, hooks, commands, skills, rules, `AGENTS.md`) as supply chain artifacts: hidden unicode, embedded payloads, outbound exec primitives, risky env overrides (`ANTHROPIC_BASE_URL`), committed secrets, and unknown MCP servers.
- Report-only by design: findings go to `SESSION.md`/`BACKLOG.md`; trust decisions stay with the user. High findings quarantine the affected file's content as instructions for the rest of the run.
- Patterns and High/Medium/Info classification live in `references/agent-config-audit.md` (Layer 3, loaded on demand). Uses `agentshield` CLI when available; the built-in pattern scan alone is a valid pass.

**v3.0** — unified session folder + leaner skill (breaking change).

- **Breaking:** session/continuity docs now live in one agent-agnostic `.agents/` folder at the project root, replacing per-agent `.codex/agents/`, `.claude/agents/`, `.cursor/agents/`, `.windsurf/agents/`, and the helper skills' `.codex/memory/`. Run `bash scripts/migrate.sh --apply` to move existing files into `.agents/` and keep continuity.
- Removed per-agent detection from the skills; continuity now belongs to the project, not the tool.
- `CHANGELOG.md` is now consistently at the project root across all skills.
- Slimmed `safe-code/SKILL.md` by moving doc/session templates into `skills/safe-code/references/`, loaded on demand per the Agent Skills spec.
- AGENTS.md authoring rules now have one canonical home (`references/agents-md-authoring.md`); helper skills defer to it.

**v2.9** — six-file project context + feature specs.

- Added `context/` project brain and `context/feature-specs/` build specs.
- Added local-only `context/current-issues.md` template and gitignore rule.
- `/safe-code` auto-resumes saved sessions when users forget `--continue`.
- Persistent context/doc updates are drafted during work and finalized on `/safe-code --save`.
- Old safe-code continuity docs migrate into new context files safely.

**v2.8** — explicit first-run, continue, and save commands.

**v2.7** — code-review-graph and helper-skill orchestration.

---

## New to skills?

Read the tutorial for step-by-step setup:
- [English tutorial](./TUTORIAL-EN.md)
- [Tutorial Bahasa Melayu](./TUTORIAL-BM.md)
