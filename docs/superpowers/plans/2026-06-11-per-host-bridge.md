# Per-Host Provider Bridge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On each `/safe-code` run, write the provider bridge for the host actually running (plus the always-written `AGENTS.md`) instead of unconditionally writing all four; other hosts' bridges accrue lazily when safe-code later runs under them. Bump to v4.4.

**Architecture:** Pure documentation/script edits. No test runner — each task applies an exact-string `Edit` and verifies with `grep` (the repo's harness). The behavior change lives in the instructions `SKILL.md` gives the agent at scaffold time; `check.sh`'s advisory bridge block is relaxed to match. No safety rule is removed; the undetectable-host fallback reproduces v4.3 behavior exactly.

**Tech Stack:** Markdown (Claude Code skill format), Bash, `git`, `grep`.

**Source spec:** `docs/superpowers/specs/2026-06-11-per-host-bridge-design.md`

---

## File Structure

| File | Change | Responsibility |
|---|---|---|
| `skills/safe-code/SKILL.md` | Modify (5 regions) | Provider Bridge logic (detect + lazy + fallback), Step 1 scaffold list, Step 1c output, Doc Structure prose (~line 60), version (frontmatter + Step 8 banner) |
| `skills/safe-code/references/doc-templates.md` | Modify (1 region) | Provider Bridge Files intro note — only current host's bridge per run |
| `scripts/check.sh` | Modify (1 region) | Advisory bridge block: missing bridge `warn` → `info` (lazy-aware) |
| `README.md` | Modify (4 regions) | Bridge prose (lines 85, 115), badge, What's New v4.4 |
| `TUTORIAL-EN.md` | Modify (1 region) | Bridge paragraph (line 73) |
| `TUTORIAL-BM.md` | Modify (1 region) | Bridge paragraph (line 73), parallel to EN |

All edits are in-place; no existing safety rule is removed.

**Pre-flight (run once before Task 1):**

Run: `grep -n 'version: "4.3"\|safe-code v4.3 session complete\|version-4.3' skills/safe-code/SKILL.md README.md`
Expected: 3 matches (SKILL.md:4 frontmatter, SKILL.md:1223 banner, README.md:5 badge). Confirms version anchors present before editing.

---

## Task 1: SKILL.md — Provider Bridge logic (detect + lazy + fallback)

**Files:**
- Modify: `skills/safe-code/SKILL.md` (Provider Bridge section, ~519-536)

- [ ] **Step 1: Rewrite the Provider Bridge intro to describe per-host detection**

Edit — replace exactly:

```
`AGENTS.md` + `.safe-code/` are the source of truth, but not every host auto-reads `AGENTS.md`. So safe-code writes thin **pointer** files in each major host's native config location, so a fresh chat in any provider loads the same brain without the user invoking safe-code:
```

with:

```
`AGENTS.md` + `.safe-code/` are the source of truth, but not every host auto-reads `AGENTS.md`. So safe-code writes a thin **pointer** file in the host's native config location so a fresh chat in that provider loads the same brain without the user invoking safe-code. **Write only the bridge for the host you are currently running in** — identify your host from your own environment/system context and use the table below as a lookup. Other hosts' bridges are not written now; they accrue lazily the next time safe-code runs under them.
```

- [ ] **Step 2: Add detect/lazy/fallback rules to the Rules list**

Edit — replace exactly:

```
- Bridges are **pointers, not state** — each is a few lines that redirect to `AGENTS.md` + `.safe-code/context/`. Never duplicate project facts into them.
```

with:

```
- Bridges are **pointers, not state** — each is a few lines that redirect to `AGENTS.md` + `.safe-code/context/`. Never duplicate project facts into them.
- **Write only the current host's bridge** (the one matching the table row for the host you are running in). `AGENTS.md` is always written; the other hosts' bridges are deferred, not written this run.
- **Host not in the table** (e.g. Codex, Windsurf): write `AGENTS.md` only — those hosts read it directly, no bridge file needed.
- **Host undetectable** (you genuinely cannot tell which host you are): fall back to writing all four bridges — identical to pre-v4.4 behavior, so a run is never worse than before.
- **Never delete** an existing bridge. Lazy accrual means each host self-registers its bridge the first time safe-code runs under it; bridges for other hosts already in the repo are preserved.
```

- [ ] **Step 3: Verify the logic edits landed and old intro is gone**

Run: `grep -n 'Write only the bridge for the host you are currently running in\|Host undetectable\|accrue lazily' skills/safe-code/SKILL.md`
Expected: 3 matches.

Run: `grep -n 'writes thin \*\*pointer\*\* files in each major host' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 2: SKILL.md — Step 1 scaffold list + Step 1c output

**Files:**
- Modify: `skills/safe-code/SKILL.md` (Step 1 scaffold list ~452-456; Step 1c `Bridges:` line ~601)

- [ ] **Step 1: Mark the bridge entries in the scaffold list as current-host-only**

Edit — replace exactly:

```
CLAUDE.md                        (provider bridge — pointer only)
GEMINI.md                        (provider bridge — pointer only)
.github/copilot-instructions.md  (provider bridge — pointer only)
.cursor/rules/safe-code.mdc      (provider bridge — pointer only)
```

with:

```
<current host's bridge only — see Provider Bridge below; pointer, not state>
CLAUDE.md                        (bridge — only if running in Claude Code)
GEMINI.md                        (bridge — only if running in Gemini CLI)
.github/copilot-instructions.md  (bridge — only if running in GitHub Copilot)
.cursor/rules/safe-code.mdc      (bridge — only if running in Cursor)
```

- [ ] **Step 2: Update the Step 1c confirm output for per-host reporting**

Edit — replace exactly:

```
Bridges: CLAUDE.md / GEMINI.md / copilot-instructions.md / cursor rule - <created|exists|appended|skipped>
```

with:

```
Bridges: <current host's bridge> - <created|exists|appended>; others deferred (written when safe-code runs under that host). Undetectable host -> all four reported.
```

- [ ] **Step 3: Verify**

Run: `grep -n 'only if running in Claude Code\|others deferred (written when safe-code runs under that host)' skills/safe-code/SKILL.md`
Expected: 2 matches.

Run: `grep -n 'CLAUDE.md                        (provider bridge — pointer only)' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 3: SKILL.md — Doc Structure prose (~line 60)

**Files:**
- Modify: `skills/safe-code/SKILL.md:60`

- [ ] **Step 1: Reword the "writes thin provider-bridge pointers" sentence**

Edit — replace exactly:

```
It also writes thin **provider-bridge pointers** (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`) so hosts that do not auto-read `AGENTS.md` still load the same brain.
```

with:

```
It also writes a thin **provider-bridge pointer** for the host it is currently running in (`CLAUDE.md` for Claude Code, `GEMINI.md` for Gemini, `.github/copilot-instructions.md` for Copilot, `.cursor/rules/safe-code.mdc` for Cursor) so that host loads the same brain without auto-reading `AGENTS.md`; other hosts' bridges accrue lazily when safe-code later runs under them.
```

- [ ] **Step 2: Verify**

Run: `grep -n 'a thin \*\*provider-bridge pointer\*\* for the host it is currently running in' skills/safe-code/SKILL.md`
Expected: 1 match.

Run: `grep -n 'writes thin \*\*provider-bridge pointers\*\* (`CLAUDE.md`, `GEMINI.md`' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 4: SKILL.md — version bump (frontmatter + Step 8 banner)

