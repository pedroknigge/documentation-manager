# Feature: 10× v2.0 release package

> Hub: [AGENTS.md](../../../AGENTS.md) · [Roadmap](../../roadmap.md) · [Adoption matrix](../../adoption-matrix.md)

**Status:** Shipped  
**Slug:** `tenx-v2-release`  
**Owners:** skill maintainers  
**Last updated:** 2026-07-15

## Purpose

Close **Fase 1 (10×)** of the skill roadmap: ship a coherent **2.0.0** package that rolls up ArkGate bridge, autopilot v2, dashboard, hardening, discovery, and an honest adoption tracking matrix.

## What 2.0.0 contains

| Epic | Version introduced | Status |
|------|-------------------|--------|
| ArkGate bridge | 1.4 | Shipped |
| Feature autopilot v2 | 1.5 | Shipped |
| Knowledge dashboard | 1.6 | Shipped |
| Skill hardening + discovery | 1.7 | Shipped |
| Adoption matrix + release packaging | **2.0** | Shipped |

## Public surface

| Kind | Surface |
|------|---------|
| Skill version | `metadata.version` **2.0.0** |
| Adoption tracking | [docs/adoption-matrix.md](../../adoption-matrix.md) |
| Human changelog | [CHANGELOG.md](../../../CHANGELOG.md) |
| Pre-release gate | [PUBLISH.md](../../../PUBLISH.md) |

## Acceptance (10× checklist)

- [x] ArkGate bridge procedure + validate  
- [x] Autopilot v2 + Implementation bridge  
- [x] Knowledge dashboard generator  
- [x] Hardening fixtures + golden cases  
- [x] Discovery / upgrade docs  
- [x] Adoption matrix file  
- [x] Version **2.0.0** aligned (SKILL · README · AGENTS)  
- [x] `./scripts/validate-skill.sh` green  

## Non-goals for this release

- Polyglot / SaaS / org hub (Fase 2–3)  
- Claiming unverified public install counts  
- Auto-push or forced GitHub release tag without human  

## Related

- Plan (historical epics): [docs/plans/](../../plans/)  
- Roadmap Fase 1: [roadmap.md](../../roadmap.md)
