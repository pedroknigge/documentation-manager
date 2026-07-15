# Feature: Skill hardening

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Plan: [../../plans/skill-hardening/README.md](../../plans/skill-hardening/README.md)

**Status:** Shipped  
**Slug:** `skill-hardening`  
**Owners:** skill maintainers  
**Last updated:** 2026-07-15

## Purpose

Give maintainers a local, deterministic suite so refactors of SKILL.md / modes / install do not silently break plan-vs-feature contracts, version sync, or install completeness.

## Canonical authority

| Topic | Authority | Role |
|-------|-----------|------|
| Hardening tests | [scripts/test-skill-hardening.sh](../../../scripts/test-skill-hardening.sh) | Entry |
| Fixtures | [scripts/fixtures/](../../../scripts/fixtures/) | Data |
| Discovery | [skill-discovery.md](../../../skills/documentation-manager/references/skill-discovery.md) | Agent install/upgrade |
| Validate chain | [scripts/validate-skill.sh](../../../scripts/validate-skill.sh) | Gate |
| Publish | [PUBLISH.md](../../../PUBLISH.md) | Pre-release |

## Acceptance criteria

- [x] validate + hardening suite exit 0
- [x] ≥3 fixtures (thin / mature / no-docs)
- [x] Golden mode anchors (≥8)
- [x] Version sync SKILL/README/AGENTS
- [x] Upgrade/discovery documented
- [x] PUBLISH pre-release gate

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| CLI | `test-skill-hardening.sh`, `validate-skill.sh`, `install-smoke.sh` | Real |
| Fixtures | `scripts/fixtures/**` | Real |
| Docs | skill-discovery.md | Real |

## Related docs

- Plan: [../../plans/skill-hardening/README.md](../../plans/skill-hardening/README.md)
