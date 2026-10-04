# safe-code reference: Step 8 final banner

> Loaded (Layer 3) only right before the Step 8 banner is printed. The rules — re-measure every
> count at report time, self-diff the run, `complete` is earned — live in SKILL.md Step 8, with the
> header strings `scripts/check-version.sh` guards. `<version>` is the SKILL.md frontmatter version.

**Header.** `=== safe-code v<version> session complete ===` only when every task is `[x]`. Any `[!]`
abandoned, `[p]` parked, or `[ ]`/`[~]` open task (except `Save final docs/context updates…`, and
`Identity + account guard` on a run with no commit) -> `=== safe-code v<version> session ended ·
<n> abandoned · <n> parked · <n> open ===`.

**Compression** (Proportional Ceremony): on light, Orientation, and routine-resume runs omit lines
whose value is `none`, `skipped: not in scope`, `skipped: routine resume`, or `not needed`. Always
keep the header and the Run, Git/Remote/Save/Commits, Brain, and Task list lines.

```
=== safe-code v<version> session complete ===

Project root: <path>  ·  Safe-code folder: <project-root>/.safe-code/
Run: <setup (fresh) | setup (adopt) · Coverage: ~N% | light | audit> · profile: <Orientation | Audit | Cleanup | n/a> · mode: <A | B | C | n/a>
        (light: "hygiene pass skipped (light run; /safe-code --audit runs it)")
Session type: <fresh | resumed from <saved_at>>
Graph:  codegraph <ready | stale | unavailable | partial> | files: <n> | nodes: <n> | edges: <n>

Git:    <repo found | not found> | <n> commits | branch: <branch> | unpushed: <N | no upstream>  (omit when 0)
Remote: <URL | none>  [Bucket <A | B | C>]
Save:   local commit only; no push
Brain:  <N> lines (budget 300) [· local-only (gitignored)]   (+ `AGENTS.md: <N> lines (budget 120)` when over)
Team:   on (<N> authors, 90d)   (only when team mode is on)
Commits: <pending — run /safe-code --save | n atomic: type:subject, … | 1 (atomic split skipped: <reason>)>

Files:  AGENTS.md <created|populated|reconciled|unchanged> | .safe-code/ <created|existed|migrated>
        context/ + feature-specs/ + current-issues.md (gitignored) + six session files: <statuses>
        Legacy: <none | migrated + removed: <list> | conflicts: <list>>
Loaded: L1 <entry slices> | L2 <resume files or none> | L3 <detail files loaded this session>

Decisions: <list>
Removed:   <list>
Flagged:   <list>
Config audit: <clean | High: n, Medium: n | skipped: not in scope>
Context self-test: <result line, references/first-run.md (Result format) | skipped: routine resume>
Refactors: <summary>
Review:    <review-changes run | skipped: docs-only | unavailable fallback>
Smoke:     <passed | failed -> debug | timed out | inconclusive | flaky (rerun green) | no command available | skipped: docs-only> (<command>) · covers: <scope> · env: <cwd, runtime, exit>
Debug:     <debug-issue run | not needed | unresolved blocker>
Task list: <done>/<total> complete; unfinished moved to <ACTIVE.md|BACKLOG.md|none>
Parked:    <none | each `[p]` task with what approval it waits for — open, not abandoned>
Abandoned: <none | each `[!]` task with its reason — a run with one is never "complete">
Requested: <n/n rows observed | none declared>
Out-of-scope touches: <none | this run's unclaimed files — config, hooks, skill or agent files first | foreign: <paths> (not this run's; never reverted)>
Follow-up saved for next `/safe-code --continue`: <list>
Worth asking next: <1–2 questions from Open Questions or audit findings — omit if none>

Run /safe-code --save to commit and close this session.
```

`Graph:` is the one graph-status vocabulary (`ready | stale | unavailable | partial`), used by
Step 3f and `references/graph-integration.md` alike.
