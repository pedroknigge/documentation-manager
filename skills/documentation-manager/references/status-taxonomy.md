# Status taxonomy

Use **exactly** these labels as the primary status token (English tokens; surrounding prose may be localized).

| Status | Meaning |
|--------|---------|
| `Planned` | Not implemented |
| `In progress` | Active development |
| `Local` | UI/local state; no durable server data layer for the happy path |
| `Demo` | Prototype / fixture / partial demo surface |
| `Dual` | Migrating; dual providers or residual legacy path |
| `Real` | Canonical path: schema + repository/API + permissions; no direct legacy for happy path |
| `Shipped` | Production-used but maturity not classified as Real/Dual (prefer Real/Dual when known) |
| `Partial` | Important pieces missing (e.g. viewer yes, bridge no) |
| `Deprecated` | Do not extend |
| `Unknown` | Not assessed |
| `Index` | Cluster index only (not a single implementable surface) |

## Hub and feature tables

- **Primary token** first; optional short note in parentheses.
- Examples: `Dual (Airtable residual)`, `Partial (Twin→Bridge open)`, `Real`.
- Avoid free-form essays in the Status column.

## Mapping from prototype / dataState (if the repo has them)

| dataState / signal | Prefer status |
|--------------------|---------------|
| live + full data layer | `Real` |
| dual providers / Airtable residual | `Dual` |
| local-only | `Local` |
| demo / fixtures | `Demo` |
| mixed incomplete | `Partial` |
| not wired | `Planned` or `Unknown` |
