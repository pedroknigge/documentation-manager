# Prototype → production — Appendix A coverage

Honesty map for Pedro norte *De prototipo a producción* v1.0 **Apéndice A** artifacts.

**This page is the SSOT** for what the skill does with those artifacts. Do not copy the table into `SKILL.md` or `modes.md`.

**Captain:** human. **Tool:** proposes. Never claim we **generate** what we only **audit**. Signing Gate A/B is always the captain.

## Verbs

| Verb | Meaning |
|------|---------|
| **generates** | Skill may write a first draft / proposal from templates. Captain accepts, edits, or rejects. |
| **audits** | Skill checks existing docs vs code (living claims / coverage). Does not author the artifact. |
| **out-of-scope (captain)** | Skill does not produce or sign this. Captain owns it. Skill may link if it already exists. |

## Coverage (today)

| Artifact | Skill | What exists today | Honesty |
|----------|-------|-------------------|---------|
| Problem / scope / non-goals | **generates** | `product-vision.md`, `requirements.md`, plan Problem / Non-goals / MVP scope, architecture Non-goals, feature Out of scope | Proposal on from-zero / bootstrap / plan / feature. Integrate: do not rewrite. |
| Domain invariants | **generates** | architecture Data & boundaries; optional `data-model.md` (invariants + ownership, not a schema dump) | Thin proposal. Not a dedicated invariants pack. |
| Context diagram | **generates** | [architecture-template.md](architecture-template.md) mermaid Context diagram | Proposal on from-zero / bootstrap / adopt-full. Integrate: adopt existing architecture. |
| Data inventory | **audits** | Code inventory ([modes.md §6.1](modes.md#61-code-inventory-change-set-only)); data-model claims if present | Code inventory ≠ a production data inventory. No inventory template. Do not generate a full inventory. |
| Threat model 1-pager | **out-of-scope (captain)** | AuthN/AuthZ one-liner in architecture only | No threat-model template or security review. If a 1-pager exists, treat as any other doc (code wins). Do not generate. |
| ADRs | **generates** | [adr-template.md](adr-template.md) + [modes.md §2.5](modes.md#25-adr-placement) | Net-new / inferred-from-code. Integrate: link existing; no parallel series. |
| Definition of Done | **generates** | plan / feature Acceptance criteria; [quality-checklist.md](quality-checklist.md) **Production-harden DoD** row is the skill’s bar when Intent=`production-harden` | Proposal AC + harden checklist. Still **not** a signed production Go (Gate A/B signing is captain / [modes.md §14](modes.md#14-gono-go-decision-trail-v254)). |
| Runbooks SEV | **out-of-scope (captain)** | none | No incident / SEV runbook template. Link if present. Do not generate. |
| Gate A/B signed | **out-of-scope (captain)** | Trail *proposal* is [go-nogo-template.md](go-nogo-template.md) + [modes.md §14](modes.md#14-gono-go-decision-trail-v254) | Human signs **Go**. Skill never auto-signs. Do not claim the trail is a signed gate. |

## When to load

User mentions prototipo a producción, Apéndice A, production checklist, Gate A/B, SEV runbooks, threat model, production-harden, or “no volver a prototipo” — load **this page**. Do not invent missing artifacts. Intent=`production-harden` DoD is the quality-checklist row + [modes.md §17](modes.md#17-production-harden-dod) — still not a signed Go.

## Non-goals

- Implementing missing artifacts (threat model, SEV runbooks, data inventory)
- Replacing the go/no-go trail (modes §14) or auto-signing Gate A/B
- Orderfield / ArkGate ports
- Claiming **generate** for **audits** or **out-of-scope (captain)** rows
