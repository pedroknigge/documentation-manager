# Pstack plan bridge (v2.5.19)

**Sensor, not fusion.** Documentation Manager **bakes** a portable pstack-inspired design rule set into **plan mode** (always-on; no plugin required). When host skills named `architect` / `figure-it-out` / a pstack plugin are present, it may **propose** (HITL) a live `/architect` or `/figure-it-out` run **with checkpoint**, then fold findings into the plan. It does **not** vendor pstack, copy those skill bodies, or merge the products.

Shared axioms: **human captain** · **Missing stays Missing** · **no greenwash** · **dual-plane intact** · **no silent auto-run** · **cold-agent readable** ([modes.md §19](modes.md#19-cold-agent-readable)).

## 1. Bake (always-on, portable)

When plan mode **writes or refreshes** a plan, apply these rules *inside this skill* so hosts without the pstack plugin still get them:

| Rule | What to write in the plan |
|------|---------------------------|
| **Subtract before add** | What **not** to build; what to **delete first** (Non-goals / MVP out / Open questions). |
| **Attack the premise** | When scope is **fuzzy** or **prior fixes failed**, question the request before adding surface (Open questions). |
| **Falsifiable acceptance** | Acceptance rows are **prove-it predicates** a cold agent can check — not vibes. |
| **Verifiable next actions** | Each next action is an **independently verifiable unit** (not a chat leftover). |
| **One-way doors** | At least **two structurally distinct** approaches in **Open questions** / **Approach** (or HITL). Whole-shape alternatives, not point tweaks. |
| **Experience / outcome first** | Outcome and user experience beat implementation convenience. |

Do **not** copy pstack skill bodies. This table is the portable rule set for cold-agent plans. [§19](modes.md#19-cold-agent-readable) stays binding: intent, success, non-goals, and next actions recover from the file alone.

## 2. Detection (sibling, live path)

Run the **live** path when **plan mode** is active (write or refresh) **and** a pstack-family skill is on the host.

| Signal | How to detect | Confidence |
|--------|---------------|------------|
| Host skill | Skill named `architect` / `/architect` | high |
| Host skill | Skill named `figure-it-out` / `/figure-it-out` | high |
| Host plugin | pstack plugin / `setup-pstack` / poteto pstack | high |
| Session | User said “pstack”, “/architect”, “/figure-it-out” | high (session) |

**If the sibling is not installed:** bake still applies. Live path → `skip:absent` + one friendly hint. Do **not** install it for them. Do **not** invent a design dump. The captain can install later.

**Announce when plan mode is in play:**

```text
Pstack: n/a | skip:absent|declined | HITL | folded
```

| Token | When |
|-------|------|
| `n/a` | Not plan write/refresh |
| `skip:absent` | No architect / figure-it-out / pstack plugin on the host |
| `skip:declined` | Captain said no (or silent decline) this session |
| `HITL` | One propose is out; waiting — **or** captain already said run (still not silent) |
| `folded` | Live findings folded into existing plan sections |

Bake has no separate token: it is **always-on** for plan write/refresh.

## 3. HITL propose (default when present)

**When:** plan mode · pstack-family skill **present** · no prior yes/decline this session.

**Once**, after Stage A plan write (or refresh), ask in a friendly voice (Spanish/English mix OK):

> Hay pstack (`/architect` / `/figure-it-out`) en el host. ¿Corro `/architect` (o `/figure-it-out` si el trabajo es grande y ambiguo) **with checkpoint** y pliego los findings en Acceptance / MVP / Next actions / Open questions del plan?

That is the **pstack HITL propose**. Captain **no** / silent decline → `skip:declined`; do not ask again this session. Captain **yes** → §4.

Do **not** run the sibling while waiting. **no silent auto-run.**

**Which sibling (closed):**

| Work | Call (always **with checkpoint**) |
|------|-----------------------------------|
| Default / bounded design | `/architect` **with checkpoint** |
| Large ambiguous work, epic/migration, no narrower playbook, or prior fixes failed | `/figure-it-out` **with checkpoint** |

Always request **checkpoint**. Architect’s default is to proceed to implementation; this skill must not start that. Do not run arena / implement / fill-in unless the captain asked that sibling for that.

If the user already said “run `/architect`”, “run `/figure-it-out`”, or “with pstack” **in this plan session**, treat that as the captain’s yes — still announce `HITL`, still use checkpoint, still fold. That is not a silent auto-run.

## 4. Call + fold (not a second SSOT)

1. Load the sibling `SKILL.md` and follow **its** workflow. Do **not** copy skill bodies, runner prompts, or principle catalogs into this skill.
2. Pass **with checkpoint**. Pause for sign-off before any implement phase.
3. Read the synthesized design / framing / open tradeoffs. **Do not** paste the full sibling dump into the plan.
4. Fold into the plan’s existing **Acceptance criteria**, **MVP scope**, **Next actions**, and **Open questions** so a cold agent can recover them from the file alone (`id` + path + note). Apply [modes.md §19](modes.md#19-cold-agent-readable).
5. Dual-plane: sibling findings are **AS-IS**; plan rows are **TO-BE**. Do not invent a Sí or a green OK.
6. Sibling missing after a **yes** → `skip:absent`; hint once; bake still stands; leave live gaps as **Missing**.

Default **non-writes**: product-vision, requirements, unrelated ADRs/packs, `ark.config.json`, app source, pstack skill trees / model rules. No auto-commit. Do not vendor pstack into this repo.

## 5. Pairing guidance (for agents)

```text
plan mode (docs)
  → bake always (§1)
  → if pstack-family present: HITL propose (§3)
  → /architect or /figure-it-out **with checkpoint**
  → fold into plan Acceptance / MVP / Next actions / Open questions
  → user commits
```

- ArkGate stays the **architecture-contract** sibling ([arkgate-bridge.md](arkgate-bridge.md)). Vibe-proof stays the **auditor** sibling ([vibe-proof-bridge.md](vibe-proof-bridge.md)). This bridge does **not** replace either.
- Do **not** run pstack implement / arena / fill-in unless the captain asked that sibling for that.

## 6. Dogfood note (origin vs host)

| Where you are | What is true |
|---------------|----------------|
| **Origin package** (`pedroknigge/documentation-manager`) | Ships Documentation Manager. Bake applies to meta plans. Do **not** auto-run live pstack on every meta plan. |
| **Host / consumer** | Bake always on plan write/refresh. Live HITL when a pstack-family skill is present. |

Code and the bake table (§1) win. Cold-agent §19 wins over chat leftovers.
