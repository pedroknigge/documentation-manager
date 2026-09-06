# Feature: Template telemetry

> Part of the skill-package knowledge base. Hub: [AGENTS.md](../../../AGENTS.md)  
> Related: [Roadmap](../../roadmap.md) · Plan: [../../plans/phase-2-bridge/README.md](../../plans/phase-2-bridge/README.md)

**Status:** Withdrawn  
**Slug:** `template-telemetry`  
**Owners:** skill maintainers  
**Last updated:** 2026-09-06  
**Package version:** shipped in skill **2.4.0**; withdrawn from the current skill surface

## Purpose (historical)

Capture **template / skill UX gaps** in an opt-in **local ledger** so maintainers could improve templates — without network, product code profiling, or secrets.

## Why withdrawn

This ritual does **not** make knowledge enslavement inevitable. It recorded skill UX gaps for maintainers; it did not bind claims to code, audit a git change set, cascade, or reconcile. Default was already **off**.

North star: [ADR-0002](../../adr/0002-knowledge-enslavement-captain.md). Captain stays captain — no ledger, no silent opt-in, no replacement ritual.

## What left the skill surface

| Removed | Why the cut is safe |
|---------|---------------------|
| `references/template-telemetry.md` | Agents no longer load a telemetry mode |
| `scripts/template-telemetry.sh` | No default-off JSONL ritual to install or test |
| SKILL rule + modes §12 + quality-checklist section | Not on the adopter path |
| `install.sh` remote fetch of the procedure | Classic install no longer ships it |

History of the 2.4.0 ship remains in [CHANGELOG](../../../CHANGELOG.md#240--2026-07-17).

## Related docs

- Umbrella (historical ship): [phase-2-bridge](../../plans/phase-2-bridge/README.md)  
- Binding north star: [ADR-0002](../../adr/0002-knowledge-enslavement-captain.md)  
