# safe-code reference: legacy layout migration

> Loaded on demand when any safe-code command detects a legacy layout (Layer 3). The
> binding rules — detect on every command, migrate at scaffold time, never overwrite,
> one `decision` LOG entry — live inline in SKILL.md; this file holds the full
> detection list, per-location steps, config patch targets, and content mapping.

## Legacy layouts to detect

```
Pre-v3 layout:  .codex/agents/  .claude/agents/  .cursor/agents/  .windsurf/agents/
                .codex/memory/  .claude/memory/  .cursor/memory/  .windsurf/memory/
v3 layout:      .agents/  (six session files)  +  root context/  +  root CHANGELOG.md
                created by safe-code (gitignore entry /context/current-issues.md is the marker)
```

## Migration steps (per legacy location found)

1. Move every safe-code `*.md` into its new home — `git mv` when tracked, plain move otherwise:
   - session docs (`ACTIVE.md`, `SESSION.md`, `LOG.md`, `BACKLOG.md`, `MEMORY.md`, `safe-refactor-code.md`) -> `.safe-code/`
   - root `context/` -> `.safe-code/context/`
   - root `CHANGELOG.md` -> `.safe-code/CHANGELOG.md` (skip if the repo never had safe-code manage it and the user objects)
2. Never overwrite: if the destination file already exists, keep the legacy file in place, report the conflict, and let the user merge.
3. Patch old config to the new version wherever the repo uses it:
   - `.gitignore`: replace `/context/current-issues.md` with `/.safe-code/context/current-issues.md`
   - `AGENTS.md`: rewrite Read First paths and any `context/`, `.agents/`, `.codex/agents/` references to `.safe-code/` paths
   - any other repo doc safe-code wrote that points at old paths
4. Remove each legacy folder once it is empty — including a now-empty `.codex/`, `.claude/`, `.cursor/`, or `.windsurf/` parent. Never remove a folder that still holds unmigrated or non-safe-code files; report what was left behind instead.
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
- Provider-bridge pointer files (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`) are redirects, not state — preserve them; they are never legacy.