**Files:**
- Modify: `skills/safe-code/SKILL.md:4` and `:1223`

- [ ] **Step 1: Bump frontmatter version**

Edit — replace exactly:

```
version: "4.3"
```

with:

```
version: "4.4"
```

- [ ] **Step 2: Bump Step 8 banner**

Edit — replace exactly:

```
=== safe-code v4.3 session complete ===
```

with:

```
=== safe-code v4.4 session complete ===
```

- [ ] **Step 3: Verify**

Run: `grep -n 'version: "4.4"\|safe-code v4.4 session complete' skills/safe-code/SKILL.md`
Expected: 2 matches.

Run: `grep -n '4\.3' skills/safe-code/SKILL.md`
Expected: no output (exit 1).

---

## Task 5: doc-templates.md — Provider Bridge Files note

**Files:**
- Modify: `skills/safe-code/references/doc-templates.md:535` (the note under the section heading)

- [ ] **Step 1: Add per-host note to the Provider Bridge Files intro**

Edit — replace exactly:

```
> Thin redirects so hosts that do not auto-read `AGENTS.md` still load the same brain.
> Never overwrite a user's existing file; if it exists without a `<!-- safe-code:bridge -->`
> block, append the block instead of replacing the file.
```

with:

```
> Thin redirects so hosts that do not auto-read `AGENTS.md` still load the same brain.
> Write only the bridge for the host currently running (see SKILL.md Provider Bridge); the
> templates below are the shapes for each host, used when that host's bridge is the one written.
> Never overwrite a user's existing file; if it exists without a `<!-- safe-code:bridge -->`
> block, append the block instead of replacing the file.
```

