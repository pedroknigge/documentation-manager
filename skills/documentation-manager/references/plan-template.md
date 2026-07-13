# Plan: [Name]

> **Plan (not SSOT implementation docs).** Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · [Architecture](../../architecture.md) · future pack: `docs/features/<slug>/`  
> When this ships or lands in code, **promote** to a feature pack (see Promotion).

**Status:** Planned | In progress | Shipped | Cancelled | Superseded  
**Slug:** `feature-slug`  
**Kind:** new feature | epic | spike | redesign  
**Owners:** [team or roles]  
**Last updated:** YYYY-MM-DD  
**Code path (if any):** `…` or *none yet*

## Problem

[What hurts today? Who feels it? Why now?]

## Outcome

[One paragraph: what success looks like for users/business after this lands.]

## Users & success

- **Primary users:** …
- **Success metrics:** …
- **Non-goals / out of scope:** …

## MVP scope

| In MVP | Later / out |
|--------|-------------|
| … | … |

## Acceptance criteria

- [ ] …
- [ ] …
- [ ] …

## Proposed public surface (hypothesis)

| Kind | Surface | Notes |
|------|---------|-------|
| API / route | | TBD until code |
| UI | | |
| CLI / job | | |
| Events | | |
| ModuleId / package | | |

*If code does not exist yet, mark rows TBD — do not invent endpoints.*

## Approach (short)

[How we think we will build it. Link architecture constraints. Prefer bullets over essays.]

```mermaid
flowchart LR
  Need[User need] --> Entry[Entry point]
  Entry --> Core[Core change]
  Core --> Result[Outcome]
```

## Dependencies & risks

- **Depends on:** …
- **Blocked by:** …
- **Risks:** …
- **Open decisions:** (promote to ADR only when locked)

## Open questions

- …

## Promotion

When implementation starts or the surface is real in code:

1. Create `docs/features/<slug>/` from [feature-readme-template.md](feature-readme-template.md) (status from code).
2. Move durable decisions into ADRs if locked.
3. Link this plan from the feature pack (**Related docs**).
4. Mark this plan **Shipped** or **Superseded** and link the feature pack.
5. Update hub nav + Surface coverage row; drop or archive the plan link if the pack is now the authority.

## Related

- Roadmap row / epic: …
- ADR (if any): …
- Spike / research: …
