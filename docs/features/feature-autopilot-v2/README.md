# Feature: Feature autopilot 2.0

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Plan: [../../plans/feature-autopilot-v2/README.md](../../plans/feature-autopilot-v2/README.md)

**Status:** Shipped  
**Slug:** `feature-autopilot-v2`  
**Owners:** skill maintainers  
**Last updated:** 2026-07-15

## Purpose

Plain-language feature requests produce the right docs artifact **and**, when asked, an optional **Implementation bridge** (placement / stubs as hypotheses) without turning Documentation Manager into a full codegen product.

## Canonical authority

| Topic | Authority | This pack's role |
|-------|-----------|------------------|
| Autopilot procedure | [modes.md §3](../../../skills/documentation-manager/references/modes.md) | Entry |
| Implementation bridge | [implementation-bridge.md](../../../skills/documentation-manager/references/implementation-bridge.md) | Entry |
| Plan template | [plan-template.md](../../../skills/documentation-manager/references/plan-template.md) | Bridge section |
| Core rules | [SKILL.md](../../../skills/documentation-manager/SKILL.md) rule 15 | Index |

## Users & success

- **Primary users:** AI-first devs naming features in natural language
- **Success metrics:** docs-first default; stubs only on opt-in; promote from code not stubs
- **Out of scope:** multi-agent swarms, IDE plugins, mass PR generation

## Acceptance criteria

- [x] Decision table v2 (plan/feature/kind/bridge) in modes.md
- [x] Implementation bridge template + procedure
- [x] Opt-in stubs; default no product code
- [x] Ark layer placement when ArkGate detected
- [x] Quality bar anti-hallucination
- [x] validate-skill green (v1.5.0)

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| Skill procedure | modes §3.1–3.8, implementation-bridge.md | Real |
| Templates | plan-template, feature-readme bridge sections | Real |
| Package version | skill **1.5.0** | |

## How it works

Stage A: plan vs pack + Kind. Stage B (opt-in): placement, checklist, optional stubs marked hypothesis. Promote: code inventory wins.

## Related docs

- Plan: [../../plans/feature-autopilot-v2/README.md](../../plans/feature-autopilot-v2/README.md)
- ArkGate bridge: [../arkgate-bridge/README.md](../arkgate-bridge/README.md)
