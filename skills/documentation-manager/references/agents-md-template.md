# AGENTS.md — Project Knowledge & Agent Instructions

> **This file is the hub for project knowledge, architecture overview, decisions, and instructions for anyone (human or AI) working on this codebase.**  
> Always read this file and the relevant documents in `docs/` before starting significant work. Update them when you make important changes.  
> Code is the source of truth for implementation details; these documents capture the *why* and high-level *what*.

## Project Overview

[Short description, elevator pitch, main goals]

## Key Links

- Product Vision: [docs/product-vision.md](./docs/product-vision.md)
- Requirements: [docs/requirements.md](./docs/requirements.md)
- Architecture: [docs/architecture.md](./docs/architecture.md)
- Decisions (ADRs): [docs/decisions/](./docs/decisions/)
- Roadmap: [docs/roadmap.md](./docs/roadmap.md)
- Data Model: [docs/data-model.md](./docs/data-model.md) *(if present)*
- API: [docs/api.md](./docs/api.md) *(if present)*
- Testing Strategy: [docs/testing-strategy.md](./docs/testing-strategy.md) *(if present)*
- Operations: [docs/operations.md](./docs/operations.md) *(if present)*
- Glossary: [docs/glossary.md](./docs/glossary.md) *(if present)*

*(On adopt-integrate, replace or supplement with links to **existing** productive authorities — e.g. CLAUDE.md, docs/modules/, docs/architecture/ — instead of inventing parallel paths.)*

## Features

| Feature | Doc | Status |
|---------|-----|--------|
| [Name] | [docs/features/slug/README.md](./docs/features/slug/README.md) | Real / Dual / … |

*(Add a row for every feature pack under `docs/features/`. Status tokens from the skill's status taxonomy: Real, Dual, Local, Demo, Partial, Planned, In progress, Shipped, Deprecated, Unknown, Index.)*

## Surface coverage

> Required on **adopt** (full or integrate). Every product surface discovered in code should appear once.  
> Status values: [status taxonomy](status-taxonomy.md) — `Real` | `Dual` | `Local` | `Demo` | `Partial` | `Planned` | `In progress` | `Shipped` | `Deprecated` | `Unknown` | `Index`.

| Surface / ModuleId | Canonical doc | Feature pack | Status | Gap |
|--------------------|---------------|--------------|--------|-----|
| `example-module` | [docs/modules/example.md](./docs/modules/example.md) | [features/example](./docs/features/example/README.md) | Dual | residual legacy |
| `undocumented-surface` | — | — | Unknown | needs feature pack or module doc |

Rules:
- Prefer linking an existing module/canonical doc over writing a new narrative.
- Rows with empty Canonical doc **and** empty Feature pack = open documentation debt.
- Do not omit surfaces just because you did not write a long feature README.

## Instructions for AI Agents & Contributors

- Consult this hub and relevant `docs/` files at the start of any significant task.
- After work that affects architecture, requirements, decisions, features, or plans, update the corresponding documents and this hub (including coverage matrix rows).
- Prefer creating or updating ADRs for significant technical decisions (one decision per file; continue the repo's numbering scheme).
- Document features under `docs/features/<kebab-slug>/` and link them here; one primary ModuleId per slug unless this is a cluster **Index**.
- Keep documentation living and accurate — usefulness over volume; one authority per topic.
- When uncertain about product intent, ask clarifying questions rather than assuming.
- Do not delete durable decisions; mark ADRs as Deprecated or Superseded instead.
- Do not invent endpoints, tables, or modules; mark TBD / open question instead.

## Current Status Summary

[High-level current state, major open items, last major update]

_Last updated: YYYY-MM-DD by [who]_
