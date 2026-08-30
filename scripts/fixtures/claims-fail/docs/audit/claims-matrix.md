# Claims matrix fixture — critical Contradicted (must FAIL audit-claims.sh)

## Claims matrix

| ID | Claim | Source doc | Code evidence | Anchor | Severity | Verdict | Action |
|----|-------|------------|---------------|--------|----------|---------|--------|
| C-001 | Payment API is live | README | none | `anchor.path=src/pay.ts` | critical | Contradicted | fix doc |
| C-002 | Docs mention optional widget | notes | n/a | | normal | Missing | keep |
| C-003 | Legacy claim without severity still Contradicted | old | conflict | | | Contradicted | keep |
