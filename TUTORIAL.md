# Tutorial: How to Use safe-code Skills

A beginner-friendly guide to installing and using these skills with AI coding agents like Codex (VS Code) or any agent that supports the agentskills format.

---

## What Are Skills?

Skills are instruction files that tell an AI agent *how* to do a specific task — like a recipe the agent follows. You install them once, then invoke them by name in any conversation.

---

## Step 1: Install the Skills

Pick one of these methods depending on how you work.

### Option A: Global Install (works in all your projects)

Copy the skill folders into your global Codex skills directory:

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.codex/skills

# Clone this repo
git clone https://github.com/afu-it/safe-code.git

# Copy skills into global directory
cp -r safe-code/skills/codebase-pruner ~/.codex/skills/
cp -r safe-code/skills/safe-refactor-code ~/.codex/skills/
cp -r safe-code/skills/repo-hygiene ~/.codex/skills/
```

### Option B: Per-Project Install (only for one specific project)

```bash
# Go into your project folder
cd your-project/

# Create the local skills directory
mkdir -p .codex/skills

# Clone and copy
git clone https://github.com/afu-it/safe-code.git /tmp/safe-code
cp -r /tmp/safe-code/skills/codebase-pruner .codex/skills/
cp -r /tmp/safe-code/skills/safe-refactor-code .codex/skills/
cp -r /tmp/safe-code/skills/repo-hygiene .codex/skills/
```

After install, your folder should look like this:

```
~/.codex/skills/               ← global
└── codebase-pruner/
    └── SKILL.md
└── safe-refactor-code/
    └── SKILL.md
└── repo-hygiene/
    └── SKILL.md
```

---

## Step 2: Open Your Project in VS Code with Codex

1. Open VS Code
2. Open your project folder
3. Open the Codex panel (or your agent chat)
4. Make sure the agent can see your project files

---

## Step 3: Use the Skills

Just type naturally in the agent chat. Use `$skill-name` to invoke a specific skill.

---

### Scenario 1: You want to find dead code (safe, no deletions)

> Good for: first time, not sure what's dead, want to review before anything is deleted.

```
Use $codebase-pruner in Audit mode on this repo
```

The agent will scan your project and return a report like this:

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

Review the list. Nothing is deleted yet.

---

### Scenario 2: You want to see the deletion plan before doing anything

```
Use $codebase-pruner in Dry-Run mode
```

The agent will show you exactly what it plans to delete, in what order, with rollback steps — but still won't touch any files.

---

### Scenario 3: You're ready to actually delete dead code

```
Use $codebase-pruner in Execute mode
```

The agent will delete High confidence candidates only, one slice at a time, and verify after each deletion. It stops automatically if something breaks.

---

### Scenario 4: You only want to clean up one specific folder

```
Use $codebase-pruner Targeted on src/handlers/ only
```

---

### Scenario 5: You refactored some code and want docs kept in sync

> Good for: after changing how a module works, and you want AGENTS.md, CHANGELOG.md updated automatically.

```
Use $safe-refactor-code to clean up the auth module and keep AGENTS.md updated
```

The agent will:
- Refactor the code in safe slices
- Update or create `AGENTS.md`, `MEMORY.md`, `CHANGELOG.md` with what changed
- Do a hygiene pass to remove any leftover dead imports

---

### Scenario 6: Full cleanup in one go (recommended for messy repos)

```
Use $repo-hygiene on this repo
```

This runs everything in order:
1. Audit dead code
2. Show you the plan
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
Never jump straight to Execute on a project you haven't audited. The Audit report helps you understand what will be deleted and why.

**Medium and Low confidence candidates are never auto-deleted.**
The agent will flag them and ask you to review. You are always in control.

**If something breaks, the agent rolls back.**
Each deletion is a small slice. If verification fails after a slice, the agent restores that slice and stops — it does not continue blindly.

**Skills work best on git repos.**
Make sure your project is a git repo (`git init`) before running Execute mode. This gives you a safety net — you can always run `git checkout -- filename` to restore any file.

**Start with a clean git state.**
Before running Execute, make sure you have no uncommitted changes. Run `git status` first. If there are changes, commit or stash them.

---

## Folder Structure After Using the Skills

After a hygiene pass, your repo may have these new files:

```
your-project/
├── AGENTS.md          ← agent handoff notes (what was done, what's next)
├── MEMORY.md          ← short snapshot of current repo state
├── CHANGELOG.md       ← dated log of code changes
└── safe-refactor-code.md  ← repo-specific refactor rules for future runs
```

These files help future agents (or future you) understand the repo without rereading the whole history.