- [ ] **Step 2: Verify**

Run: `grep -n 'Write only the bridge for the host currently running' skills/safe-code/references/doc-templates.md`
Expected: 1 match.

---

## Task 6: check.sh — relax missing-bridge warning to info

**Files:**
- Modify: `scripts/check.sh:170` (and surrounding loop, ~162-171)

- [ ] **Step 1: Change the missing-bridge branch from warn to info**

Edit — replace exactly:

```
		else
			warn "$b missing (run /safe-code to write provider bridge)"
		fi
```

with:

```
		else
			info "$b not present (lazy — written when safe-code runs under that host)"
		fi
```

- [ ] **Step 2: Verify the warn is gone and info is present**

Run: `grep -n 'not present (lazy — written when safe-code runs under that host)' scripts/check.sh`
Expected: 1 match.

Run: `grep -n 'missing (run /safe-code to write provider bridge)' scripts/check.sh`
Expected: no output (exit 1).

- [ ] **Step 3: Run check.sh against this repo to confirm it still parses and exits 0**

Run: `bash scripts/check.sh; echo "exit=$?"`
Expected: runs to completion; bridge block shows `info`/`pass` lines (no `warn` for missing bridges); `exit=0` (this repo has no committed `current-issues.md`).

---

## Task 7: README.md — bridge prose + badge + What's New

