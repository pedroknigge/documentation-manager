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

## Implementation bridge

> **Opt-in Stage B.** Omit this section until the user asks to implement / scaffold / stubs — or leave a one-line placeholder: *“Say implement/stubs to fill.”*  
> Full rules: [implementation-bridge.md](implementation-bridge.md). Paths below are **hypotheses**, not SSOT.

**Stubs written:** no | yes (user opt-in)

### Placement

| Area | Proposed path | Layer (Ark or convention) | Status |
|------|---------------|---------------------------|--------|
| Entry | TBD | TBD | hypothesis |
| Core | TBD | TBD | hypothesis |
| Tests | TBD | TBD | hypothesis |

### Engineering checklist

- [ ] (derive from Acceptance criteria)
- [ ]

### Stub inventory (only if user opted in)

| Path | Purpose | Written? |
|------|---------|----------|
| | | no |

### Anti-hallucination

- No endpoint/table/ModuleId marked **Real** without code evidence.

## Promotion

When implementation starts or the surface is real in code:

1. Create `docs/features/<slug>/` from [feature-readme-template.md](feature-readme-template.md) (status from **code**, not stubs).
2. Re-check acceptance criteria against code; supersede diverged stub inventory.
3. Move durable decisions into ADRs if locked.
4. Link this plan from the feature pack (**Related docs**).
5. Mark this plan **Shipped** or **Superseded** and link the feature pack.
6. Update hub nav + Surface coverage row; drop or archive the plan link if the pack is now the authority.

See also promote checklist in [implementation-bridge.md](implementation-bridge.md).

## Related

- Roadmap row / epic: …
- ADR (if any): …
- Spike / research: …
