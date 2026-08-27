# safe-code reference: first-run population + context self-test

> Loaded on demand on the first `/safe-code` run (empty scaffold) and whenever the
> Context Self-Test triggers (Layer 3). The binding rules — write evidence-derivable
> context immediately on first run, never invent facts, gaps become work — live inline
> in SKILL.md; this file holds the per-file table, the question set, and the grading.

## First-Run Population — per-file table

| File | First-run write |
|---|---|
| `AGENTS.md` | Yes — Read First order + verified project facts/commands |
| `.safe-code/context/project-overview.md` | Yes — from README, manifests, package metadata |
| `.safe-code/context/architecture.md` | Yes — stack, boundaries, invariants, **and a Navigation map (where things live / entry points)** from manifests/folders/configs |
| `.safe-code/context/code-standards.md` | Yes — conventions from linter/formatter/tsconfig/editorconfig |
| `.safe-code/context/ai-workflow-rules.md` | Only if repo/team docs reveal real workflow; else leave template |
| `.safe-code/context/progress-tracker.md` | Yes — Current Phase + Open Questions (unverifiable facts) |
| `.safe-code/context/user-preferences.md` | No — conversation-derived only, no repo evidence |
| `.safe-code/context/ui-context.md` | No — only when UI/design work occurs |
| `.safe-code/context/current-issues.md` | No — manual + issue-trigger only |

Rules:

- This immediate-write exception applies only while a file is an empty scaffold. Once it holds real content, later edits revert to Draft-Until-Save.
- Never invent facts. Anything not provable from repo evidence is an Open Question, not a populated claim.
- Tag load-bearing technical claims per the Evidence Tags rule in SKILL.md — `[extracted: <path|command>]` when read directly from the repo, `[inferred: <basis>]` for deductions.
- Still draft *this session's* ongoing changes in `SESSION.md`; First-Run Population is about seeding empty context, not about live edits.
- After populating, run the **Context Self-Test** to verify the brain is sufficient; fill or flag any gaps it finds.

## Context Self-Test — how

1. **Closed-book.** Dispatch a fresh-context subagent given **only** the `.safe-code/context/*.md` files — no repo access. (No subagent support -> run inline, but answer strictly from the loaded context, not from code read this session.) The point is to simulate an agent that has the brain but not the codebase.
2. **Ask the Day-1 question set** (8–10), each mapped to the file that should answer it:

   | Question | Should be answered by |
   |---|---|
   | What does this project do, and for whom? | `project-overview.md` |
   | What is the stack and high-level architecture? | `architecture.md` |
   | Where do I add a new route / feature / model? | `architecture.md` (Navigation map) |
   | How do I run, build, and test it? | `code-standards.md` / `architecture.md` |
   | What invariants must never be broken? | `architecture.md` |
   | What code conventions must I follow? | `code-standards.md` |
   | What is in progress and what is next? | `progress-tracker.md` |
   | Any user preferences / hard dislikes to respect? | `user-preferences.md` |

   Add repo-specific questions when the stack warrants (e.g. "how is auth enforced?", "how is data persisted?"). When `graphify-out/graph.json` exists, seed 1–2 extra questions from the top god nodes (most-connected concepts): "What is <god node> and what depends on it?" — the brain should be able to answer about the concepts the graph says matter most.
3. **Require evidence.** Each answer must cite the context file + section it came from. No citation possible -> graded **fail** (the model is answering from training memory, not the brain). An answer resting only on `[inferred: …]`-tagged claims is **weak**: pass it only if no `[extracted: …]` evidence could exist for that question; otherwise treat it as a gap — verify the claim from the repo and upgrade the tag, or downgrade the claim to an Open Question. A file that is *intentionally* still a template on a first run (`user-preferences.md`, `ui-context.md`) answering "none recorded yet" is a **pass**, not a gap — absence is the correct answer there.
3b. **Re-verify before scoring.** The closed-book grader checks citability, not truth: a stale fact that is faithfully cited still passes. So before scoring, re-execute every command string that appears in `context/*.md` (`ps`, `rg`, build/test/run commands, paths) against the repo; a command that cannot succeed as written is a **fail** for the question that cites it and a drafted correction in `SESSION.md`. Report the count: `context_selftest: n/n (citable) · m commands re-verified, k stale`.
3c. **Open Questions are a third state.** A question the brain answers only with an unresolved Open Question is **open**, not pass — unless the repo cannot answer it either (then it stays open honestly). The template-file pass rule applies only to the two files the population table marks as conversation-derived (`user-preferences.md`, `ui-context.md`). Report `n pass / n open / n fail`.
4. **Adversarial grade (when subagents available).** A second subagent tries to refute each answer ("is this actually supported by the context, or invented?"). Majority-refuted -> fail.

## Gaps are work, not just a score

For each failed question:

- **Discoverable from the repo** -> read the specific code, write the fact into the right context file (draft in `SESSION.md`, apply on `--save`).
- **Not provable from repo evidence** -> add to `.safe-code/context/progress-tracker.md` Open Questions for the user.

Record the result as `context_selftest: <pass>/<total> pass · <open> open · <fail> fail · <m> commands re-verified (<date>)` in `progress-tracker.md`, and report it in the final summary. Keep the question set small — this is a coverage gate, not an interrogation.
