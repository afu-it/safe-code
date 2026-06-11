# safe-code v4.4 — Per-Host Provider Bridge (design)

**Goal:** On a `/safe-code` run, write the provider bridge for the **host actually
running** instead of unconditionally writing all four. Other hosts' bridges accrue
lazily — each is written the first time safe-code runs under that host. Result: a repo
accumulates bridge files only for the tools the user actually uses, instead of being
seeded with `CLAUDE.md` + `GEMINI.md` + `.github/copilot-instructions.md` +
`.cursor/rules/safe-code.mdc` on the first run regardless of which tool the user touched.

**Why:** The all-four behavior exists for cross-provider portability (open the project
later in any host, context auto-loads with zero setup). But a solo user on a single tool
gets three dead files cluttering the repo. Lazy per-host accrual keeps the portability
property (each host that runs safe-code self-registers its bridge) while keeping the repo
clean by default.

**Non-goals:** No `--bridges all` flag or any escape hatch (YAGNI — decision: "lazy je
cukup"). `AGENTS.md` remains the always-written source of truth. No change to the
"never overwrite an existing bridge / append a marked block" rule. No change to what a
bridge *contains* (still a thin pointer, never state).

---

## The change

### Host detection (one instruction, no code)

safe-code is markdown an agent follows; the running agent already knows its own host from
its system context. The Provider Bridge step instructs:

> Identify the host you are running in from your own environment/system context, and write
> only that host's bridge file. If you cannot determine the host, fall back to writing all
> four bridges (the pre-v4.4 behavior).

Host → bridge mapping (unchanged table, now used as a *lookup* not a *write-all list*):

| Detected host | Bridge written |
|---|---|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules/safe-code.mdc` |
| any other host (Codex, Windsurf, …) or **undetectable** | see below |

- **Host not in the table** (e.g. Codex, Windsurf): write `AGENTS.md` only; no special
  bridge file. Those hosts read `AGENTS.md` directly, so no bridge is needed.
- **Host undetectable** (agent genuinely cannot tell): fall back to writing all four —
  identical to today's behavior. This guarantees v4.4 is never *worse* than v4.3.

### Always written

- `AGENTS.md` is written on every run, exactly as today.

### Lazy accrual (this is what preserves portability)

- The "never overwrite an existing host file; append a marked `<!-- safe-code:bridge -->`
  block if it exists without pointing at the brain; leave it if it already points there"
  rule is unchanged.
- Because each run only writes the current host's bridge and never removes others, opening
  the project later in a different host and running `/safe-code` there writes *that* host's
  bridge. Over time the repo holds bridges only for hosts the user actually used.
- safe-code **never deletes** an existing bridge. Migrating a repo from v4.3 to v4.4 keeps
  whatever bridges are already present; v4.4 only changes which *new* bridges get created.

### Step 1c output

The confirm block's `Bridges:` line reports only what this run did, e.g.
`Bridges: CLAUDE.md - created (host: Claude Code); others deferred (written when safe-code
runs under that host)`. The undetectable-fallback case reports all four as today.

## Test (subagent, exact-string grep harness per repo convention)

- Given the Provider Bridge instruction + a simulated **Claude Code** host on an empty repo:
  agent writes `AGENTS.md` + `CLAUDE.md` and does **not** create `GEMINI.md`,
  `.github/copilot-instructions.md`, or `.cursor/rules/safe-code.mdc`.
- Given a simulated **Cursor** host on a repo that already has `CLAUDE.md`: agent writes
  `.cursor/rules/safe-code.mdc`, leaves the existing `CLAUDE.md` untouched.
- Given an **undetectable** host: agent writes all four (v4.3 parity).
- Given a host **not in the table** (Codex): agent writes `AGENTS.md` only.

## Files that must move together (sync surface)

A version-bumping behavior change touches multiple files; all must stay consistent.

| File | Edit |
|---|---|
| `skills/safe-code/SKILL.md` | Step 1 scaffold list (bridges no longer all-unconditional); **Provider Bridge** subsection (detection + lazy + fallback); Step 1c `Bridges:` output line; the "writes thin provider-bridge pointers" prose near the Doc Structure / lines ~60–62 |
| `skills/safe-code/references/doc-templates.md` | Provider Bridge Files section — note that only the current host's bridge is written per run |
| `README.md` | How It Works / Context + Session Docs — describe per-host lazy bridges; **What's New** v4.4 entry; badge |
| `TUTORIAL-EN.md` + `TUTORIAL-BM.md` | bridge paragraph (kept parallel, bilingual) |
| `scripts/check.sh` | **Provider bridges (advisory)** block, lines ~159–175: today it `warn`s on every missing bridge of the four. Under lazy accrual a missing bridge is **expected**, not a problem — change the missing-branch from `warn` to `info` with a lazy-aware message (e.g. "not written — created when safe-code runs under that host"). Keep the existing `warn` for a bridge that **exists but does not point at** `AGENTS.md`/`.safe-code` (that is still a real misconfiguration). Keep the `pass` for a correct bridge. |
| version bump → **v4.4** | `SKILL.md` frontmatter, Step 8 banner, README badge, README What's New, tutorials; then `bash scripts/check-version.sh` must pass and a repo-wide grep for `4.3` shows no stale refs |

`scripts/migrate.sh` needs **no** change: it migrates legacy session-state folders and
preserves bridges; it does not enforce a specific set of bridge files. `check.sh`'s
session-file lists are unaffected — only its advisory bridge block changes.
