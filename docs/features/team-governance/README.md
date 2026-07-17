# Feature: Team governance

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Plan: [../../plans/phase-2-bridge/README.md](../../plans/phase-2-bridge/README.md)

**Status:** Shipped  
**Slug:** `team-governance`  
**Owners:** skill maintainers  
**Last updated:** 2026-07-17  
**Package version:** skill **2.3.0**

## Purpose

Give consumer repos a minimal **docs/team/** surface: who owns what, and optional **last approved** notes — without CODEOWNERS engines, BPM, or HR wikis.

## Canonical authority

| Topic | Authority | Role |
|-------|-----------|------|
| Procedure (create vs link, non-writes) | [team-governance.md](../../../skills/documentation-manager/references/team-governance.md) | SSOT |
| Owners template | [team-owners-template.md](../../../skills/documentation-manager/references/team-owners-template.md) | Consumer `docs/team/OWNERS.md` |
| Approval notes template | [team-approval-notes-template.md](../../../skills/documentation-manager/references/team-approval-notes-template.md) | Consumer `docs/team/approval-notes.md` |
| Modes | [modes.md §11](../../../skills/documentation-manager/references/modes.md#11-team-governance-v23-slice-c) | Wiring |
| Core rule | [SKILL.md](../../../skills/documentation-manager/SKILL.md) rule 23 | Index |
| Hub link | [agents-md-template.md](../../../skills/documentation-manager/references/agents-md-template.md) | Pointer only |

## Acceptance criteria

- [x] `docs/team/` layout + owners + approval-notes templates
- [x] Create vs link + integrate-first non-writes documented
- [x] Hub links Team without HR dump
- [x] validate + hardening green

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| Skill procedure | team-governance.md, modes §11 | **Real** |
| Templates | team-owners-template, team-approval-notes-template | **Real** |
| Package version | **2.3.0** | |

## How it works

1. User asks for owners/team → create or link `docs/team/`.  
2. Hub gets a Key Links pointer.  
3. Product narrative stays untouched (integrate-first).  
4. Monorepo: owner rows may use package paths from Package index.

## Related docs

- Umbrella: [phase-2-bridge](../../plans/phase-2-bridge/README.md)  
- Prior: [polyglot-mvp](../polyglot-mvp/README.md) · [monorepo-hubs](../monorepo-hubs/README.md)  
- Next: template telemetry (Slice D)  
