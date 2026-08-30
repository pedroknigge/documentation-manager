# Documentation claims audit

> Hub: [AGENTS.md](../../AGENTS.md) (adjust relative path)  
> **Code is source of truth.** Docs do not override implementation.  
> **Living claims v0:** anchors + severity — see [living-claims.md](living-claims.md) and [ADR-0001](../../../docs/adr/0001-living-claims-wire-format.md).

**Date:** YYYY-MM-DD  
**Scope:** project | feature:`slug`  
**Intent:** audit  
**Out:** root | sandbox:path  
**Auditor:** documentation-manager

## Summary

| Verdict | Count |
|---------|------:|
| OK | 0 |
| Partial | 0 |
| Missing | 0 |
| Contradicted | 0 |
| Unverifiable | 0 |

| Severity | Count |
|----------|------:|
| critical | 0 |
| normal | 0 |

**Truth score (advisory):** _computed by dashboard / formula below — not a merge gate_  
**CI gate:** fail if any **critical** + **Contradicted** (local `scripts/audit-claims.sh`).

**Top risks:**  
1. …  
2. …

**Recommended next Intent:** integrate (patch) | from-zero (sandbox) | none  

## Code inventory (high level)

| Kind | Evidence (paths / symbols) | Notes |
|------|----------------------------|-------|
| ModuleIds / packages | | |
| UI surfaces | | |
| API route families | | |
| Data / schema areas | | |
| Jobs / kernel | | |

Do not paste full endpoint dumps into permanent product docs.

## Claims matrix

| ID | Claim (quote or paraphrase) | Source doc | Code evidence | Anchor path | Anchor symbol | Anchor hash | Severity | Verdict | Action |
|----|----------------------------|------------|---------------|-------------|---------------|-------------|----------|---------|--------|
| C-001 | | | | | | | normal \| critical | OK \| Partial \| Missing \| Contradicted \| Unverifiable | keep / fix doc / open Q |
| C-002 | | | | | | | | | |

### Living-claims columns

| Column | Maps to | Notes |
|--------|---------|-------|
| Anchor path | `anchor.path` | Repo-relative path; required for structural anchored claims |
| Anchor symbol | `anchor.symbol` | Optional symbol / export / ModuleId |
| Anchor hash | `anchor.hash` | Optional opaque content hash |
| Severity | `severity` | `critical` \| `normal`; **omit → `normal`** |

### Verdict definitions

| Verdict | Meaning |
|---------|---------|
| **OK** | Matches code |
| **Partial** | Exists but incomplete vs claim |
| **Missing** | Not found in code |
| **Contradicted** | Code conflicts with claim |
| **Unverifiable** | Not a structural claim |

### Truth score (advisory) vs CI

```text
score = (OK_N * 100 + PARTIAL_N * 50) / TOTAL_V   # TOTAL_V > 0
```

Aligns with `generate-docs-dashboard.sh`. If any **critical Contradicted** exists, CI **must** fail; dashboard score may floor to `0` but remains advisory.

## Follow-on plan (optional)

- [ ] Patch Contradicted rows in productive docs  
- [ ] Add coverage matrix gaps  
- [ ] from-zero sandbox for clean KB  
- [ ] File net-new ADRs for decisions that only live in code  
- [ ] Wire consumer CI to `scripts/audit-claims.sh` / example `docs-audit` workflow  

## Related

- Status taxonomy for feature rows  
- adopt-integrate non-writes if next Intent is integrate  
- Living claims procedure: [living-claims.md](living-claims.md)  
