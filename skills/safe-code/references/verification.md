# safe-code reference: verification detail

> Loaded on demand (Layer 3) when writing task check annotations, when closing a task on
> test, scan, or smoke evidence, when running Smoke-Verify (Step 7), and before declaring a
> previously working procedure broken. The binding rules — every task carries its check
> before work starts, a task closes on an observed effect, a timed-out or inconclusive run
> never passes, a zero-hit scan counts only if it provably ran — live inline in SKILL.md;
> this file holds the formats, the verdict rules, and the procedures.

## Task Checks

Every meaningful task carries its closing check **before** the work starts:

- `check: <command> · expect: <success-only token>` — passes only when the command exits 0
  **and** the token appears. A nonzero exit never passes because its error text happens to
  contain the token.
- No runnable check -> `check: manual · evidence: <the artifact, path, line, or measurement
  that will prove it>`. A description of work done is not evidence; ambiguous evidence keeps
  the task `[~]`. Review manual tasks by consequence, not visibility: the riskiest item in a
  run is often the one nothing can check.

A check is **weak** — rewrite it before starting the task — when it:

- names an activity ("run the tests") instead of an outcome ("suite X green, N tests");
- has an `expect:` token that also appears in failure output (`error`, `done`, `finished`);
- asserts a number the command was handed instead of one it computed;
- cannot fail for any state of the repo.

Annotation format:

```md
- [ ] remove unused dateUtil  · check: rg -n "dateUtil" src · expect: 0 matches (control: rg "formatDate" -> hits)
- [x] remove unused dateUtil  · type: refactor · files: src/utils/dateUtil.ts · closed by: observed (rg 0 matches, control hit)
- [!] migrate legacy auth     · abandoned: needs the user's decision on session store (Redis vs DB)
```

Record which kind of evidence closed each task (`closed by: observed | command | manual`).
A task flips `[~]` -> `[x]` on an **observed effect** (file exists, endpoint answers, test
named in the output), not on exit code 0 or a tool's own "success" line — tools have
returned 0 with the job undone.

## New Tests

A new test counts as verification only after it has been **seen failing without the fix**:
revert or bypass the fix, run the test -> red, restore the fix -> green. A test that was
never red may not exercise the change at all. Record both runs next to the task.

## Test Runs

- **Count against the known total.** A test run passes only when the number of tests it ran
  is about the `known total` on the `test:` line of `AGENTS.md` `## Commands` (record it the
  first time a full green run is seen, re-stamp it at `--save`). A run that reports far fewer is not a pass: a script
  run under the wrong shell once reported 226 of ~3,700 tests with exit 0.
- **Crash before counts -> `inconclusive`**, never passed.
- **Runner or infrastructure crash** (not an assertion failure) gets exactly one rerun.
  Green -> `flaky (rerun green)`, reported as such, never as `passed`; red again -> failed.
- **Run scripts under their shebang shell** (`bash script.sh` for a bash script), not the
  agent's interactive shell — shells differ on globbing, arrays, and `set -e`.
- Tiers by change size (a fast subset for small changes) only when the project declares
  them in `code-standards.md`; safe-code never picks a lighter tier itself.

## Exit Status

`cmd | tail -n 20` reports `tail`'s exit status, not `cmd`'s — a failed run reads as green.
Capture the real status instead:

```bash
cmd > <gitignored-log> 2>&1; echo "exit=$?"; tail -n 20 <gitignored-log>
# or
set -o pipefail; cmd | tail -n 20          # bash/zsh
cmd | tail -n 20; echo "exit=${PIPESTATUS[0]}"   # bash
```

## Before Declaring a Procedure Broken

A procedure that worked before (a deploy, a script, a recorded command) is re-run **exactly
as recorded** — same command, working directory, shell, and environment — before it is
declared broken. Verifier artefacts are verifier findings, not product failures: a
verifier's own timeout, a strict text match against output that changed wording, or a
draft/sandbox path that reads different config than the real one.

## Scan Proof (zero-hit reference scans)

A zero-hit reference scan is evidence only if the scan provably ran:

1. Quote every glob argument (`rg --glob '*.ts'`, `grep --include='*.py'`, `'**/*.py'`) — in
   zsh an unmatched glob aborts the whole command, and `2>/dev/null` hides that, so "0 refs"
   and "never searched" look identical.
2. Check the exit status, and re-run any search whose output is empty once more in isolation
   before it justifies a deletion.
3. Prove the scan can fail: run the identical command against a symbol you know is alive and
   confirm it returns hits — a wrong path, a typo'd pattern, or a shell that ate the glob all
   look exactly like clean code.
4. Exclude safe-code's own records from confirmation greps — they name the candidate
   without using it: `rg -n '<symbol>' --glob '!.safe-code/**' --glob '!AGENTS.md' --glob '!.codegraph/**'`
   (grep: `--exclude-dir=.safe-code --exclude-dir=.codegraph --exclude=AGENTS.md`). Run the
   positive control with the same exclusions.
5. Record the positive control next to the zero-hit result in the Graveyard `evidence:` field.

A false negative here deletes live code; a loud failure does not.

## Smoke-Verify

- Run the project's **documented** build/test/run command from `AGENTS.md` `## Commands` —
  the single source (`verified: <sha> · <date>`, tests `known total: N`; rules:
  `references/agents-md-authoring.md`, Verified Commands). Never invent a command; none
  documented -> `smoke-verify: no command available`. A command that ran green is re-stamped
  at `--save`.
- Pass -> `smoke-verify: passed (<command>) · covers: <what it actually exercised>`. The
  `covers:` part is mandatory: a strict gate over 40% of the surface reports "0 errors"
  exactly like a gate over 100%, and a clean result with unstated scope grades WEAK in the
  Context Self-Test.
- Fail -> `$debug-issue` on the failure before asking the user. Its gate is absolute: no
  red-capable command that reproduces the symptom, no hypothesis; "no correct seam for a
  regression test" is a finding for `MEMORY.md`, not a reason to skip the test.
- **Long-running command** (build, e2e, anything past the tool timeout) -> run it detached to
  a gitignored log inside the project and poll a bounded loop for a terminal marker; never a
  fixed sleep, never foreground. `smoke-verify: timed out (<command>, <log>)` is its own
  outcome and is never reported as passed.
- **Record the environment** with the verdict: resolved working directory, runtime/shell
  actually used, exit status. A pass produced in a different directory, runtime version, or
  shell than the project documents is an environment mismatch to resolve, not evidence; a
  later re-verification must use the same command in the same environment or it does not count.
- Outcomes: `passed` · `failed -> debug` · `timed out` · `inconclusive` ·
  `flaky (rerun green)` · `no command available` · `skipped: docs-only`.

## Slice Standard (Steps 6 and 7)

A slice closes when a full re-read finds nothing new, not when it looks finished:

1. Finish the whole deliverable — no placeholders, no "rest later".
2. Re-read it as a domain expert and replace the cheap version of each part.
3. Hunt correctness, integration, and portability defects.
4. Low-cost polish.

Verification obligations only — none of this adds printed ceremony.

Slices are **vertical tracer bullets**: each cuts a narrow but complete path through every
layer, is demoable on its own, and fits one fresh context window; prefactor first ("make the
change easy, then make the easy change"). Exception — a **wide refactor** (one mechanical
change fanning across the repo) cannot land green as a vertical slice: sequence it expand ->
migrate in batches sized by blast radius -> contract, each batch its own slice, green batch
to batch because the old form still exists.
