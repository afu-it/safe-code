# safe-code

A collection of agent skills for safe code maintenance — dead code removal, controlled refactoring, and repo continuity doc sync.

## Skills

### `codebase-pruner`
Scan an entire codebase for dead code, estimate deletion risk, and remove only high-confidence candidates in verified slices.

**Use when:** code accumulates after workflow changes, old handlers/routes/modules are never cleaned up, or the codebase feels heavy.

```
Use $codebase-pruner in Audit mode on this repo
Use $codebase-pruner in Execute mode
Use $codebase-pruner Targeted on src/handlers/ only
```

---

### `safe-refactor-code`
Refactor code in safe slices while keeping repo continuity docs (`AGENTS.md`, `MEMORY.md`, `CHANGELOG.md`) in sync.

**Use when:** restructuring code and need future agents to resume without losing context.

```
Use $safe-refactor-code to clean up the auth module
Use $safe-refactor-code and keep AGENTS.md updated
```

---

### `repo-hygiene`
Full hygiene pass in one go — orchestrates `codebase-pruner` then `safe-refactor-code`.

**Use when:** you want dead code removal + refactor + doc sync in a single session.

```
Use $repo-hygiene on this repo
```

## Install

Copy the skill folder(s) you want into your agent's skills directory.

**Global (all projects):**
```
~/.codex/skills/codebase-pruner/
~/.codex/skills/safe-refactor-code/
~/.codex/skills/repo-hygiene/
```

**Per-project:**
```
your-project/.codex/skills/codebase-pruner/
your-project/.codex/skills/safe-refactor-code/
your-project/.codex/skills/repo-hygiene/
```

Each folder contains one `SKILL.md` file. No other dependencies required.
