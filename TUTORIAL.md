# Tutorial: How to Use safe-code Skills

A beginner-friendly guide to installing, using, updating, and removing these skills with AI coding agents like Codex, Claude Code, Cursor, and others.

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
npx skills add afu-it/safe-code --skill safe-code
npx skills add afu-it/safe-code --skill codebase-pruner
npx skills add afu-it/safe-code --skill safe-refactor-code
```

---

### Alternative — manual install

```bash
git clone https://github.com/afu-it/safe-code.git

# For Codex (global):
cp -r safe-code/skills/safe-code ~/.codex/skills/
cp -r safe-code/skills/codebase-pruner ~/.codex/skills/
cp -r safe-code/skills/safe-refactor-code ~/.codex/skills/

# For Claude Code (global):
cp -r safe-code/skills/safe-code ~/.claude/skills/
cp -r safe-code/skills/codebase-pruner ~/.claude/skills/
cp -r safe-code/skills/safe-refactor-code ~/.claude/skills/

# For Cursor (global):
cp -r safe-code/skills/safe-code ~/.cursor/skills/
cp -r safe-code/skills/codebase-pruner ~/.cursor/skills/
cp -r safe-code/skills/safe-refactor-code ~/.cursor/skills/
```

Or for one specific project only:

```bash
mkdir -p your-project/.agents/skills
cp -r safe-code/skills/safe-code your-project/.agents/skills/
cp -r safe-code/skills/codebase-pruner your-project/.agents/skills/
cp -r safe-code/skills/safe-refactor-code your-project/.agents/skills/
```

---

## Step 2: Open Your Project

Open your project in VS Code (or your preferred editor) with your AI agent active — Codex, Claude Code, Cursor, or whichever you use.

---

## Step 3: Use the Skills

### The main command — runs everything at once

```
/safe-code
```

That's it. This one command will:

1. Detect which agent you're using (Codex, Claude, Cursor, etc.)
2. Audit the full codebase for dead code
3. Show the deletion plan for your review
4. Delete only high-confidence dead code, slice by slice
5. Refactor any messy areas left behind
6. Save all docs into your agent's own folder automatically:
   - Codex → `.codex/memory/`
   - Claude → `.claude/memory/`
   - Cursor → `.cursor/memory/`

`AGENTS.md` is always kept at the repo root — all agents read it from there.

---

### Individual skills — when you want more control

| What you want to do | Command |
|---|---|
| Full cleanup in one pass | `/safe-code` |
| Find dead code only (no deletions) | `Use $codebase-pruner in Audit mode` |
| See deletion plan only | `Use $codebase-pruner in Dry-Run mode` |
| Delete dead code | `Use $codebase-pruner in Execute mode` |
| Clean one folder only | `Use $codebase-pruner Targeted on src/folder/` |
| Refactor + sync docs | `Use $safe-refactor-code` |

---

### Real scenario examples

**After changing a workflow and leaving old code behind:**
```
/safe-code
```

**Just want to see what's dead before touching anything:**
```
Use $codebase-pruner in Audit mode on this repo
```

**Refactored the auth module, want docs updated:**
```
Use $safe-refactor-code to clean up the auth module and keep AGENTS.md updated
```

**Clean up only the handlers folder:**
```
Use $codebase-pruner Targeted on src/handlers/ only
```

---

## Step 4: What Gets Created

After running `/safe-code`, your project will have these files:

```
your-project/
├── AGENTS.md                          ← at root, readable by all agents
├── .codex/                            ← (or .claude/, .cursor/, etc.)
│   └── memory/
│       ├── MEMORY.md                  ← working snapshot of repo state
│       ├── CHANGELOG.md               ← dated log of changes
│       └── safe-refactor-code.md      ← repo-specific refactor rules
```

These help future agents resume work without rereading the whole codebase.

---

## Updating Skills

### Update to latest version

```bash
# Update all installed skills
npx skills update

# Check if updates are available without updating
npx skills check
```

### Update one specific skill

```bash
npx skills update --skill safe-code
npx skills update --skill codebase-pruner
npx skills update --skill safe-refactor-code
```

### Manual update

```bash
cd safe-code
git pull origin master

# Then re-copy the updated skill folders
cp -r skills/safe-code ~/.codex/skills/
cp -r skills/codebase-pruner ~/.codex/skills/
cp -r skills/safe-refactor-code ~/.codex/skills/
```

---

## Removing Skills

### Remove via npx

```bash
# Remove one skill
npx skills remove safe-code
npx skills remove codebase-pruner
npx skills remove safe-refactor-code

# Remove all three
npx skills remove safe-code codebase-pruner safe-refactor-code
```

### Manual removal

```bash
# Remove from global Codex skills
rm -rf ~/.codex/skills/safe-code
rm -rf ~/.codex/skills/codebase-pruner
rm -rf ~/.codex/skills/safe-refactor-code

# Remove from global Claude skills
rm -rf ~/.claude/skills/safe-code
rm -rf ~/.claude/skills/codebase-pruner
rm -rf ~/.claude/skills/safe-refactor-code

# Remove from a specific project
rm -rf your-project/.agents/skills/safe-code
rm -rf your-project/.agents/skills/codebase-pruner
rm -rf your-project/.agents/skills/safe-refactor-code
```

> Note: Removing the skills does not delete the docs already created in your repo (`.codex/memory/`, `AGENTS.md`, etc.). Those stay unless you delete them manually.

---

## Listing Installed Skills

```bash
# List all installed skills (project + global)
npx skills list

# List global skills only
npx skills ls -g

# List for a specific agent
npx skills ls -a codex
npx skills ls -a claude-code
```

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
Before running `/safe-code`, make sure you have no uncommitted changes. Run `git status` first. If there are changes, commit or stash them before proceeding.

**Docs go into your agent's folder automatically.**
You don't need to configure anything. The skill detects whether you're using Codex, Claude, or Cursor and saves docs into the right place.
