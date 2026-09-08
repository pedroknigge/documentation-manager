# Feature: Go/no-go Gate A/B trail

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Living claims (different plane): [../living-claims/README.md](../living-claims/README.md)

**Status:** Shipped  
**Slug:** `go-nogo`  
**Owners:** skill maintainers  
**Last updated:** 2026-09-08  
**Package version:** skill **2.5.4**  
**Narrative:** Patch on the Knowledge OS floor — a signed **ops / TO-BE** production decision trail. **Not** a new major; **not** a Knowledge OS leap; **not** living-claims CI.

## Purpose

Leave a **go/no-go trail in docs** so Gate A/B answers (**Sí** / **No** / **N/A justificado**) plus **one residual-risk sentence** exist at a pointable path. Golden rule: if you cannot point to where it is, it does not exist. **No greenwash.**

## Canonical authority

| Topic | Authority | Role |
|-------|-----------|------|
| Procedure | [modes.md §14](../../../skills/documentation-manager/references/modes.md#14-gono-go-decision-trail-v254) | Wiring |
| Template | [go-nogo-template.md](../../../skills/documentation-manager/references/go-nogo-template.md) | Consumer `docs/ops/go-nogo.md` |
| Core rule | [SKILL.md](../../../skills/documentation-manager/SKILL.md) rule 25 | Index |
| Audit token | [audit-template.md](../../../skills/documentation-manager/references/audit-template.md) | Dual-plane (CI ≠ go/no-go) |
| Quality bar | [quality-checklist.md](../../../skills/documentation-manager/references/quality-checklist.md) | Done checks |
| North binding | Consumer §20 tables / Apéndice A **Gate A/B firmado** | Criteria source (copy, do not invent) |

## Acceptance criteria

- [x] modes §14 procedure: Block A any No → cannot be Go; Block B No only with owner + due; HITL / human captain
- [x] Template for `docs/ops/go-nogo.md` with Sí / No / N/A justificado + residual-risk
- [x] Dual-plane: trail is ops/TO-BE; living-claims CI must not auto-fill Gate answers
- [x] SKILL + QC + audit-template + hub pointer wired; validate/hardening greppable
- [x] No product answers invented; no auth/backup/Orderfield implementation

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| Procedure | modes §14 | **Real** |
| Template | `references/go-nogo-template.md` | Consumer copies to `docs/ops/go-nogo.md` |
| Package version | **2.5.4** | patch-per-PR |

## How it works

1. User asks for go/no-go / Gate A/B / production gate.  
2. Agent copies **§20** criteria from the project (Apéndice A) into `docs/ops/go-nogo.md`.  
3. Each row gets Sí / No / N/A justificado with evidence — never invent a Sí.  
4. One residual-risk sentence. Gate A No blocks Go. Gate B No needs owner + due.  
5. **Go** is signed only by the human captain.

## Related docs

- [living-claims](../living-claims/README.md) — structural claims CI (different plane)
- [ADR-0002](../../adr/0002-knowledge-enslavement-captain.md) — captain / HITL
