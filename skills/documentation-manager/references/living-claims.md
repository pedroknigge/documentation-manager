# Living claims (v0) — Knowledge OS first increment

Machine-anchored structural claims on top of the existing audit matrix. **Markdown matrix is SSOT.** Dashboard truth score is **advisory**; **CI / local `audit-claims.sh` is the gate**.

**Package:** skill **2.5.0+** · Narrative: Knowledge OS **first increment toward 100×** (10× already shipped at v2.0; not a second 10× or full 100× leap).

**Wire ADR:** [docs/adr/0001-living-claims-wire-format.md](../../../docs/adr/0001-living-claims-wire-format.md)

## When

| Signal | Action |
|--------|--------|
| Intent / mode **audit** | Write matrix with living-claims columns (anchors + severity) |
| “living claims”, “truth score”, “docs CI”, “fail on Contradicted” | Follow this procedure + modes §6 / §13 |
| Integrate after audit | Patch Contradicted/Missing; keep anchors honest |

## Wire format (v0)

Every structural claim row:

| Field | Required | Values / notes |
|-------|----------|----------------|
| `id` | yes | e.g. `C-001` |
| claim | yes | Quote or paraphrase |
| source doc | yes | Relative path |
| `anchor.path` | yes when claim is structural and path-backed | Repo-relative path |
| `anchor.symbol` | optional | Symbol / export / ModuleId |
| `anchor.hash` | optional | Opaque content hash string |
| `severity` | optional | `critical` \| `normal` (default **`normal`** if omitted) |
| `verdict` | yes | `OK` \| `Partial` \| `Missing` \| `Contradicted` \| `Unverifiable` |
| action | recommended | keep / fix doc / open Q |

**Matrix-first:** extend [audit-template.md](audit-template.md) / `docs/audit/claims-matrix.md`. Do **not** invent a parallel claims wiki or sidecar SSOT.

Legacy matrices without Severity/Anchor columns: valid; parsers treat severity as `normal`.

## Truth score vs CI

**Advisory score** (aligns with `generate-docs-dashboard.sh`):

```text
score = (OK_N * 100 + PARTIAL_N * 50) / TOTAL_V   # TOTAL_V > 0
```

`TOTAL_V = OK + Partial + Missing + Contradicted + Unverifiable`.

**Gate (enforcement):** any `severity=critical` + `verdict=Contradicted` → local CI / `scripts/audit-claims.sh` **exit non-zero**. Optional: also fail critical `Missing`. Dashboard MAY floor score to `0` under the same condition; do not treat HTML as merge authority.

**Graceful v0:**

- No matrix → skip/warn (exit 0 or documented warn); do not invent claims.
- Matrix without severity → all rows `normal`.

## Agent procedure

1. Code inventory first ([modes.md §6.1](modes.md#61-code-inventory-always-first)).  
2. Extract structural claims only.  
3. For each claim: set `anchor.path` (and optional symbol/hash); set `severity=critical` only when a false claim would ship a lie about a shipped surface / security / install path.  
4. Verdicts unchanged — **code wins**.  
5. Write `docs/audit/claims-matrix.md` (or sandbox) from [audit-template.md](audit-template.md).  
6. Offer dashboard ([knowledge-dashboard.md](knowledge-dashboard.md)) as view; remind that **CI is the gate**.  
7. Never invent code to satisfy a claim; never auto-commit.

## CI (local / air-gapped)

Consumers (and this package example workflow) run a pure local script — **no network**:

```bash
./scripts/audit-claims.sh [path-to-claims-matrix.md]
```

Example GitHub Actions: copy `.github/workflows/docs-audit.yml` from the skill package (opt-in). Script + fixtures land with the CI slice; this document is the skill-side contract.

## Non-goals (v0)

- SaaS / control-plane / org merge policy engines  
- Formal proof / SMT  
- Auto-commit; inventing implementation to match docs  
- Replacing Notion/MkDocs  

## Concept anchors (greppable)

`living claims` · `living-claims` · `anchor.path` · `severity` · `critical Contradicted` · `truth score` · `audit-claims` · `docs-audit`

## Related

- Modes: [modes.md §6](modes.md#6-audit-project-or-feature) · [§13](modes.md#13-living-claims--ci-structural-audit-v25)  
- Quality: [quality-checklist.md](quality-checklist.md)  
- Feature pack: [docs/features/living-claims/README.md](../../../docs/features/living-claims/README.md)  
- Epic: [docs/plans/knowledge-os/README.md](../../../docs/plans/knowledge-os/README.md)  
