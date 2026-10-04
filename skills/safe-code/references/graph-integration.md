# safe-code reference: graph integration (codegraph — Step 3f, Step 4, `--codegraph`)

> Loaded on demand by Step 3f, Step 4 (dead-code derivation), and `/safe-code --codegraph`
> (Layer 3). The binding rules — accelerator never overrides safety, ask before installing,
> never edit agent config outside the root, graceful manual fallback — live inline in
> SKILL.md; this file holds the commands.

The one graph tool is **codegraph** (`github.com/colbymchenry/codegraph`, MIT, npm
`@colbymchenry/codegraph`, CLI `codegraph`). Its index lives in `<project-root>/.codegraph/`,
which carries its own `.gitignore` (`*` + `!.gitignore`). Only that one file is meant to be committed
(so collaborators' `git status` stays clean); the index itself never is. `--save` adds
`.codegraph/.gitignore` to the `chore` scaffold commit the first time it appears, nothing else under `.codegraph/`.
Check `codegraph --help` once per session; a subcommand missing from it -> skip that step and
continue manually, never invent flags.

## Detection and install

1. Host already exposes the MCP tools (`codegraph_explore`, `codegraph_node`, `codegraph_callers`, …) -> use them for reads; use the CLI for `init` / `sync` / `status`.
2. `codegraph` on PATH -> run the **Health check** once per session, then drive the CLI.
3. Missing -> ask ONCE (supply-chain decision): "Install codegraph? It installs the CLI, wires its MCP server into this agent only (global agent config), and indexes this project." **Yes** -> run, in order:
   1. `npm i -g @colbymchenry/codegraph` (Node present). No Node -> print the official installer for the user to run — never pipe it to a shell yourself — and stop here until they have:
      - macOS / Linux: `curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh`
      - Windows (PowerShell): `irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex`
   2. `codegraph install --target <id> --location global --yes` — wires the MCP server + auto-sync watcher into **only** the agent running safe-code. `<id>` = the running host mapped through the target list in `codegraph install --help` (e.g. `claude-code`, `cursor`, `codex`). Host unknown or not listed -> skip this step and print the command for the user. Never `--target all` or `auto`. This is the one sanctioned write outside the project root besides the Save Bridge (SKILL.md Scope Rule), allowed only by that explicit yes.
      Under Claude Code, `--yes` also writes codegraph's auto-allow list for its own read-only MCP tools; say so in the install question ("also lets the agent use codegraph's read-only tools without prompting"). Add `--no-permissions` if the user wants prompts kept.
   3. `codegraph init` in the project root (writes only `.codegraph/`).

   Record the answer in `user-preferences.md` (a recorded decline is durable: print the commands instead of re-offering). **Declined, or cannot ask (non-interactive)** -> run none of them; print the three commands; non-interactive records nothing.
4. None -> `Graph: unavailable`, continue with manual scans.

On suggest, install, or first use in a session, print once: "codegraph sends anonymous usage stats; turn off with `codegraph telemetry off` or `DO_NOT_TRACK=1`." Never set either for the user.

**Never run `codegraph install` without that yes** (and never `codegraph uninstall`): it edits agent config outside the project. Already installed CLI, user now wants the MCP server -> the same yes question for step 2 alone.

**Sync.** MCP wired -> its watcher re-syncs the graph on every file change. Not wired -> safe-code runs `codegraph sync` at the start of every run (and after code edits, before graph-based checks).

## Health check (report only)

1. `codegraph --version`.
2. Copies on PATH: `which -a codegraph` (de-duplicate) · Windows `where codegraph`. More than one distinct path -> report each with `<path> --version`; the first on PATH wins.
3. Online -> `codegraph upgrade --check`. Never run `codegraph upgrade`.
4. One line: `Codegraph: <version> (<path>)` plus ` — latest <v>` / ` — <n> copies on PATH` when relevant. Never blocks the run.

## Build / freshness (Step 3f)

- No `.codegraph/` (after consent) -> `codegraph init -y` from the project root (writes only `.codegraph/`). Who may init (SKILL.md Step 3f): `--codegraph`, and audit runs / targeted refactors with graph evidence in scope and the CLI installed — never a setup run unless the user asked for `--codegraph`.
- `.codegraph/` exists -> `codegraph sync` (incremental, sub-second). After code edits in a run, `codegraph sync` again before any graph-based check.
- `codegraph status` -> files, nodes, edges, languages for the Reasoning block and the Step 8 `Graph:` line. "Index is locked" from a crashed run -> `codegraph unlock`, then retry once.
- Empty or failed -> `Graph: unavailable`; partial language coverage -> `Graph: partial`, graph findings for covered languages only, manual checks kept. Statuses use the Step 8 `Graph:` vocabulary (`ready | stale | unavailable | partial`; `references/final-banner.md`) everywhere.
- Legacy graph dirs (`.code-review-graph/`, `graphify-out/`) -> leave them, mention once that they are unused now; never delete.

## Command map

| Need | CLI (MCP twin) |
|---|---|
| Orientation / "how does X work" | `codegraph explore "<query>"` (`codegraph_explore`) · `codegraph context "<task>"` |
| One symbol or file + dependents | `codegraph node <name>` · `codegraph node -f <file> --symbols-only` (`codegraph_node`) |
| Callers / callees | `codegraph callers <symbol>` · `codegraph callees <symbol>` |
| Blast radius before editing shared code | `codegraph impact <symbol>` |
| Tests to run for a change | `codegraph affected <changed files…>` — over-reports (the safe side); run what it lists |
| Find a symbol | `codegraph query "<search>"` (`-k function|method|class`) |
| File tree from the index | `codegraph files` |

Renames have no graph preview: list `callers` + `impact` first, then edit and confirm with `rg`.

## Dead-code derivation (Step 4)

codegraph has no dead-code command; derive candidates from the project root after `codegraph sync`:

```sh
# 1. functions/methods with 0 callers AND 0 file references
for k in function method; do codegraph query "" -k "$k" -l 5000; done |
  awk '/^(function|method) /{n=$2; getline; print n "\t" $1}' | sort -u |
  while IFS="$(printf '\t')" read -r name loc; do
    codegraph callers "$name" | grep -q 'No callers found' && printf '%s\t%s\n' "$name" "$loc"
  done
# 2. orphan modules
codegraph files --format flat --no-metadata | sed -n 's/^  //p' | while read -r f; do
  codegraph node -f "$f" --symbols-only | grep -q 'no other indexed file depends on it' && echo "ORPHAN $f"
done
```

Reading the output — candidates only, never a deletion list:

- `callers` resolves by **name**: same-named methods merge, so a dead method can hide behind a live namesake. Every candidate (and every method you care about) is confirmed by `rg` with a positive control, excluding `.safe-code/**`, `AGENTS.md`, and `.codegraph/**` (`references/verification.md`, Scan Proof).
- Drop from the orphan list: entry points (`main`, bin scripts, `index.*` roots, framework routes/pages), test files, config files. **Public API = the package's entry points** — manifest `main` / `exports` / `bin`, a published index, a documented CLI/HTTP surface — Medium at best. An `export` keyword inside a private app (`"private": true`, never published) is not public API: an exported symbol nothing imports is an ordinary candidate.
- Dynamic dispatch, registries, reflection, config strings -> Medium/Low per `$codebase-pruner`. Never auto-delete.
- Cost: about 0.1s per symbol — fine for an audit, too slow for every run.

## `/safe-code --codegraph` (build + query)

- **Build** (`--codegraph`): detect/install as above -> `init -y` or `sync` -> `status`. Standalone run ends with one line: `Codegraph: built — <files> files, <nodes> nodes, <edges> edges`.
- **Query** (`--codegraph "<question>"`): read-only — `codegraph explore "<question>"` (or `codegraph_explore`); relay in plain language. The agent may use `node` / `callers` / `impact` internally. No index yet -> say so and offer build mode.
- **Auto-refresh**: once `.codegraph/` exists, every `/safe-code` / `--continue` run runs `codegraph sync` (redundant but harmless when the MCP watcher is wired); failure -> `Graph: stale (sync failed)`, continue. Never installs on this path.

### Harvest mapping (build mode; all draft-until-save)

| codegraph output | Goes to |
|---|---|
| `status` files/nodes/edges/languages | Step 8 `Graph:` line |
| `files --format grouped` + `explore` on entry points | `architecture.md` Navigation map refresh |
| Orphan modules seen while exploring | `progress-tracker.md` Open Questions candidates |
| Most-depended-on files (`node -f <file> --symbols-only` "used by N files") | Context Self-Test seed questions (`references/first-run.md`) |

Evidence tags: a claim read from codegraph output is `[extracted: codegraph <subcommand> <arg>]` — the pointer is the re-runnable command. Harvest only what is real; an empty harvest is valid (`Codegraph: built, nothing worth harvesting`).

### Corpus exclusions

Never paste `.safe-code/context/current-issues.md` (may hold secrets/raw logs) into any prompt or query. codegraph indexes source code only; it does not send file content to an LLM.
