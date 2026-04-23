# safe-code

A collection of agent skills for safe code maintenance — dead code removal, controlled refactoring, and repo continuity doc sync.

Works with **Codex, Claude Code, Cursor, Windsurf, and 40+ other agents** via `npx skills`.

---

## Install

```bash
# Install all skills into your current project
npx skills add afu-it/safe-code

# Install globally (available in all your projects)
npx skills add afu-it/safe-code -g

# Preview what's available before installing
npx skills add afu-it/safe-code --list
```

---

## Usage

### One command to do everything

```
/safe-code
```

Detects your active agent, audits dead code, removes high-confidence candidates, refactors affected areas, and saves all continuity docs into your agent's own folder:

```
.codex/memory/    ← if using Codex
.claude/memory/   ← if using Claude Code
.cursor/memory/   ← if using Cursor
```

`AGENTS.md` always stays at the repo root.

---

## Skills

### `safe-code` — full hygiene in one pass
Orchestrates `codebase-pruner` and `safe-refactor-code` in the correct order. Invoke with `/safe-code`.

### `codebase-pruner` — dead code detection and removal
Scans the full codebase, builds a reference graph from real entrypoints, scores candidates by confidence and blast radius, then removes only High confidence dead code in verified slices.

```
Use $codebase-pruner in Audit mode
Use $codebase-pruner in Dry-Run mode
Use $codebase-pruner in Execute mode
Use $codebase-pruner Targeted on src/handlers/
```

### `safe-refactor-code` — refactor with doc sync
Refactors code in safe slices and keeps `AGENTS.md`, `MEMORY.md`, `CHANGELOG.md`, and `safe-refactor-code.md` up to date inside the active agent's folder.

```
Use $safe-refactor-code to clean up the auth module
```

---

## New to skills?

Read [TUTORIAL.md](./TUTORIAL.md) for a step-by-step guide including how to update and remove skills.
