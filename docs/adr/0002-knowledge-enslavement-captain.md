# ADR-0002: Knowledge enslavement and the captain rule

**Status:** Accepted  
**Date:** 2026-09-05  
**Deciders:** Pedro  
**Tags:** north-star, captain, knowledge-os, governance

## Context / Problem

Later slices (breadcrumbs, git-diff audit, cascade, reconcile) need a **binding north star** before anyone writes engines or formats. Without it, agents soften the goal into “helpful docs,” invent regimes, or treat the skill as an always-on product that overrides the developer.

This ADR locks the goal and the captain rule. It does **not** specify implementations.

## Alternatives Considered

1. **Always-on product** that rewrites the tree on its own — rejected. The skill is independent and on-demand.
2. **Agent as authority** (latest-by-date wins; tool overrides evolved layout) — rejected. Human is captain; HITL when it is unclear who wins.
3. **Soft “alignment” wording** — rejected. The north star is already locked (Pedro 2026-09-05). Do not rewrite or soften it.

## Decision

**North star (binding — do not rewrite or soften):**

> Make knowledge enslavement inevitable for agents, with the human as captain.

**Captain rule:** the tool helps order. It never overrides an evolved layout or a developer decision. The human remains captain. When it is unclear who wins, stop and ask (HITL).

### Operating shape (locked here; engines live elsewhere)

| Constraint | Meaning |
|------------|---------|
| On-demand skill | Independent skill, not an always-on product. |
| Breadcrumbs in code | `id` + Haken parent/plane + status, mirroring docs. The comment is a **mirror**, not the sole truth. |
| Audit scope | From **git diff / changed files only**. Never full-tree scans. |
| Cascade | Parent change → review children. **Haken Versklavungsprinzip** decides hold vs escalate/break: hold if still enslaved to parent (`s≈f(q)`); escalate/break when not. Downward for-review on parent release. The LLM does **not** invent the regime. |
| Reconcile | Classify agent-written plans/MDs as evolution vs regime change vs orphan vs contradiction. No living contradictions. HITL when unclear who wins. Latest-by-date does **not** auto-win — the supersede / enslavement verdict does. |
| Structure | Propose structure. Never override evolved layout or developer decisions. |
| Later ports | Orderfield / ArkGate ports are optional and **out of scope** for this decision. |

## Consequences

**Positive:**

- One durable sentence agents cannot “improve.”
- Captain / HITL is explicit before any cascade or reconcile code exists.
- Subtractive: later PRs implement rows; they do not reopen the goal.

**Negative / Risks:**

- “Enslavement” is sharp on purpose. Soften it in a PR and you have left this ADR.
- Naming Haken terms here is **not** a format spec. Inventing a wire from this page would be scope creep.

**Neutral / Notes — out of scope (other rows own these):**

- Breadcrumbs format spec
- Cascade engine
- Git-diff audit implementation
- Reconcile logic
- Orderfield / ArkGate ports

## Links

- First-contact pointer: [../../README.md](../../README.md)
- Prior ADR in this series: [0001-living-claims-wire-format.md](./0001-living-claims-wire-format.md)
- Epic (does not replace this lock): [../plans/knowledge-os/README.md](../plans/knowledge-os/README.md)
