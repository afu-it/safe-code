# Identity + Account Guard — procedure (Step 3e)

Loaded on demand by Step 3e, right before the run's first commit (normally inside `--save`) — never on a run that commits nothing. Inform and suggest only — never edit global git config, never switch accounts, never push.

### Commit identity

1. Read `git config user.name` and `git config user.email` (effective values, from inside the project).
2. Read the `## Git Identity` block (`name:` / `email:`) from `.safe-code/context/user-preferences.local.md` first (per-developer, gitignored; a value there wins), else from `user-preferences.md`; `-` or empty counts as unset. If a block is set, compare. **Mismatch -> stop before committing**: print the project-local fix (`git config user.name "<name>"` + `git config user.email "<email>"`) and wait; a commit under the wrong identity is not reversible once pushed by the user later.
3. If no block is set, check the two silent-leak shapes below. **Only when one is flagged**, draft a `## Git Identity` entry in `SESSION.md` for the user to confirm at `--save` (in team mode it is applied to `user-preferences.local.md`, never the shared file — `references/team-mode.md`, Per-developer preferences); nothing flagged -> draft nothing, `identity: ok`:
   - email is empty or `<user>@<Machine>.local` -> git derived it from the OS account; the machine name and the OS full name would land in every commit.
   - `user.name` looks like a full legal name while the remote owner is a handle -> the user may want the handle instead.
4. Never write `user-preferences.md` or `user-preferences.local.md` from this step; the entry goes through the normal draft-until-save path. Never store tokens or passwords here — identity is name + email only.

### Push account (information only)

When the remote is a hosting platform with a CLI on PATH (`gh` for github.com; skip otherwise): read the active account (`gh auth status`, active row) and the remote owner from the URL. Different -> report one line, `Push account: <active> — remote owner <owner>`, and print a push-once command for the user to run themselves. It authenticates this one push as `<owner>` without switching the active account — switching would change the account for every repo and every other session on the machine, so safe-code never suggests it:

```
T=$(gh auth token --user <owner>); git -c credential.helper= -c "http.https://github.com/.extraheader=Authorization: Basic $(printf '<owner>:%s' "$T" | base64)" push origin <branch>
```

Two failure shapes to recognise when the user reports a failed push:

- **`Repository not found`** on a private repo usually means the wrong account, not a missing repo — the host hides private repos from accounts without access instead of answering 403. Re-check the active account against the remote owner before anything else.
- **A push whose commits touch `.github/workflows/*`** is refused unless the token has the `workflow` scope. Print `gh auth refresh -s workflow` for the user — never run it yourself. It refreshes the *active* account's token only; when the push goes out as another account (the push-once command), say that account's token is the one that needs the scope.

safe-code never pushes, so the mismatch never blocks a run; it just stops the user from discovering the failure later. Record the outcome in the Step 3c Reasoning block as `identity: ok | fixed by user | pending`.
