# Implementation bridge (Feature autopilot v2 / v1.5)

**Stage B** after plan or feature-pack docs. **Docs remain Stage A authority.**  
This bridge never invents production APIs as facts — every path/signature is a **hypothesis** until code exists and audit says OK.

## When to run

| Signal | Run bridge? |
|--------|-------------|
| User only: “nueva feature X” / “documentá X” / plan | **No** — Stage A only (docs). In summary, one line: *“Say implement / stubs to open Implementation bridge.”* |
| “implementá”, “generá stubs”, “scaffold”, “start coding X”, “también el código” | **Yes** — after plan/pack written or updated |
| Promote plan → pack when code **already** real | Prefer real code over stubs; bridge optional for remaining gaps |
| User said “solo docs” / “no code” | **Never** |

Default **product code non-write** unless opt-in above. Still **no auto-commit**.

## Announce

```text
Implementation bridge: off | on (stubs=opt-in) | placement-only
ArkGate placement: none | layer-aware (<layers>)
```

## Steps

1. Ensure Stage A exists: `docs/plans/<slug>/` and/or `docs/features/<slug>/`.
2. Fill **Implementation bridge** section in that doc (template below) — or sibling `implementation.md` only if the section would dominate the README (>~40 lines of placement detail).
3. **Placement**
   - If ArkGate detected ([arkgate-bridge.md](arkgate-bridge.md)): map proposed dirs to **layer globs** from `ark.config.json`. Prefer `/ark-place` / contract layers when those skills exist — do not reimplement Ark.
   - Else: infer from repo conventions (`src/`, `app/`, packages) and mark **TBD** where unsure.
4. **Stub policy (opt-in only)**
   - List files to create with status `hypothesis`.
   - If user asked to write stubs: create minimal skeletons only; every export/route marked `// TODO: hypothesis — not SSOT` or language equivalent.
   - Do **not** claim routes/tables exist in the feature pack Public surface as Real — use Planned / TBD.
5. **Acceptance → engineering checklist** — copy plan acceptance criteria into checkboxes linked to placement rows.
6. Summary: files written (docs vs code), non-writes, that stubs are hypotheses.

## Template block (paste into plan or feature README)

```markdown
## Implementation bridge

> **Opt-in / hypothesis.** Not SSOT until code lands and audit is OK.  
> Stubs written: no | yes (user opt-in)

### Placement

| Area | Proposed path | Layer (Ark or convention) | Status |
|------|---------------|---------------------------|--------|
| Entry | `TBD` | TBD | hypothesis |
| Core | `TBD` | TBD | hypothesis |
| Tests | `TBD` | TBD | hypothesis |

### Engineering checklist

- [ ] …
- [ ] …

### Stub inventory (only if user opted in)

| Path | Purpose | Written? |
|------|---------|----------|
| | | no |

### Anti-hallucination

- No endpoint/table/ModuleId listed as **Real** without code evidence.
- Public surface rows stay TBD/Planned until promote or code-backed refresh.
```

## Kind refinement (decision tree v2)

Use with modes §3.1 — set plan **Kind** (and optional hub note):

| Kind | Signals | Docs shape |
|------|---------|------------|
| **spike** | “spike”, “explore”, “timebox”, “prove” | Short plan; heavy Open questions; bridge usually placement-only |
| **new feature** | default “nueva feature” | Full plan template MVP |
| **epic** | “epic”, multi-module, multi-quarter | Epic plan + child plans/slugs; no single mega-pack |
| **redesign** | “redesign”, “replace”, “migrate off” | Plan + link existing feature pack; dual-status notes |

## Promote checklist (explicit)

When code is real (“promové el plan” / implementation landed):

1. [ ] Code inventory for slug (paths, routes, tests) — **code wins**
2. [ ] Create/update `docs/features/<slug>/` from [feature-readme-template.md](feature-readme-template.md)
3. [ ] Acceptance criteria re-checked against code (not against stubs)
4. [ ] Implementation bridge: mark stubs superseded or delete inventory rows that diverged
5. [ ] Plan status → `Shipped` or `Superseded` + link pack
6. [ ] Hub: Features primary; Plans historical
7. [ ] Surface coverage row → documented
8. [ ] Optional: scoped audit on new claims

## Status tokens for stub-only work

| Situation | Prefer |
|-----------|--------|
| Docs + no code | plan `Planned` / feature pack only if refreshing — else stay on plan |
| Stubs written, no real behavior | `Planned` or `In progress` (not `Real`) |
| Partial real code | `Partial` |
| Happy path real | `Real` / `Shipped` per [status-taxonomy.md](status-taxonomy.md) |
