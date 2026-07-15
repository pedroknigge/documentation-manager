# Feature: Knowledge dashboard

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Plan: [../../plans/knowledge-dashboard/README.md](../../plans/knowledge-dashboard/README.md)

**Status:** Shipped  
**Slug:** `knowledge-dashboard`  
**Owners:** skill maintainers  
**Last updated:** 2026-07-15

## Purpose

Give humans a fast offline HTML view of features, plans, and optional claims matrix — without replacing Markdown as SSOT or inventing documentation.

## Canonical authority

| Topic | Authority | This pack's role |
|-------|-----------|------------------|
| Generator | [scripts/generate-docs-dashboard.sh](../../../scripts/generate-docs-dashboard.sh) | Entry |
| Procedure | [knowledge-dashboard.md](../../../skills/documentation-manager/references/knowledge-dashboard.md) | Entry |
| Modes | [modes.md §10](../../../skills/documentation-manager/references/modes.md#10-knowledge-dashboard-v16) | Index |
| SKILL | rule 18 / v1.6.0 | Index |

## Users & success

- **Primary users:** humans scanning status; agents linking a report after audit
- **Success metrics:** one command → openable HTML; no invented claims; gitignored output default
- **Out of scope:** SaaS, WYSIWYG edit, CDN dashboards

## Acceptance criteria

- [x] Generator script documented and runnable
- [x] Output under `docs/audit/generated/` + gitignore
- [x] Relative links to markdown sources
- [x] Offline single-file HTML
- [x] Reads only existing docs
- [x] validate-skill green (v1.6.0)

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| CLI | `scripts/generate-docs-dashboard.sh` | Real |
| UI | `docs/audit/generated/dashboard.html` | Generated view |
| Skill | modes §10 + knowledge-dashboard.md | Real |

## How it works

Scan `docs/features/*/README.md` and `docs/plans/*/README.md` for Status/Slug/title; optional claims-matrix verdict counts; emit dark static HTML.

## Related docs

- Plan: [../../plans/knowledge-dashboard/README.md](../../plans/knowledge-dashboard/README.md)
