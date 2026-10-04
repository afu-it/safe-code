# safe-code reference: feature specs (writing + dedup)

> Loaded on demand (Layer 3) before writing or flipping a `feature-specs/<NN>-<name>.md`
> file. The binding rules — every proposed feature becomes a `status: suggested` spec, no
> build before approval, the status lifecycle, the `[NEEDS CLARIFICATION]` gate, the two
> pre-write checks — live inline in SKILL.md (Feature Suggestion Rule); this file holds how
> to run the checks and how to write a spec that survives.

## Before writing a `status: suggested` spec

1. **Redundancy.** Search the codebase for an existing implementation by domain concept
   (not just the feature's name) and report where you looked. Already-implemented is a
   different outcome from rejected and is never recorded as a rejection.
2. **Rejection dedup by concept, not keyword.** Scan specs with `status: rejected` or
   `removed` — "night theme" matches a dark-mode rejection. On a match, surface it instead
   of re-litigating: "This resembles `feature-specs/07-dark-mode.md`, rejected because
   <reason>. Still feel the same way?"

## Status flips

- Draft each flip in `SESSION.md`, apply on `--save`; the spec file itself may be created
  immediately (Draft-Until-Save exception).
- `suggested -> approved` is blocked while any `[NEEDS CLARIFICATION]` marker remains:
  resolve each with the user (offer a recommended answer), write the answer in, delete the marker.
- `rejected` and `removed (<date>)` specs are long-term memory: keep the file, never
  re-suggest the idea. A removed feature's spec carries the same `restore:` pointer as its
  Graveyard entry.

## Writing a durable spec

A spec may sit at `suggested` for weeks while the code moves under it.

- Describe interfaces, type names, signatures, config shapes, and behavioural contracts —
  never file paths or line numbers.
- Write **what** the system should do, not how; the implementing agent explores fresh.
- Exception: a snippet that encodes a decision more precisely than prose (schema, state
  machine, type shape) may be inlined, trimmed to the decision-rich part.
- Never fabricate specs for already-completed features unless the user asks.
