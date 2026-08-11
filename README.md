# Shepherd

Turn any HQ agent into a guarded manager for issues, tickets, feedback, and operational queues.

Shepherd is source-agnostic. Its setup walkthrough helps the operator select the company and agent, connect one or more issue sources, define goals and lifecycle states, set scope and permissions, choose handoff and escalation rules, and prove the configuration with a read-only pilot before enabling writes.

## Install

After the marketplace listing is approved:

```bash
hq install marketplace:shepherd
```

Then run `/shepherd-setup`.

## What it installs

- `/shepherd-setup`: guided setup and pilot workflow
- `/shepherd`: repeatable operating loop for configured sources
- `shepherd` knowledge: lifecycle, safety, adapter, and pilot contracts

Configuration is company-scoped by default at `companies/{company}/settings/shepherd.json`. Personal use writes to `personal/settings/shepherd.json`. The configuration stores secret key names only, never credentials.

The default mode is `pilot`. A pilot may read and classify a bounded sample, but it cannot comment, create tickets, change status, assign work, merge, deploy, close, or resolve anything.

Source: [ShahzaibJak/hq-pack-shepherd](https://github.com/ShahzaibJak/hq-pack-shepherd)