**Files:**
- Modify: `README.md:5` (badge), `:85`, `:115`, `:240` (What's New)

- [ ] **Step 1: Bump the badge**

Edit — replace exactly:

```
[![version](https://img.shields.io/badge/version-4.3-teal?style=flat-square)](./skills/safe-code/SKILL.md)
```

with:

```
[![version](https://img.shields.io/badge/version-4.4-teal?style=flat-square)](./skills/safe-code/SKILL.md)
```

- [ ] **Step 2: Reword the line 85 bridge prose**

Edit — replace exactly:

```
Every project's source of truth is `AGENTS.md` + one `.safe-code/` folder. safe-code also writes thin **provider-bridge pointers** (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/safe-code.mdc`) so hosts that don't auto-read `AGENTS.md` still load the same brain — no `.codex/`/`.claude/`/`.agents/` state clutter.
```

with:

```
Every project's source of truth is `AGENTS.md` + one `.safe-code/` folder. safe-code also writes a thin **provider-bridge pointer** for the host you're running in (`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, or `.cursor/rules/safe-code.mdc`) so that host loads the same brain without auto-reading `AGENTS.md`. Other hosts' bridges accrue lazily — each is written the first time you run safe-code under it — so the repo only carries bridges for tools you actually use, with no `.codex/`/`.claude/`/`.agents/` state clutter.
```

- [ ] **Step 3: Reword the line 115 bridge prose**

Edit — replace exactly:

```
- `AGENTS.md` is the canonical entry point — its Read First section points into `.safe-code/`. Because not every host auto-reads `AGENTS.md` (Claude reads `CLAUDE.md`, Gemini `GEMINI.md`, Copilot `.github/copilot-instructions.md`, Cursor `.cursor/rules/`), safe-code writes a thin pointer in each so every provider lands on the same brain.
```

with:

```
- `AGENTS.md` is the canonical entry point — its Read First section points into `.safe-code/`. Because not every host auto-reads `AGENTS.md` (Claude reads `CLAUDE.md`, Gemini `GEMINI.md`, Copilot `.github/copilot-instructions.md`, Cursor `.cursor/rules/`), safe-code writes a thin pointer for the host it is currently running in, so that provider lands on the same brain. The other hosts' pointers are written lazily the first time you run safe-code under each.
```

- [ ] **Step 4: Add the What's New v4.4 entry above v4.3**

Edit — replace exactly:

```
**v4.3** — vibe-coder companion.
```

with:

```
**v4.4** — per-host provider bridges. safe-code now writes only the bridge for the host you're running in; other hosts' bridges accrue lazily when you run it under them. `AGENTS.md` is still always written, and an undetectable host falls back to writing all four (v4.3 parity). Keeps repos free of unused `GEMINI.md`/Copilot/Cursor files for single-tool users.

**v4.3** — vibe-coder companion.
```

- [ ] **Step 5: Verify all README edits and that the badge no longer shows 4.3**

Run: `grep -n 'version-4.4\|per-host provider bridges\|a thin \*\*provider-bridge pointer\*\* for the host you'"'"'re running in\|written lazily the first time you run safe-code under each' README.md`
Expected: 4 matches.

Run: `grep -n 'version-4.3' README.md`
Expected: no output (exit 1).

---

## Task 8: Tutorials — bridge paragraph (EN + BM, kept parallel)

**Files:**
- Modify: `TUTORIAL-EN.md:73`, `TUTORIAL-BM.md:73`

- [ ] **Step 1: Reword the EN bridge paragraph**

Edit `TUTORIAL-EN.md` — replace exactly:

```
safe-code writes `AGENTS.md` plus thin pointer files for other hosts — `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, and `.cursor/rules/safe-code.mdc`. Open a fresh chat in Claude, Gemini, Copilot, or Cursor and it loads the same `.safe-code/context/` brain automatically, without you running anything.
```

with:

```
safe-code writes `AGENTS.md` plus a thin pointer file for the host you're running in — `CLAUDE.md` (Claude), `GEMINI.md` (Gemini), `.github/copilot-instructions.md` (Copilot), or `.cursor/rules/safe-code.mdc` (Cursor). The other hosts' pointers are added lazily the first time you run safe-code under each, so you only ever carry bridges for tools you actually use. Open a fresh chat in a host that already has its bridge and it loads the same `.safe-code/context/` brain automatically, without you running anything.
```

- [ ] **Step 2: Reword the BM bridge paragraph (parallel)**

Edit `TUTORIAL-BM.md` — replace exactly:

```
safe-code tulis `AGENTS.md` plus fail pointer nipis untuk host lain — `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, dan `.cursor/rules/safe-code.mdc`. Buka chat baru dalam Claude, Gemini, Copilot, atau Cursor dan ia auto-load brain `.safe-code/context/` yang sama, tanpa anda run apa-apa.
```

with:

```
safe-code tulis `AGENTS.md` plus satu fail pointer nipis untuk host yang anda tengah guna — `CLAUDE.md` (Claude), `GEMINI.md` (Gemini), `.github/copilot-instructions.md` (Copilot), atau `.cursor/rules/safe-code.mdc` (Cursor). Pointer host lain ditambah secara lazy kali pertama anda run safe-code dalam host itu, jadi anda cuma simpan bridge untuk tool yang betul-betul diguna. Buka chat baru dalam host yang dah ada bridge-nya dan ia auto-load brain `.safe-code/context/` yang sama, tanpa anda run apa-apa.
```

- [ ] **Step 3: Verify both tutorials**

Run: `grep -c 'a thin pointer file for the host you'"'"'re running in' TUTORIAL-EN.md`
Expected: 1.

Run: `grep -c 'satu fail pointer nipis untuk host yang anda tengah guna' TUTORIAL-BM.md`
Expected: 1.

---

## Task 9: Final version-consistency check + commit

**Files:** none (verification + commit)

- [ ] **Step 1: Run the maintainer version guard**

Run: `bash scripts/check-version.sh; echo "exit=$?"`
Expected: `Result: OK — all version mentions agree on 4.4`, `exit=0`.

- [ ] **Step 2: Repo-wide stale-version sweep**

Run: `grep -rn 'v4\.3\|version-4.3\|version: "4.3"\|safe-code v4.3 session' skills/ README.md TUTORIAL-EN.md TUTORIAL-BM.md scripts/ | grep -v 'docs/superpowers'`
Expected: no output (exit 1) — except the README What's New `**v4.3**` history line, which is intentional. If that line is the only match, that is correct.

- [ ] **Step 3: Confirm clean working tree review then commit (local-only)**

Run: `git status --short`
Review the changed files, then commit as atomic conventional commits (code/behavior first, docs last) — do not push:

```bash
git add skills/safe-code/SKILL.md scripts/check.sh
git commit -m "feat(safe-code): v4.4 — write only the running host's provider bridge (lazy accrual)"
git add skills/safe-code/references/doc-templates.md README.md TUTORIAL-EN.md TUTORIAL-BM.md
git commit -m "docs(safe-code): document per-host lazy provider bridges (v4.4)"
```

Expected: two local commits; `git log --oneline -2` shows both; nothing pushed.

---

## Self-Review notes (already applied)

- **Spec coverage:** every spec "Files that must move together" row maps to a task (SKILL.md → T1-4, doc-templates → T5, check.sh → T6, README → T7, tutorials → T8, version guard → T9). The spec's check.sh correction is Task 6.
- **No placeholders:** all Edit steps carry exact before/after strings gathered from the live files.
- **Consistency:** version target "4.4" used uniformly; the undetectable-host fallback phrasing ("all four") matches between SKILL.md (T1 Step 2), Step 1c output (T2), and README What's New (T7).
