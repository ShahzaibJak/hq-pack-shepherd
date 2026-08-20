# Configuration contract

Write one JSON object from `assets/config-template.json`.

Record both measurable `goals` and explicit `nonGoals`. Goals describe desired outcomes; they never imply permission. Non-goals make excluded actions reviewable during pilot and activation.

## Source entries

Each source contains:

- `id`: stable local identifier.
- `type`: connector or adapter kind, such as `github`, `linear`, `slack`, `email`, `zendesk`, `local-markdown`, or `custom`.
- `locator`: non-secret queue, project, channel, mailbox, label, or path selector.
- `secretKeys`: HQ secret key names only.
- `readPolicy`: eligible item and reply/event rules.
- `identityKey`: source-native immutable identity used for exact idempotency.
- `canonicalLocation`: issue, ticket, message, or thread coordinates used for evidence and handoff.

Keep source-native identifiers as evidence. Never deduplicate by title alone.

## Permission rules

`read` and `classify` may be enabled during the pilot. Every other permission is a separate boolean.

`merge` and `deploy` default false and stay false through the pilot. They MAY be enabled after activation, but only behind explicit, individually named gates and only when the deployment's own review and release workflows still own the final action — Shepherd drives the gated path, it never bypasses required reviews, branch protection, or release approvals. Enable them one gate at a time, never together as a bundle.

**Verify-before-resolve is the invariant.** When merge/deploy are gated on, resolution is still not automatic: a merged or released change must pass an explicit verify phase before any resolve phase may close its issue. The resolve path only ever closes items already marked `verified`; it never runs verification itself, and merge, deploy, or inactivity never resolve an item on their own.

`closeOrResolve` requires an explicit human terminal signal even after activation. The single automated exception is the verified-deploy terminal path (see below); it is gated, unattended-only, and re-checks every guard at write time.

### Verified-deploy terminal path

A reference deployment (HQ Feedback Orchestrator, US-008) added one gated automated resolution for issues Shepherd drove end to end. It fires only when all four preconditions hold: the item is unattended (no external claimant), Shepherd-owned, `verified` by the verify phase, and not on hold — and only behind its resolve gate. It writes a terminal `resolved` transition idempotently, becomes a no-op once terminal / not-verified / on-hold / taken, and a later matching signal opens a follow-up rather than reopening the resolved item. Everything outside this exact contract still requires a human terminal signal.

## Activation

Changing `mode` to `active` is necessary but insufficient. Enable only the minimum individual permission booleans approved after pilot review. Record the approval separately in the company project journal or another company-governed decision log.
