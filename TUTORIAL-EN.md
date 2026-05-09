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
⠋ Installing build-graph...
✔ Installed → ~/.codex/skills/build-graph
⠋ Installing explore-codebase...
✔ Installed → ~/.codex/skills/explore-codebase
⠋ Installing review-changes...
✔ Installed → ~/.codex/skills/review-changes
⠋ Installing debug-issue...
✔ Installed → ~/.codex/skills/debug-issue
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
  ┌─────────────────────────────────────────────────────────┐
  │  Step 0  Detect which agent you use                     │
  │  Step 1  Create 8 project docs + populate AGENTS.md     │
  │  Step 2  Load context                                   │
  │  Step 3  Check git & backup                             │
  │  Step 4  Scan for dead code                             │
  │  Step 5  Show plan (asks you first)                     │
  │  Step 6  Delete dead code slice by slice                │
  │  Step 7  Refactor + update all docs                     │
  │  Step 8  Print final report                             │
  └─────────────────────────────────────────────────────────┘
```

**You don't need to do anything** — just watch it work. If it's unsure about something, it will ask you before proceeding.

### What happens to AGENTS.md?

On setup, safe-code scans your repo **before deciding what to do with `AGENTS.md`**:

- It reads your `README`, config files, CI workflows, package manager files, and any existing instruction files
- It extracts real, verified facts — exact commands, your stack, folder structure, quirks
- If `AGENTS.md` already exists but is mostly empty or just auto-generated boilerplate, it fills it in properly
- If `AGENTS.md` is short or generic, it treats it as thin and upgrades it into a useful handoff file
- If `AGENTS.md` already has useful content, it audits and reconciles the file in place without overwriting anything good

---

## 💾 Want to End the Session?

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
  ✔  git init (if needed)
  ✔  git add -A
  ✔  git commit (with auto-generated message)
  ✔  Print: commit hash + local-only status
  ✔  Close this safe-code session
```

Next time you run `/safe-code`, it **auto-detects** the closed session and picks up from `ACTIVE.md`.

---

## 📁 What Files Get Created?

After the first run, your project will have this structure:

```
your-project/
├── AGENTS.md                    ← project rules, stack & real dev commands
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
> 💡 **AGENTS.md** = populated with real project context, not generic placeholders

---

## 🎛️ Only Two Commands

You only need these:

| What you want to do | Command |
|---|---|
| Start or continue safe repo hygiene | `/safe-code` |
| Save docs, commit locally, and close session | `/safe-code save` |

safe-code chooses the safest internal mode automatically: orientation, audit, or cleanup. It also auto-runs helper skills for graph build, repo exploration, dead-code pruning, refactor checks, review, and debugging when needed.

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
# Remove all seven
npx skills remove safe-code codebase-pruner safe-refactor-code build-graph explore-codebase review-changes debug-issue

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

**"Why does AGENTS.md look detailed after the first run?"**  
Because safe-code scans your repo first before writing it. The goal is a file that any AI agent can read and immediately understand your project — your stack, your commands, your quirks — without asking.

**"How do I know if the skill is installed?"**  
```bash
npx skills list
```

---

## 💡 Tips for Beginners

**Start with `/safe-code`.**  
If your repo is new, dirty, or risky, it will naturally stay in audit/documentation mode.

**Make sure git is clean before starting.**  
Run `git status` first. If you have uncommitted changes, do `git commit` before running the skill. This gives you a safety net.

**Don't be afraid.**  
This skill was designed to be safe. The agent asks you when it has doubts. You are always in control.
