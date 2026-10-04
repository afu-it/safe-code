# safe-code reference: legacy layout migration

> Loaded on demand when any safe-code command detects a legacy layout (Layer 3). The
> binding rules — detect on every command, migrate at scaffold time, never overwrite,
> one `decision` LOG entry — live inline in SKILL.md; this file holds the full
> detection list, per-location steps, config patch targets, and content mapping.

Deterministic helper: the skill ships `scripts/migrate.sh` (dry-run by default; `--apply`
moves with `git mv` when tracked) — same detection and marker rules as this file.

## Legacy layouts to detect

```
Pre-v3 layout:  .codex/agents/  .claude/agents/  .cursor/agents/  .windsurf/agents/
                .codex/memory/  .claude/memory/  .cursor/memory/  .windsurf/memory/
v3 layout:      .agents/  (six session files)  +  root context/  +  root CHANGELOG.md
                created by safe-code (gitignore entry /context/current-issues.md is the marker)
```

**Legacy only when it holds safe-code session files.** These folder names are also used by
other tools: `.agents/skills/` is the standard project skill directory, and `.claude/agents/*.md`
are real Claude Code subagents. A folder counts as a legacy safe-code location only when:

1. it contains at least one of the six session files (`ACTIVE.md`, `SESSION.md`, `LOG.md`,
   `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md`), **and**
2. a safe-code marker is present — `ACTIVE.md`, `SESSION.md`, or `safe-refactor-code.md`
   inside that folder, or a project-level marker (`.safe-code/`, an `AGENTS.md` that names
   safe-code, or the v3 `/context/current-issues.md` gitignore entry).

Root `context/` is legacy only with the v3 gitignore entry, or with `progress-tracker.md` inside it
**plus** a project marker. Even then only safe-code's named context files (and `feature-specs/*.md`)
move; any other file in `context/` stays. Anything that fails these tests is the user's — report
nothing, move nothing.

## Migration steps (per legacy location found)

1. Move only safe-code's own files into their new home — `git mv` when tracked, plain move otherwise. Every other file in the folder (subagent definitions, skills, unrelated notes) stays where it is:
   - the six session files (`ACTIVE.md`, `SESSION.md`, `LOG.md`, `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md`) -> `.safe-code/`
   - safe-code's named files in root `context/` (and `context/feature-specs/*.md`) -> `.safe-code/context/`
   - root `CHANGELOG.md` -> `.safe-code/CHANGELOG.md` **only** when the v3 gitignore entry is present (otherwise it is the project's own changelog)
2. Never overwrite: if the destination file already exists, keep the legacy file in place, report the conflict, and let the user merge.
3. Patch old config to the new version wherever the repo uses it:
   - `.gitignore`: replace `/context/current-issues.md` with `/.safe-code/context/current-issues.md`
   - `AGENTS.md`: rewrite Read First paths and any `context/`, `.agents/`, `.codex/agents/` references to `.safe-code/` paths
   - any other repo doc safe-code wrote that points at old paths
4. Remove each legacy folder once it is empty — including a now-empty `.codex/`, `.claude/`, `.cursor/`, or `.windsurf/` parent. Never remove a folder that still holds unmigrated or non-safe-code files (`.claude/agents/` with real subagents, `.agents/skills/`); report what was left behind instead.
5. Log the whole migration as one typed `decision` entry in `LOG.md`.

## Content mapping (old continuity docs that are thin or pre-date `context/`)

- `MEMORY.md` -> draft candidate facts for `.safe-code/context/architecture.md`
- `BACKLOG.md` -> draft Next Up / Open Questions for `.safe-code/context/progress-tracker.md`
- `ACTIVE.md` -> draft Current Goal / In Progress for `.safe-code/context/progress-tracker.md`
- `LOG.md` -> safe decision summaries only
- existing `AGENTS.md` -> preserve verified rules and add Read First section

## Migration rules

- File moves and config patches happen now; content rewrites (mapping above) are drafted in `SESSION.md` and applied on `/safe-code --save`.
- Do not copy raw logs, secrets, stack traces, private URLs, or `current-issues.md` content into context files.
- Mark uncertain migrated facts as Open Questions.
- After migration, `.safe-code/context/` is canonical project context; the six session files in `.safe-code/` remain session state.
- Provider-bridge pointer files (`CLAUDE.md`, plus `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`, `.clinerules/safe-code.md` written by earlier versions) are redirects, not state — preserve them; they are never legacy, never deleted.
