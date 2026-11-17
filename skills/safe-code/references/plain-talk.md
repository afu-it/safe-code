# safe-code reference: plain talk (the summary a non-coder can act on)

> Loaded (Layer 3) right before the Step 8 summary is printed, and at the start of
> `/safe-code --explain`. The binding rules — a plain summary comes first, the banner keeps its
> exact lines — live in SKILL.md (Step 8, `--explain`); this file holds how to write it.

The banner is a record for the next agent and for people who read logs. The person who typed the
command needs something else first: what happened, what it means for them, and what to do next,
said the way one friend tells another.

The rules below are adapted from the `bro` skill (`github.com/luchasarie/bro-skill`, MIT).
safe-code does not bundle or call it.

## The rules

1. **Re-tell, never add.** The plain summary says only what the run's own record already says
   (task list, banner lines, findings). No new claim, no new advice, no number that is not in
   the record. It is checked against the banner before printing: a sentence the banner cannot
   back is removed.
2. **Simpler, not necessarily shorter.** The aim is "cannot be misunderstood". Take the space
   real clarity needs; cut preamble, hedging, and filler.
3. **Facts survive exactly.** Every path, command, file name, number, URL, name, and decision is
   copied as it is. Simplify the sentence around a fact, never the fact.
4. **Everyday words.** No term the reader would have to look up. When one is unavoidable, say
   what it is in everyday words first, then the term once: "the saved copy of your work (a
   commit)". Never an internal label alone (`Bucket C`, `mode: C`, `Orientation`, `[p]`).
5. **Friend to friend.** Casual and direct ("ok so…", "basically…", "the one thing to do now…").
   A touch of warmth, never a performance, never a joke at the reader's expense.
6. **The user's language.** Written in the language the user writes in, in the register they
   use. Paths, commands, and banner lines stay as they are.
7. **Flat.** Sentences, not headers or tables. A short list only when there really are several
   separate things, five at most.
8. **Bad news is said plainly and early.** A failed check, an unfinished task, or something
   unverified is in the first two sentences, with what it means and what fixes it — never
   softened, never left for the banner to reveal.

## Step 8: the plain summary

Printed **above** the banner, two to six sentences, in this order:

1. **What happened** — what now works, or what was found. One concrete thing the user can try
   or look at, when there is one.
2. **What it means for them** — only when it is not obvious: what is safe, what is not done,
   what was left alone on purpose.
3. **What needs them** — each `unverified:` item, parked approval, or open question, as a plain
   sentence with the way to settle it. Nothing needs them -> say so in a few words.
4. **The next step** — one action, with the exact command.

Then the banner, unchanged. The plain summary never replaces a banner line and never restates
all of them.

Before / after:

```text
Before:  Run: setup (adopt) · Coverage: ~40% · profile: Audit · mode: C
         Flagged: 2 dead-code candidates (findings only)
         Unverified: npm run build — check: npm install, then run it

After:   Ok so, your project now has a memory: any coding agent that opens it will read the
         same notes instead of starting from zero. This is a big project, so I read the main
         parts first (about 40% of it); the rest gets read when your work reaches it. I found
         2 pieces of code nothing seems to use and removed nothing. One thing I could not
         check: whether `npm run build` passes, because that needs `npm install` first, which
         is your call. Next: type `/safe-code --save` to keep all of this.
```

## `--explain`

The whole briefing is written this way: short plain paragraphs, no form, no labels. Cover, in
this order, what the project does and who it is for; what it is built with, in everyday words;
where it stands now; what is in progress and the next step; and what is still unknown. A
section with nothing to say is left out, not filled.

- It re-tells the brain. A fact the brain does not hold is not added; a gap is named as a gap
  ("the notes do not say who uses this").
- A term from the brain that a non-coder would not know gets its everyday meaning the first
  time it appears.
- The brain disagrees with the code -> the code wins; say so in one plain sentence.

## Elsewhere

The `plain:` recap in `LOG.md` and the Save Bridge block follow rules 1–4 in one line.
Questions put to the user (the codegraph install question, a Mode B plan, the adopt
questions) follow rules 3–6: say what will happen and what a yes changes, before the command.
