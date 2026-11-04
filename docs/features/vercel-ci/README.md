# Feature: Vercel CI surface for docs-audit

> Hub: [AGENTS.md](../../../AGENTS.md)  
> Plan: [docs/plans/pedroknigge/vercel-ci/PLAN.md](../../plans/pedroknigge/vercel-ci/PLAN.md)

**Status:** Shipped  
**Slug:** `vercel-ci`  
**Owners:** Pedro (captain) · skill maintainers  
**Last updated:** 2026-11-04  
**Package version:** skill **2.5.22**  
**Narrative:** The docs-audit gate can run inside a Vercel build and be read back as one verdict. GitHub Actions stays.

## Purpose

A repo with no GitHub Actions workflows can still fail a preview deployment on a critical Contradicted claim, and an agent can report `pass`, `fail`, `pending`, or `absent` without a second matrix parser.

## Canonical authority

| Topic | Authority | Role |
|-------|-----------|------|
| Gate process | `scripts/audit-claims.sh` | Real, unchanged, air-gapped |
| Actions example | `.github/workflows/docs-audit.yml` | Real, unchanged |
| Surface reader | `scripts/ci-surface.sh` | Real (`detect`, `read`, `recipe`) |
| Captain recipe | [vercel-ci.md](../../../skills/documentation-manager/references/vercel-ci.md) | Opt-in `buildCommand` |
| Procedure | [modes.md §13](../../../skills/documentation-manager/references/modes.md#13-living-claims--ci-structural-audit-v25) | Wiring |

## Public surface

| Kind | Surface | Notes |
|------|---------|-------|
| CLI | `ci-surface.sh detect` / `read` / `recipe` | **Real** |
| Recipe | `buildCommand` string from `recipe` | Opt-in. `install.sh` does not write `vercel.json` |
| Verdict | `pass` \| `fail` \| `pending` \| `absent` | Skipped, ignored, canceled → `absent`. Both surfaces must pass |

## What the interface hides

Callers ask for a surface and a verdict. The script hides commit-status context `Vercel`, check-run app slugs, `vercel[bot]` deployment statuses, the comments check that is not the deployment, and the rule that an unknown context is not a pass.

## Related

- Living claims gate: [living-claims](../living-claims/README.md)
- Tests: `scripts/test-ci-surface.sh`, fixtures `scripts/fixtures/ci-surface/` and `scripts/fixtures/vercel-no-actions/`
