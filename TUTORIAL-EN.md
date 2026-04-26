# Tutorial: How to Use safe-code

> **For anyone brand new to coding or AI tools** — we start from scratch, step by step, with visuals.

---

## 🤔 What Is a Skill?

Imagine you have an **AI chef**. A skill is like a **recipe** you hand them:

```
  You           Skill (Recipe)      AI Agent
  ───           ──────────────      ────────
  "please        safe-code         "Got it, I
   clean up       SKILL.md    →     know exactly
   my code"       (instructions)    what to do"
```

Without a skill, the AI agent doesn't know the safe procedure for cleaning code. With a skill, it follows the right process — audit first, plan, verify, then delete.

---

## ✅ Before You Start — Check These 3 Things

### 1. Do you have Node.js?

Open your **Terminal** (or Command Prompt) and type:

```bash
node --version
```

If you see a number like `v20.11.0` → ✅ you're good.  
If you get an error → install it first from [nodejs.org](https://nodejs.org) (pick LTS).

> **What's a Terminal?**  
> The Terminal is a black box where you give your computer instructions by typing.  
> Windows: search for "Command Prompt" or "PowerShell"  
> Mac: go to Applications → Utilities → Terminal

### 2. Do you have Git?

```bash
git --version
```

If you see a version number → ✅ you're good.  
If you get an error → install it from [git-scm.com](https://git-scm.com).

### 3. Is your project in a git folder?

```bash
cd your-project-name
git status
```

If you see any output (even "nothing to commit") → ✅ you're good.  
If you see `not a git repository` → run `git init` first.

---

## 📦 Step 1 — Install the Skill

Open your terminal, navigate to your project folder, then type:

```bash
npx skills add afu-it/safe-code
```

Hit Enter. Wait a few seconds. You'll see:

```
⠋ Detecting your agent...
✔ Found: Codex
⠋ Installing safe-code...
✔ Installed → ~/.codex/skills/safe-code
⠋ Installing codebase-pruner...
✔ Installed → ~/.codex/skills/codebase-pruner
⠋ Installing safe-refactor-code...
✔ Installed → ~/.codex/skills/safe-refactor-code
✔ Done!
```

The skills go directly into your agent's folder automatically. **You don't need to know which folder** — it figures that out for you.

> **Want to install for ALL your projects at once?**
> ```bash
> npx skills add afu-it/safe-code -g
> ```
> `-g` = global (every project on your machine)

> **Want to preview what's included before installing?**
> ```bash
> npx skills add afu-it/safe-code --list
> ```

---

## 🚀 Step 2 — Use the Skill

Open your project in your **AI agent** (Codex, Claude Code, Cursor, or Windsurf).

Then type this in the chat:

```
/safe-code
```

Hit Enter. The agent will do all of this automatically:

```
  /safe-code
      │
      ▼
  ┌─────────────────────────────────────────┐
  │  Step 0  Detect which agent you use     │
  │  Step 1  Create 8 project record files  │
  │  Step 2  Load context                   │
  │  Step 3  Check git & backup             │
  │  Step 4  Scan for dead code             │
  │  Step 5  Show plan (asks you first)     │
  │  Step 6  Delete dead code slice by slice│
  │  Step 7  Refactor + update all docs     │
  │  Step 8  Print final report             │
  └─────────────────────────────────────────┘
```

**You don't need to do anything** — just watch it work. If it's unsure about something, it will ask you before proceeding.

---

## 💾 Want to Save Your Progress?

If you want to stop and continue tomorrow, or switch to another project:

```
/safe-code save
```

It will automatically do **11 things** in a few seconds:

```
  ✔  Save progress → ACTIVE.md
  ✔  Write to diary → LOG.md
  ✔  Update architecture → MEMORY.md
  ✔  Clear working notes → SESSION.md
  ✔  git add -A
  ✔  git commit (with auto-generated message)
  ✔  git push
  ✔  Print: commit hash + status
```

Next time you run `/safe-code`, it **auto-detects** the saved session and picks up where it left off.

---

## 📁 What Files Get Created?

After the first run, your project will have this structure:

```
your-project/
├── AGENTS.md                    ← project rules & standards
├── CHANGELOG.md                 ← history of changes
└── .codex/                      ← (or .claude/ .cursor/ .windsurf/)
    └── agents/
        ├── ACTIVE.md            ← current status  (like a hard drive 💾)
        ├── SESSION.md           ← working notes   (like RAM 🧠)
        ├── LOG.md               ← diary of all decisions
        ├── BACKLOG.md           ← list of pending tasks
        ├── MEMORY.md            ← big picture of the project
        └── safe-refactor-code.md ← refactor rules
```

> 💡 **ACTIVE.md** = like a hard drive — persists even after you close everything
> 💡 **SESSION.md** = like RAM — cleared every time you run `/safe-code save`

---

## 🎛️ Other Commands (Optional)

If you want more control:

| What you want to do | Command |
|---|---|
| Full cleanup in one pass | `/safe-code` |
| Save & push progress | `/safe-code save` |
| Scan only, don't delete anything | `Use $codebase-pruner in Audit mode` |
| See the plan without doing anything | `Use $codebase-pruner in Dry-Run mode` |
| Execute the deletion | `Use $codebase-pruner in Execute mode` |
| Clean one specific folder only | `Use $codebase-pruner Targeted on src/folder/` |
| Refactor + update docs | `Use $safe-refactor-code` |

---

## 🔄 Updating the Skill

When a new version is available:

```bash
# Update all skills
npx skills update

# Check for updates without installing
npx skills check

# Update one specific skill
npx skills update --skill safe-code
```

---

## 🗑️ Removing the Skill

```bash
# Remove all three
npx skills remove safe-code codebase-pruner safe-refactor-code

# Remove just one
npx skills remove safe-code
```

> **Note:** Removing the skill does not delete the docs already created in your project (`AGENTS.md`, `.codex/`, etc.). Those stay unless you delete them manually.

---

## ❓ Questions Beginners Usually Ask

**"Does the AI delete things without asking me?"**  
No. It shows you the plan first and asks whenever it's unsure. It only deletes code it's confident about — and it verifies each small slice before moving on.

**"What if the agent accidentally deletes something important?"**  
It auto-rolls back if any slice fails verification. And because you have git, you can always run `git checkout -- filename` to restore any file.

**"Do I need internet to use this?"**  
Only during install (`npx skills add ...`). After that, the skills live on your machine — no internet needed.

**"Will this delete my actual source code?"**  
It only removes **dead code** — code that nothing in the project calls or uses anymore. All active code is untouched.

**"How do I know if the skill is installed?"**  
```bash
npx skills list
```

---

## 💡 Tips for Beginners

**Start with Audit mode.**  
Before letting the agent do real work, use `Audit mode` to see what it finds. Read the report, understand what it flagged, then decide to proceed.

**Make sure git is clean before starting.**  
Run `git status` first. If you have uncommitted changes, do `git commit` before running the skill. This gives you a safety net.

**When in doubt, use Dry-Run.**  
`Dry-Run mode` shows you the full deletion plan without doing anything. Think of it as a preview — see what would happen before it actually happens.

**Don't be afraid.**  
This skill was designed to be safe. The agent asks you when it has doubts. You are always in control.
