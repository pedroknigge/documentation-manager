# Living claims (v0) — Knowledge OS first increment

Machine-anchored structural claims on top of the existing audit matrix. **Markdown matrix is SSOT.** Dashboard truth score is **advisory**; **CI / local `audit-claims.sh` is the gate**.

**Package:** skill **2.5.0+** · Narrative: Knowledge OS **first increment toward 100×** (10× already shipped at v2.0; not a second 10× or full 100× leap).

**Wire ADR:** [docs/adr/0001-living-claims-wire-format.md](../../../docs/adr/0001-living-claims-wire-format.md)  
**Captain / north star:** [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)

## When

| Signal | Action |
|--------|--------|
| Intent / mode **audit** | **Diff-first** change set ([modes.md §6.0](modes.md#60-change-set-diff-first)), then write matrix with living-claims columns (anchors + severity) |
| “living claims”, “truth score”, “docs CI”, “fail on Contradicted” | Follow this procedure + modes §6 / §13 |
| Integrate after audit | Patch Contradicted/Missing; keep anchors honest |
| “breadcrumbs”, code-comment claim tags | Follow **Code breadcrumbs** below; propose only — no engines |

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

1. **Diff-first** change set ([modes.md §6.0](modes.md#60-change-set-diff-first)): `./scripts/audit-claims.sh --list-changed [--base REF]` or the git commands there. Never a full-tree read by default.  
2. Inventory **only those paths** ([modes.md §6.1](modes.md#61-code-inventory-change-set-only)). Extract structural claims only from the set. If the user opted into **full-tree / cold-start**, default that universe to `docs/` + root markdown + `.github` contributor docs and **exclude** `examples/**` unless they asked to include demos ([skill-discovery.md](skill-discovery.md) **Cold-start survey heuristics**; `./scripts/survey-docs.sh --claim-scope`).  
3. For each claim: set `anchor.path` (and optional symbol/hash); set `severity=critical` only when a false claim would ship a lie about a shipped surface / security / install path.  
4. Verdicts unchanged — **code wins**.  
5. Write `docs/audit/claims-matrix.md` (or sandbox) from [audit-template.md](audit-template.md).  
6. Offer dashboard ([knowledge-dashboard.md](knowledge-dashboard.md)) as view; remind that **CI is the gate**.  
7. If a changed breadcrumb names `parent=` (or a changed id is a parent), apply [modes.md §6.7](modes.md#67-cascade-verdicts-haken) — **recommend review** of children ([§6.9](modes.md#69-recommend-review-human-vs-agent)); do not run a cascade engine.  
8. If the set includes agent-written plans/MDs that share a topic with a living doc, apply [modes.md §6.8](modes.md#68-reconcile-classification-plansmds) — classify; **no living contradictions**; latest-by-date does not auto-win.  
9. When cascade / reconcile / audit needs eyes, recommend review per [modes.md §6.9](modes.md#69-recommend-review-human-vs-agent) (**human** vs **agent**; pointers into the set / claims / class). Do not assign, notify, or merge.  
10. Never invent code to satisfy a claim; never auto-commit. HITL when who-wins is unclear.

## CI (local / air-gapped)

Consumers (and this package example workflow) run a pure local script — **no network**.

The **merge gate** parses the **whole matrix**. Agent audit/reconcile **reads** stay **diff-first** ([modes.md §6.0](modes.md#60-change-set-diff-first)). Do not pass `--list-changed` to the CI job (that would hide existing critical Contradicted).

```bash
# gate (whole matrix — what CI runs):
./scripts/audit-claims.sh [PROJECT_ROOT]
./scripts/audit-claims.sh --matrix PATH

# change-set helper (agent reads — not the CI gate):
./scripts/audit-claims.sh --list-changed [--base REF] [PROJECT_ROOT]
```

Copy both `.github/workflows/docs-audit.yml` and `scripts/audit-claims.sh` into the consumer repo (opt-in). Enable the workflow as a required check to fail merge on **critical Contradicted**.

## Code breadcrumbs (comment mirror)

Optional one-line comments next to anchored code that **mirror** a living-claims `id`. The matrix row (and source doc) still holds the id. The comment is **not** the sole truth and **not** a second SSOT.

Tool **proposes**. Human is captain. Never override an evolved layout or a developer decision ([ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)). HITL when unclear.

### Line format

One line, host-language comment syntax, greppable `@claim`, space-separated `key=value` (lowercase keys):

```text
@claim id=<claim-id> [parent=<claim-id>] plane=<P3|P2|P1|P0> status=<changed|adjusted>
```

| Field | Required | Values |
|-------|----------|--------|
| `id` | yes | Same `id` as the matrix row ([ADR-0001](../../../docs/adr/0001-living-claims-wire-format.md)), e.g. `C-001` |
| `parent` | no | At most **one** other claim `id`. Omit when there is no parent. |
| `plane` | yes | Closed set **`P3` → `P2` → `P1` → `P0`** only. Do not invent `P4`, `P-1`, or open-ended planes. |
| `status` | yes | `changed` \| `adjusted` only |

**One parent max.** Do not write two `parent=` keys. Do not list children on the parent line.

**Status** is *not* [status-taxonomy.md](status-taxonomy.md) (feature/doc maturity: `Real`, `Planned`, …). Breadcrumb status is only:

| Token | Meaning |
|-------|---------|
| `changed` | The anchored claim/code surface itself changed |
| `adjusted` | Adapted to a parent or plane shift without a primary rewrite |

Do not extend this pair unless a later ADR says so.

Place the line immediately above `anchor.symbol` when present; otherwise near the `anchor.path` evidence. Do not campaign a full-tree rewrite of existing comments.

### Examples

**TypeScript / JS**

```ts
// @claim id=C-001 parent=C-000 plane=P1 status=changed
export function checkout() {}
```

**Python**

```python
# @claim id=C-001 parent=C-000 plane=P1 status=adjusted
def checkout():
    ...
```

**Go**

```go
// @claim id=C-001 parent=C-000 plane=P1 status=changed
func Checkout() {}
```

**Shell**

```bash
# @claim id=C-010 plane=P0 status=changed
checkout() { :; }
```

(Shell example omits `parent` — no parent.)

### Non-goals (this section)

Convention only. Do **not** implement here: cascade engine (verdicts: [modes.md §6.7](modes.md#67-cascade-verdicts-haken)), reconcile classification (procedure: [modes.md §6.8](modes.md#68-reconcile-classification-plansmds)), recommend-review engine (audience: [modes.md §6.9](modes.md#69-recommend-review-human-vs-agent)), breadcrumb parsers, or CI that fails on missing comments. `audit-claims.sh` default remains the **matrix gate**; `--list-changed` is the change-set helper only.

## Non-goals (v0)

- SaaS / control-plane / org merge policy engines  
- Formal proof / SMT  
- Auto-commit; inventing implementation to match docs  
- Replacing Notion/MkDocs  
- Cascade engine / reconcile classification ([modes.md §6.8](modes.md#68-reconcile-classification-plansmds)) / recommend-review engine ([modes.md §6.9](modes.md#69-recommend-review-human-vs-agent)) / breadcrumb parsers (comment convention only)

## Concept anchors (greppable)

`living claims` · `living-claims` · `anchor.path` · `severity` · `critical Contradicted` · `truth score` · `audit-claims` · `docs-audit` · `@claim` · `breadcrumb` · `plane` · `changed` · `adjusted` · `diff-first` · `--list-changed` · `recommend review` · `whole matrix`

## Related

- Modes: [modes.md §6](modes.md#6-audit-project-or-feature) · [§6.7](modes.md#67-cascade-verdicts-haken) · [§6.8](modes.md#68-reconcile-classification-plansmds) · [§6.9](modes.md#69-recommend-review-human-vs-agent) · [§13](modes.md#13-living-claims--ci-structural-audit-v25)  
- Quality: [quality-checklist.md](quality-checklist.md)  
- Feature pack: [docs/features/living-claims/README.md](../../../docs/features/living-claims/README.md)  
- Epic: [docs/plans/knowledge-os/README.md](../../../docs/plans/knowledge-os/README.md)  
- Captain lock: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)  
