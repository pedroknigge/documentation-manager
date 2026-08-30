# ADR-0001: Living claims v0 wire format

**Status:** Accepted  
**Date:** 2026-08-30  
**Deciders:** skill maintainers  
**Tags:** knowledge-os, audit, claims, ci

## Context / Problem

Audit already produces a Markdown **claims matrix** with verdicts (`OK` \| `Partial` \| `Missing` \| `Contradicted` \| `Unverifiable`), and the knowledge dashboard computes a heuristic truth score from verdict counts. Those claims are not machine-anchored to code paths, so CI cannot fail on critical lies and agents cannot reuse a stable wire shape.

Knowledge OS Phase-3 first increment (toward 100×; not a second 10×) needs a **matrix-first** living-claims format that scripts and CI can parse without inventing a parallel wiki.

## Alternatives Considered

1. **YAML/JSON sidecar next to each doc** — strong typing; splits SSOT from the matrix agents already write; higher adopt friction.
2. **Frontmatter per claim embedded in product docs** — pollutes narrative docs; hard to audit in one pass.
3. **Matrix-first columns (chosen)** — extend `docs/audit/claims-matrix.md` (or sandbox copy) with anchor + severity columns; optional thin procedure in `references/living-claims.md`.

## Decision

**Living claims v0 is matrix-first.** The claims matrix remains the single agent-written SSOT for structural claims. Columns (and parsers) MUST understand:

| Field | Required | Notes |
|-------|----------|-------|
| `id` | yes | Stable claim id (e.g. `C-001`) |
| claim text | yes | Quote or paraphrase |
| source doc | yes | Relative path to narrative doc |
| `anchor.path` | yes for structural rows that can be anchored | Repo-relative path evidence |
| `anchor.symbol` | optional | Symbol / export / ModuleId within path |
| `anchor.hash` | optional | Content hash of anchored file/snippet (opaque string) |
| `severity` | optional | `critical` \| `normal`; **omit → treat as `normal`** |
| `verdict` | yes | Unchanged enum: `OK` \| `Partial` \| `Missing` \| `Contradicted` \| `Unverifiable` |
| action | recommended | keep / fix doc / open Q |

Markdown table shape (human + script friendly):

```markdown
| ID | Claim | Source doc | Code evidence | Anchor path | Anchor symbol | Anchor hash | Severity | Verdict | Action |
|----|-------|------------|---------------|-------------|---------------|-------------|----------|---------|--------|
| C-001 | … | docs/… | … | path/to/file | optionalSym | optionalHash | critical \| normal | OK \| … | … |
```

Legacy matrices without Severity / Anchor columns remain valid: parsers treat missing severity as `normal` and missing anchors as ungated structural notes.

### Truth score (advisory) vs CI gate

**Dashboard heuristic** (unchanged base formula), for matrix with `TOTAL_V > 0`:

```text
score = (OK_N * 100 + PARTIAL_N * 50) / TOTAL_V
```

where `TOTAL_V = OK + Partial + Missing + Contradicted + Unverifiable`.

**Living-claims floor / CI:** if any row has `severity=critical` **and** `verdict=Contradicted`, treat as gate failure. Local `scripts/audit-claims.sh` (consumer/example CI) MUST exit non-zero. Dashboard score MAY floor to `0` when that condition holds, but **CI is the enforcement gate**; the HTML score stays **advisory**.

Graceful v0: no matrix → skip/warn (documented exit); matrix without severity → all `normal`.

## Consequences

**Positive:**

- Reuses audit matrix; no parallel claim wiki.
- Enables air-gapped local CI without SaaS.
- Aligns agents, dashboard, and scripts on one wire.

**Negative / Risks:**

- Parsers must tolerate legacy tables.
- Hash field is opaque in v0 (no mandated algorithm).

**Neutral / Notes:**

- Formal proof / SMT, auto-commit, and inventing code to match docs remain out of scope.
- Full Knowledge OS (org hub, SaaS) is later; this ADR is the first OS foundation slice toward 100×.

## Links

- Procedure: [../../skills/documentation-manager/references/living-claims.md](../../skills/documentation-manager/references/living-claims.md)
- Template: [../../skills/documentation-manager/references/audit-template.md](../../skills/documentation-manager/references/audit-template.md)
- Feature pack: [../features/living-claims/README.md](../features/living-claims/README.md)
- Epic: [../plans/knowledge-os/README.md](../plans/knowledge-os/README.md)
