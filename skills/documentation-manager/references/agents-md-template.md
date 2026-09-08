# AGENTS.md — Project Knowledge & Agent Instructions

> **This file is the hub for project knowledge, architecture overview, decisions, and instructions for anyone (human or AI) working on this codebase.**  
> Always read this file and the relevant documents in `docs/` before starting significant work. Update them when you make important changes.  
> Code is the source of truth for implementation details **and** for whether a structural claim is true.  
> These documents capture the *why* and high-level *what*. On conflict, **code wins** — fix or flag the doc.

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
- Team (owners): [docs/team/OWNERS.md](./docs/team/OWNERS.md) *(if present — pointer only, not an HR wiki)*
- Approval notes: [docs/team/approval-notes.md](./docs/team/approval-notes.md) *(if present)*
- Go/no-go (Gate A/B): [docs/ops/go-nogo.md](./docs/ops/go-nogo.md) *(if present — ops/TO-BE trail, not a code claim)*

*(On adopt-integrate, replace or supplement with links to **existing** productive authorities — e.g. CLAUDE.md, docs/modules/, docs/architecture/ — instead of inventing parallel paths.)*

## Plans

| Plan | Doc | Status |
|------|-----|--------|
| [Name] | [docs/plans/github-login/slug/README.md](./docs/plans/github-login/slug/README.md) | Planned / In progress / … |

*(New writes: `docs/plans/<github-login>/<slug>/`. Finished plans: `docs/plans/<github-login>/_archive/<slug>/`. Adopt existing flat `docs/plans/<slug>/` trees — no force-migrate. Promote to a feature pack when code is real.)*

## Features

| Feature | Doc | Status |
|---------|-----|--------|
| [Name] | [docs/features/slug/README.md](./docs/features/slug/README.md) | Real / Dual / … |

*(Add a row for every feature pack under `docs/features/`. Status tokens from the skill's status taxonomy: Real, Dual, Local, Demo, Partial, Planned, In progress, Shipped, Deprecated, Unknown, Index.)*

## Package index *(monorepo only)*

> When **Monorepo hubs** apply (workspaces / `pnpm-workspace` / `go.work` / multi-package). Root hub is a **map**, not a dump of every package’s narrative.  
> See skill [skill-discovery.md](skill-discovery.md) Monorepo hubs.

| Package path | Role (short) | Hub / docs | Docs status |
|--------------|--------------|------------|-------------|
| `packages/example` | … | [packages/example/AGENTS.md](./packages/example/AGENTS.md) or — | documented / linked / **gap** |

Rules:
- Index only — do not paste full package product vision into the root hub.
- Packages without docs → **gap** (do not invent product vision).
- Default non-writes: root index must not rewrite mature package docs.

## Surface coverage

> Required on **adopt** (full or integrate). Every product surface discovered in code should appear once.  
> **Monorepo:** include a row per package (use package path as Surface when ModuleId unknown) — multi-package coverage.  
> Status values: [status taxonomy](status-taxonomy.md) — `Real` | `Dual` | `Local` | `Demo` | `Partial` | `Planned` | `In progress` | `Shipped` | `Deprecated` | `Unknown` | `Index`.

| Surface / ModuleId | Canonical doc | Feature pack | Status | Gap |
|--------------------|---------------|--------------|--------|-----|
| `example-module` | [docs/modules/example.md](./docs/modules/example.md) | [features/example](./docs/features/example/README.md) | Dual | residual legacy |
| `packages/undocumented` | — | — | Unknown | **gap** — needs package hub or feature pack |

Rules:
- Prefer linking an existing module/canonical doc over writing a new narrative.
- Rows with empty Canonical doc **and** empty Feature pack = open documentation debt (**gap**).
- Do not omit surfaces just because you did not write a long feature README.
- Monorepo: one authority per package topic; root links, does not duplicate SSOT.

## Instructions for AI Agents & Contributors

- Consult this hub and relevant `docs/` files at the start of any significant task.
- After work that affects architecture, requirements, decisions, features, or plans, update the corresponding documents and this hub (including coverage matrix rows).
- Prefer creating or updating ADRs for significant technical decisions (one decision per file; continue the repo's numbering scheme).
- Document **plans** under `docs/plans/<github-login>/<kebab-slug>/` for new work without solid code (never invent a login; HITL if unknown); **features** under `docs/features/<kebab-slug>/` when code-backed. One primary ModuleId per slug unless this is a cluster **Index**. Promote plans → feature packs when implementation lands, then archive-on-finish.
- Keep documentation living and accurate — usefulness over volume; one authority per topic.
- When uncertain about product intent, ask clarifying questions rather than assuming.
- Do not delete durable decisions; mark ADRs as Deprecated or Superseded instead.
- Do not invent endpoints, tables, or modules; mark TBD / open question instead.
- Prefer an **audit** (claims matrix) when docs may have drifted from code before large rewrites.

## Current Status Summary

[High-level current state, major open items, last major update]

_Last updated: YYYY-MM-DD by [who]_
