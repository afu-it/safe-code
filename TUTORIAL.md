# Tutorial: How to Use safe-code Skills

A beginner-friendly guide to installing and using these skills with AI coding agents like Codex, Claude Code, Cursor, and others.

---

## What Are Skills?

Skills are instruction files that tell an AI agent *how* to do a specific task — like a recipe the agent follows. You install them once, then invoke them by name in any conversation.

---

## Step 1: Install the Skills

### Recommended — one command with npx

You need Node.js installed. Then run:

```bash
# Install all skills into your current project
npx skills add afu-it/safe-code

# Or install globally (works in all your projects)
npx skills add afu-it/safe-code -g
```

The CLI will auto-detect which agent you use (Codex, Claude Code, Cursor, etc.) and put the skills in the right place automatically.

Want to see what's available before installing?

```bash
npx skills add afu-it/safe-code --list
```

Want only one specific skill?

```bash
npx skills add afu-it/safe-code --skill codebase-pruner
npx skills add afu-it/safe-code --skill safe-refactor-code
npx skills add afu-it/safe-code --skill repo-hygiene
```

---

### Alternative — manual install

If you prefer not to use npx:

```bash
# Clone the repo
git clone https://github.com/afu-it/safe-code.git

# Copy into your agent's skills folder
# For Codex:
cp -r safe-code/skills/codebase-pruner ~/.codex/skills/
cp -r safe-code/skills/safe-refactor-code ~/.codex/skills/
cp -r safe-code/skills/repo-hygiene ~/.codex/skills/

# For Claude Code:
cp -r safe-code/skills/codebase-pruner ~/.claude/skills/
cp -r safe-code/skills/safe-refactor-code ~/.claude/skills/
cp -r safe-code/skills/repo-hygiene ~/.claude/skills/

# For Cursor:
cp -r safe-code/skills/codebase-pruner ~/.cursor/skills/
cp -r safe-code/skills/safe-refactor-code ~/.cursor/skills/
cp -r safe-code/skills/repo-hygiene ~/.cursor/skills/
```

Or for one specific project only:

```bash
mkdir -p your-project/.agents/skills
cp -r safe-code/skills/codebase-pruner your-project/.agents/skills/
cp -r safe-code/skills/safe-refactor-code your-project/.agents/skills/
cp -r safe-code/skills/repo-hygiene your-project/.agents/skills/
```

---

## Step 2: Open Your Project

Open your project in VS Code (or your preferred editor) with your AI agent active — Codex, Claude Code, Cursor, or whichever you use.

---

## Step 3: Use the Skills

Just type naturally in the agent chat. Use `$skill-name` to invoke a specific skill.

---

### Scenario 1: Find dead code — no deletions yet

> Good first step. Safe to run anytime.

```
Use $codebase-pruner in Audit mode on this repo
```

The agent scans your project and returns a report like this:

```
Entrypoints mapped: 5
Files scanned: 97

Dead code inventory:
[HIGH] Orphaned module: src/handlers/old-webhook.js — no live imports
[HIGH] Dead function: src/utils/format.js:legacyDate — 0 callers
[MEDIUM] Suspected dead: src/api/v1.js — dynamic dispatch risk

Total confirmed dead: 2
Total suspected dead: 1
Recommended next step: Dry-Run
```

Nothing is deleted yet.

---

### Scenario 2: See the deletion plan before doing anything

```
Use $codebase-pruner in Dry-Run mode
```

The agent shows exactly what it plans to delete, in what order, with rollback steps — but still won't touch any files.

---

### Scenario 3: Actually delete the dead code

```
Use $codebase-pruner in Execute mode
```

Deletes High confidence candidates only, one slice at a time, and verifies after each deletion. Stops automatically if something breaks.

---

### Scenario 4: Clean up only one specific folder

```
Use $codebase-pruner Targeted on src/handlers/ only
```

---

### Scenario 5: Refactor and keep docs in sync

> Good after restructuring a module, so future agents know what changed.

```
Use $safe-refactor-code to clean up the auth module and keep AGENTS.md updated
```

The agent will:
- Refactor the code in safe slices
- Update or create `AGENTS.md`, `MEMORY.md`, `CHANGELOG.md`
- Do a hygiene pass to remove stale imports or doc references

---

### Scenario 6: Full cleanup in one go

```
Use $repo-hygiene on this repo
```

Runs everything in order:
1. Audit dead code
2. Show the deletion plan
3. Delete High confidence dead code
4. Refactor affected areas
5. Sync all docs

---

## Quick Reference

| What you want to do | Command |
|---|---|
| Find dead code (no deletions) | `Use $codebase-pruner in Audit mode` |
| See deletion plan only | `Use $codebase-pruner in Dry-Run mode` |
| Delete dead code | `Use $codebase-pruner in Execute mode` |
| Clean one folder only | `Use $codebase-pruner Targeted on src/folder/` |
| Refactor + sync docs | `Use $safe-refactor-code` |
| Full cleanup in one pass | `Use $repo-hygiene` |

---

## Tips for Beginners

**Always Audit before Execute.**
Never jump straight to Execute on a project you haven't audited. The report helps you understand what will be deleted.

**Medium and Low confidence candidates are never auto-deleted.**
The agent flags them and asks you to review. You are always in control.

**If something breaks, the agent rolls back.**
Each deletion is one small slice. If verification fails, the agent restores that slice and stops — it does not continue blindly.

**Skills work best on git repos.**
Make sure your project is a git repo (`git init`) before running Execute mode. This gives you a safety net — you can always run `git checkout -- filename` to restore any file.

**Start with a clean git state.**
Before running Execute, make sure you have no uncommitted changes. Run `git status` first. If there are changes, commit or stash them before proceeding.

---

## Folder Structure After Using the Skills

After a hygiene pass, your repo may have these new files:

```
your-project/
├── AGENTS.md              ← agent handoff notes (what was done, what's next)
├── MEMORY.md              ← short snapshot of current repo state
├── CHANGELOG.md           ← dated log of code changes
└── safe-refactor-code.md  ← repo-specific refactor rules for future runs
```

These help future agents (or future you) understand the repo without rereading the whole history.

---

## Update Skills

```bash
# Update all installed skills to latest version
npx skills update

# Check if updates are available
npx skills check
```

## List What's Installed

```bash
npx skills list
npx skills ls -g   # global only
```
