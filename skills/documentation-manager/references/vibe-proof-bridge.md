# Vibe-proof-auditor bridge (v2.5.15)

**Sensor, not fusion.** Documentation Manager may **propose** (HITL) or, on an explicit mandate, **call** the sibling skill [vibe-proof-auditor](https://github.com/pedroknigge/vibe-proof-auditor). It does **not** embed that auditor’s checklist, scoring, or gates, and it does **not** merge the two products.

Shared axioms: **human captain** · **Missing stays Missing** · **no greenwash** · **dual-plane intact** · **no silent auto-run**.

## 1. Detection (sibling, opt-in)

Run when **plan mode** is active (or the user just named a plan and a mandate/flag).

| Signal | How to detect | Confidence |
|--------|---------------|------------|
| Host skill | Skill named `vibe-proof-auditor` / `/vibe-proof-auditor` | high |
| Session | User said “vibe-proof”, “vibe-proof-auditor” | high (session) |
| Mandate phrases (plan already chosen) | “close gaps”, “listo para prod”, “asegurá huecos” | high (session) |

**If the sibling is not installed:** one friendly hint + link. Do **not** install it for them. Do **not** invent scores. The offer may still be asked (captain can install later); the **call** is a no-op until the skill is present.

**Announce when the bridge is in play:**

```text
Vibe-proof: n/a | skip:<no-code|strong-arch|declined|absent> | HITL | mandate | folded
```

## 2. Offer gates (closed — do not reopen)

Evaluate **before** any propose or call. Order is fail-closed.

| Gate | Offer / call? | How to know (no greenwash) |
|------|---------------|----------------------------|
| **no executable contract** | **Skip** | No meaningful product/skill code (no `src/` / stack sources / scripts+tests that vibe-proof would treat as `skill/docs`). Docs-only trees stay skipped. |
| **Strong living architecture** | **Skip** | Proven with **pointers** — see §3. File existence is **not** enough. |
| Auditable code **and** architecture **weak/absent** | **Offer** (default HITL) or **mandate** | Code inventory found real surfaces; architecture authority missing, stub, TBD-only, or not living. |
| Ordinary “nueva feature X” / plan with **no** mandate | **HITL propose once** if the two offer rows above pass; else skip | Never auto-run. |
| Mandate / flag while gates pass | **Internal call** (no second ask) | Still **announce**. Still not silent. |

Unclear whether architecture is strong → **not** strong. Offer if code exists. Do **not** invent “strong” to look decisive.

## 3. Strong living architecture (pointers only)

**strong living architecture** only if you can **point** to **all** of:

1. An **adopted** architecture authority (hub-linked `docs/architecture.md`, CapCase `docs/Architecture.md`, or the captain’s evolved home). Never force a filename.
2. It names **real** code surfaces (paths / packages / modules that **exist** in the tree) — not `src/…` placeholders, not `YYYY-MM-DD` leftovers.
3. It is **not** a stub (more than a title + empty tables).
4. If a claims matrix already has architecture rows: none are **Contradicted**, and architecture claims are not **Missing**.

If you cannot point to those evidences, architecture is **weak/absent**. **Missing stays Missing.** Do not announce “strong architecture” without pointers.

## 4. HITL propose (default)

**When:** plan mode · offer gates pass · **no** mandate/flag.

**Once**, after Stage A plan write (or refresh), ask in a friendly voice (Spanish/English mix OK):

> Hay código auditable y la arquitectura documentada está floja o ausente. ¿Corro vibe-proof-auditor y pliego los findings en acceptance / MVP / next actions del plan?

That is the **vibe-proof HITL propose**. Captain **no** / silent decline → `skip:declined`; do not ask again this session. Captain **yes** → §6.

Do **not** run the sibling while waiting.

## 5. Internal call (mandate / flag only)

Skip the extra question **only** when the user already gave an explicit mandate or flag **in this plan session**:

| Kind | Examples |
|------|----------|
| Mandate | “close gaps”, “listo para prod”, “asegurá huecos” |
| Flag | “vibe-proof”, “run vibe-proof”, “with vibe-proof-auditor” |

These phrases do **not** steal a standalone “listo para prod” that was meant for the sibling alone (no plan / no docs-plan intent). This skill stays the **docs** owner; vibe-proof stays the **auditor**.

Still announce `Vibe-proof: mandate` before the call.

## 6. Call + fold (not a second SSOT)

1. Load the sibling `SKILL.md` and follow **its** workflow. Do not copy checklist/scoring/gates into this skill.
2. Prefer **quick** / “rápido” unless the captain asked for Deep.
3. Read Findings + prioritized P0–P1 remediation. **Do not** paste the full report into the plan.
4. Fold into the plan’s existing **Acceptance criteria**, **MVP scope**, and **Next actions** so a cold agent can recover them from the file alone (`id` + path + note). Apply [modes.md §19](modes.md#19-cold-agent-readable).
5. Optional one-line pointer to `vibe-proof-audit-report.md` if the sibling wrote it — **pointer**, not a second living SSOT.
6. Dual-plane: code/evidence findings are **AS-IS**; plan rows are **TO-BE**. Do not rewrite code identity to match a dunk. Do not invent a Sí or a green OK.
7. Sibling missing after a **yes** / mandate → `skip:absent`; hint once; leave gaps as **Missing**.

Default **non-writes**: product-vision, requirements, unrelated ADRs/packs, `ark.config.json`, app source, the sibling’s scoring files. No auto-commit.

## 7. Pairing guidance (for agents)

```text
plan mode (docs)
  → offer gates (§2)
  → HITL propose (§4)  or  mandate (§5)
  → vibe-proof-auditor (sibling)
  → fold into plan Acceptance / MVP / Next actions
  → user commits
```

- ArkGate stays the **architecture-contract** sibling ([arkgate-bridge.md](arkgate-bridge.md)). This bridge does **not** replace it and does **not** touch Ark ports.
- Do **not** run vibe-proof harden / `agy` unless the captain asked that sibling for hardening.

## 8. Dogfood note (origin vs host)

| Where you are | What is true |
|---------------|----------------|
| **Origin package** (`pedroknigge/documentation-manager`) | Ships Documentation Manager. Do not invent a product app. Do **not** auto-run vibe-proof on every meta plan. |
| **Host / consumer** | If that tree has auditable code and weak/absent architecture, the bridge **does** apply in plan mode. |

Code and the gates (§2–§3) win.
