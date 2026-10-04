# safe-code reference: monorepo / per-folder memory

> Loaded on demand (Layer 3) when Step 1 or `--save` finds more than one package root, or
> when `/safe-code` runs from a subfolder of the repo. One home of package detection, the
> project-root rule, and nested `AGENTS.md`.

## Project root (one rule everywhere)

The project root is the **nearest directory holding `.safe-code/`**, walking up from the
current directory but never above the git toplevel; none -> the **git toplevel**; outside git
-> the nearest safe-code marker (`AGENTS.md`, `.safe-code/`), else the current directory.
`scripts/save-reminder.sh` (from the hook's `cwd`) and `scripts/check.sh` use the same rule,
so running from `packages/api/src/` finds the root brain. A package that already has its own
`.safe-code/` is a separate project with its own brain — respected, never created by default.

## Detect package roots

Any of these, read from the files — never guessed:

- `package.json` `workspaces` (array, or `{ "packages": [...] }`), `pnpm-workspace.yaml`
  `packages:`, `lerna.json` `packages`;
- `go.work` `use` directories; `Cargo.toml` `[workspace]` `members`;
- no workspace file, but two or more directories (depth <= 3, skipping `node_modules/`,
  `vendor/`, build output) with their own manifest (`package.json`, `go.mod`, `Cargo.toml`,
  `pyproject.toml`, `composer.json`, `Gemfile`, `pom.xml`, `build.gradle*`).

Expand workspace globs against the tree (`ls -d packages/*/`) and record the real package
list in `architecture.md` `## Navigation`, one line per package.

## One brain, optional nested AGENTS.md

- **One brain at the root** — `.safe-code/` holds whole-repo facts: cross-package
  architecture, shared standards, progress. No per-package `.safe-code/`.
- **Nested `<package>/AGENTS.md`** — package-local facts only: the package's own commands
  (Verified Commands rules, `references/agents-md-authoring.md`) and its gotchas. At most
  ~40 lines; no Read First list, no copies of root rules, no session state.
- **Written only when earned** — the package has commands of its own (a filtered or
  package-scoped test/build, its own Makefile or toolchain), or at least 2 package-specific
  gotchas. Otherwise the fact stays in the root `AGENTS.md` or `architecture.md`.
- **Linked from the root** — root `AGENTS.md` gets a `## Packages` section, one line each:
  `- <package-path>/ — <one line> — <package-path>/AGENTS.md`. `check.sh` warns on a nested
  file over 40 lines or one the root does not link.
- **Existing nested instruction files** are improved in place under the same authoring rules,
  never overwritten; tool-generated blocks stay untouched.

## How hosts load them

Hosts that read `AGENTS.md` natively pick up the nearest nested one when they work in that
folder, so package rules arrive without a root-level read. Claude Code reads a subfolder's
`AGENTS.md` only while no `CLAUDE.md` exists at or above the working directory — once the
root `CLAUDE.md` bridge exists that native read is off, but a subfolder's `CLAUDE.md` still
loads on demand. So under Claude Code, next to each nested `AGENTS.md` write the same thin
bridge (`@AGENTS.md`; Provider Bridge rules in `references/doc-templates.md`: append to an
existing `CLAUDE.md`, never overwrite). Other hosts get no nested bridge.

## At `--save`

- A package gained or lost its own commands or gotchas -> create, update, or prune its nested
  `AGENTS.md` (pruned lines go to LOG `pruned:` like any brain fact) and refresh the root link.
- Nested `AGENTS.md` files travel with the root `AGENTS.md` (same commit group); in team mode
  they are shared (`references/team-mode.md`).
