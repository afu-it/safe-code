# Identity + Account Guard — procedure (Step 3e)

Loaded on demand by Step 3e. Inform and suggest only — never edit global git config, never switch accounts, never push.

### Commit identity

1. Read `git config user.name` and `git config user.email` (effective values, from inside the project).
2. If `user-preferences.md` has a `## Git Identity` block (`name:` / `email:`), compare. **Mismatch -> stop before committing**: print the project-local fix (`git config user.name "<name>"` + `git config user.email "<email>"`) and wait; a commit under the wrong identity is not reversible once pushed by the user later.
3. If no block exists, still flag the two silent-leak shapes and draft a `## Git Identity` entry in `SESSION.md` for the user to confirm at `--save`:
   - email is empty or `<user>@<Machine>.local` -> git derived it from the OS account; the machine name and the OS full name would land in every commit.
   - `user.name` looks like a full legal name while the remote owner is a handle -> the user may want the handle instead.
4. Never write `user-preferences.md` from this step; the entry goes through the normal draft-until-save path. Never store tokens or passwords here — identity is name + email only.

### Push account (information only)

When the remote is a hosting platform with a CLI on PATH (`gh` for github.com; skip otherwise): read the active account (`gh auth status`, active row) and the remote owner from the URL. Different -> report one line, `Push account: <active> — remote owner <owner>`, and print the fix for the user to run themselves:

```
# switch the active account (affects every repo on this machine)
gh auth switch --user <owner>
# or push once as <owner> without switching (other sessions keep their account)
T=$(gh auth token --user <owner>); git -c credential.helper= -c "http.https://github.com/.extraheader=Authorization: Basic $(printf '<owner>:%s' "$T" | base64)" push origin <branch>
```

safe-code never pushes, so the mismatch never blocks a run; it just stops the user from discovering a 403 later. Record the outcome in the Step 3c Reasoning block as `identity: ok | fixed by user | pending`.

