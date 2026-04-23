# safe-code

A collection of agent skills for safe code maintenance — dead code removal, controlled refactoring, and repo continuity doc sync.

Works with **Codex, Claude Code, Cursor, Windsurf, and 40+ other agents** via `npx skills`.

---

## Install

### Recommended — npx skills (one command)

```bash
# Install all skills into your current project
npx skills add afu-it/safe-code

# Install globally (available in all your projects)
npx skills add afu-it/safe-code -g

# Install only specific skills
npx skills add afu-it/safe-code --skill codebase-pruner
npx skills add afu-it/safe-code --skill safe-refactor-code
npx skills add afu-it/safe-code --skill repo-hygiene

# See what skills are available before installing
npx skills add afu-it/safe-code --list
```

### Manual install

```bash
git clone https://github.com/afu-it/safe-code.git
cp -r safe-code/skills/codebase-pruner ~/.codex/skills/
cp -r safe-code/skills/safe-refactor-code ~/.codex/skills/
cp -r safe-code/skills/repo-hygiene ~/.codex/skills/
```

---

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

---

## New to skills?

Read [TUTORIAL.md](./TUTORIAL.md) for a beginner-friendly step-by-step guide.
