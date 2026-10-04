# Agent scenarios (manual, before a release)

These scenarios run a real coding agent with the `safe-code` skill against a throwaway
fixture repo, then check what it left behind. **They cost tokens and are not run in CI.**
CI runs only the deterministic script tests in `tests/scripts/run.sh`.

| File | What it does |
|---|---|
| `build-fixture.sh [--team] [--adopt] [dir]` | Builds the sandbox: `repo/` (small Node/TS API, one dead function, one orphan module, existing `CLAUDE.md`, a `.claude/agents/reviewer.md` subagent, gitignored `.env.local`, one foreign uncommitted change), a local bare `origin.git/`, and `baseline.vars`. `--team` adds a second author. `--adopt` makes it an existing project for setup-adopt (60 commits, `CLAUDE.md` rules, `.cursorrules`, an ADR, TODO comments, a feature branch). No network. |
| `scenarios.md` | The 10 scenarios: exact prompt, `assert.sh` flags, and what the agent should say. |
| `assert.sh <base> [flags]` | Checks the observable results (foreign change untouched, no push, `Safe-Code:` trailers, no deletions on a light run, team-mode split, adopt imports untouched and cited, read-only `--explain`, ...). PASS/FAIL/SKIP per check; exit 1 on any FAIL. |
| `run-headless.sh` | **Optional.** Runs one prompt with `claude -p` in the fixture. Needs the Claude Code CLI and uses your own account. You can always paste the prompt into an interactive session instead. |

## Run one scenario

```bash
B=$(bash tests/scenarios/build-fixture.sh | tail -n 1)
# Either: open your agent in "$B/repo" and paste the prompt from scenarios.md
# Or (optional, Claude Code only):
bash tests/scenarios/run-headless.sh --install-skill "$B" "/safe-code"
bash tests/scenarios/assert.sh "$B" --light
```

`--install-skill` copies this repo's working-tree `skills/` into the fixture's `.claude/skills/`
(excluded from git), so the run tests the unreleased version. The config trust audit
(`--audit`) will then see those skill files too; that noise is expected.

## Notes

- Before any run, `assert.sh` passes most "always" checks on the untouched fixture: they
  guard against damage, so they only mean something after a run. `scenarios.md` lists them.
- "No files outside the root" checks only the sandbox dir around `repo/`, not the whole disk.
- Fixtures live under `${TMPDIR:-/tmp}`; delete them with `rm -rf "$B"` when done.
