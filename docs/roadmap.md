# Roadmap — documentation-manager

> Hub: [AGENTS.md](../AGENTS.md) · Planes: [docs/plans/](./plans/)  
> **Producto:** Agent Skill (knowledge base viva, agent-first). No es una app de producto genérica.  
> **Última actualización:** 2026-09-08 · **Versión actual:** 2.5.6

## Principios (axiomas)

1. La documentación es una **extensión viva del código**, no un artefacto que se pudre.
2. Los agentes necesitan **contexto confiable** → axioma **code wins** + audit + narrativa.
3. El costo de mantener docs debe **tender a cero** (autopilot, integrate-first, minimal asks).
4. Valor ≈ **precisión × adopción × facilidad de uso × inteligencia evolutiva**.
5. Escala real = convertirse en el **sistema operativo de conocimiento** del proyecto (no solo una skill suelta).

## Norte estratégico

| Horizonte | Objetivo | Resultado esperado |
|-----------|----------|--------------------|
| **Ahora (v1.3)** | Skill mínima, honesta, agent-first | Plan/feature autopilot; code wins; intents claros |
| **10× (v2.0)** | Estándar **invisible y automático** en repos AI-first | Adopción ×10, fricción ÷10, docs que se auto-mantienen |
| **Bridge** | Polyglot + governance + mejora continua básica | Listo para equipos y monorepos |
| **100× (Knowledge OS)** | Fuente única de verdad narrativa para agentes y humanos | Living claims, org-level, marketplace, standard nativo |

**Complemento ArkGate:** ArkGate gobierna el *código*; Documentation Manager gobierna la *narrativa*. Juntos: código gobernado + docs honestas.

## Estado actual (baseline)

| Área | Estado | Notas |
|------|--------|-------|
| Skill core (`SKILL.md` + modes) | **Shipped** (**v2.5.0**) | Bridge complete + Knowledge OS first increment |
| Feature autopilot + plan mode | **Shipped** (v1.3 → **v2 / 1.5**) | Kind + Implementation bridge opt-in |
| Templates + quality bar | **Shipped** | + skill-discovery |
| Install (`npx skills` / `install.sh`) | **Shipped** | Idempotente; dashboard script shipped |
| Validación | **Shipped** (hardening) | fixtures + golden + version sync |
| Bridge ArkGate | **Shipped** (v1.4) | [feature pack](./features/arkgate-bridge/README.md) |
| Dashboard HTML | **Shipped** (v1.6) | [feature](./features/knowledge-dashboard/README.md) |
| Adoption matrix | **Shipped** (v2.0) | [adoption-matrix.md](./adoption-matrix.md) |
| Bridge (polyglot / monorepo / team / telemetry) | **Shipped** (Fase 2) | [phase-2-bridge](./plans/phase-2-bridge/README.md) · A–D complete |
| Living claims + CI structural audit | **Shipped** (v2.5.0) | [living-claims](./features/living-claims/README.md) — first KOS increment |
| Go/no-go Gate A/B trail | **Shipped** (v2.5.4) | [go-nogo](./features/go-nogo/README.md) — ops/TO-BE; not living-claims CI |
| Polyglot / multi-repo / SaaS (org + OS) | **Planned** (resto del horizonte 100×) | [knowledge-os](./plans/knowledge-os/README.md) |

## Fases

### Fase 0 — Consolidar v1.3 (ahora)

**Meta:** base sólida, dogfood del propio repo, cero deuda de packaging.

- [x] Feature autopilot + plan mode
- [x] Intents integrate / audit / from-zero
- [x] Templates y quality checklist
- [x] Meta-docs de este paquete (este roadmap + planes)
- [x] Dogfood: validate + hardening + install-smoke gates
- [x] Matriz de adopción ([adoption-matrix.md](./adoption-matrix.md))

### Fase 1 — 10× / v2.0 — **COMPLETE**

**Meta:** de “herramienta útil al pedirla” a “siempre presente y proactiva”.  
**Shipped as skill v2.0.0** (2026-07-15). Pack: [features/tenx-v2-release](./features/tenx-v2-release/README.md).

| # | Epic / plan | Prioridad | Semanas (orientativo) | Estado |
|---|-------------|-----------|------------------------|--------|
| 1 | [ArkGate bridge](./plans/arkgate-bridge/README.md) → [feature](./features/arkgate-bridge/README.md) | P0 | 1–2 | **Shipped** (v1.4.0) |
| 2 | [Feature autopilot 2.0](./plans/feature-autopilot-v2/README.md) → [feature](./features/feature-autopilot-v2/README.md) | P0 | 3–4 | **Shipped** (v1.5.0) |
| 3 | [Knowledge dashboard (HTML)](./plans/knowledge-dashboard/README.md) → [feature](./features/knowledge-dashboard/README.md) | P1 | 3–4 | **Shipped** (v1.6.0) |
| 4 | [Skill hardening](./plans/skill-hardening/README.md) → [feature](./features/skill-hardening/README.md) | P1 | 5–6 | **Shipped** (v1.7.0) |
| 5 | Publicar **v2.0** + adoption matrix | P0 | fin fase | **Shipped** (v2.0.0) |

**Métricas de éxito 10× (packaging vs claim):**

| Métrica | Baseline (v1.3) | v2.0 delivered | Note |
|---------|-----------------|----------------|------|
| Fricción “instalar + pedir” | Manual | Discovery + install docs + matrix | Runtime ×10 still adoption work |
| Precisión de claims post-cambio | Manual audit only | Audit + ArkGate bridge procedure | Exercise on consumer repos |
| Adopción (repos / installs) | Baja, early | Matrix + channels listed | Update rows when verified |
| Suite de tests de skill | Smoke estructural | Fixtures + golden + smoke | `validate-skill.sh` |

<a id="fase-2-bridge"></a>

### Fase 2 — Bridge (≈ 2–4 meses post-v2) — **COMPLETE**

**Meta:** salir del nicho “un repo TS AI-first”.  
**Plan formal:** [docs/plans/phase-2-bridge/](./plans/phase-2-bridge/README.md) (umbrella) — **Shipped** as skill **v2.4.0**.  
**Parent next:** [knowledge-os](./plans/knowledge-os/README.md) (Fase 3).

| # | Slice | Prioridad | Hyp. version | Estado |
|---|-------|-----------|--------------|--------|
| A | [Polyglot MVP](./plans/phase-2-bridge/README.md) → [feature](./features/polyglot-mvp/README.md) | P0 | 2.1.0 | **Shipped** (v2.1.0) |
| B | [Monorepo hubs](./plans/phase-2-bridge/README.md) → [feature](./features/monorepo-hubs/README.md) | P0 | 2.2.0 | **Shipped** (v2.2.0) |
| C | [Team governance](./plans/phase-2-bridge/README.md) → [feature](./features/team-governance/README.md) | P1 | 2.3.0 | **Shipped** (v2.3.0) |
| D | [Template telemetry](./plans/phase-2-bridge/README.md) → [feature](./features/template-telemetry/README.md) | P1 | 2.4.0 | **Shipped** (v2.4.0) |

**Gate de salida Fase 2:** epic AC A–D shipped + validate verde + core local sin red — **met** (2026-07-17).

<a id="fase-3-knowledge-os"></a>

### Fase 3 — 100× Knowledge OS (≈ 4–12 meses)

**Meta:** sistema operativo de conocimiento AI-native.  
**First increment (shipped as skill v2.5.0):** living claims v0 + local/air-gapped CI structural audit — **toward** 100×, not a full OS leap. Pack: [features/living-claims](./features/living-claims/README.md).

| Capacidad | Descripción | Dependencias | Estado |
|-----------|-------------|--------------|--------|
| Living claims + truth score | Hash/código ↔ claim; CI audit | Fase 1 audit + CI hooks | **First increment** (v2.5.0) |
| Org-level hub | Políticas centrales, sync multi-repo | Bridge multi-repo | Planned |
| SaaS control-plane (opcional) | Dashboard web, search semántico, Linear/Jira | Core local siempre free | Planned (non-goal for core) |
| Native agent standard | Built-in / MCP registry / “documentation mode” | Adopción + ecosistema | Planned |
| Marketplace de knowledge packs | Presets por dominio (SaaS, fintech, AI) | Templates estables | Planned |
| Meta-architect | Anti-patterns de docs a escala | Telemetría opt-in | Planned |

Ver plan: [knowledge-os](./plans/knowledge-os/README.md).

## Priorización (primeros principios)

```text
Impacto en “code wins + zero maintenance cost”
  1. ArkGate bridge (cierra el loop código ↔ narrativa)
  2. Autopilot 2.0 (baja fricción del día a día)
  3. Validación / tests (confianza al evolucionar SKILL.md)
  4. Dashboard (adopción humana + navegación)
  5. Discovery / install (distribución)
  6. Governance / polyglot / SaaS (escala, no MVP)
```

## Non-goals (explícitos)

| No haremos (aún) | Por qué |
|------------------|---------|
| Reemplazar MkDocs / Docusaurus / Notion | Integrate-first; no guerra de wikis |
| Auto-commit / auto-push | El usuario controla git |
| Generar “docs infinitas” | Minimal viable narrative + quality bar |
| SaaS obligatorio | Core local/shell; SaaS opcional y opt-in |
| Debilitar “code wins” por telemetría o UI | El axioma no se negocia |

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| SKILL.md monolítico, difícil de testear | Extracción gradual + fixtures de modes (skill-hardening) |
| Over-documentation | Quality bar + anti-snapshot + integrate-first |
| Privacidad (telemetría / SaaS) | Opt-in, anonymized, air-gapped enterprise |
| Dependencia de un host de agentes | Contratos estables SKILL.md + MCP cuando exista |
| Competencia (Mintlify, Swimm, Notion) | Diferenciador: code wins + ArkGate + agent-native |

## Releases (hipótesis)

| Release | Contiene | Gate de salida |
|---------|----------|----------------|
| **1.3.x** | Fixes, meta-docs, dogfood | validate + smoke verdes |
| **1.4** | Bridge ArkGate MVP (procedure + post-gate sync/audit) | **Shipped** 2026-07-15 |
| **1.5** | Autopilot 2.0 (Kind + Implementation bridge; stubs opt-in) | **Shipped** 2026-07-15 |
| **1.6** | Knowledge dashboard HTML opcional | **Shipped** 2026-07-15 |
| **1.7** | Skill hardening (fixtures, discovery) | **Shipped** 2026-07-15 |
| **2.0** | 10× package: matrix + CHANGELOG + rollup of 1.4–1.7 | **Shipped** 2026-07-15 |
| **2.1** | Polyglot MVP (Slice A) | **Shipped** 2026-07-17 — [polyglot-mvp](./features/polyglot-mvp/README.md) |
| **2.2** | Monorepo hubs (Slice B) | **Shipped** 2026-07-17 — [monorepo-hubs](./features/monorepo-hubs/README.md) |
| **2.3** | Team governance (Slice C) | **Shipped** 2026-07-17 — [team-governance](./features/team-governance/README.md) |
| **2.4** | Template telemetry (Slice D) + Fase 2 Bridge complete | **Shipped** 2026-07-17 — [template-telemetry](./features/template-telemetry/README.md) |
| **2.5** | Knowledge OS **first increment** (living claims v0 + local CI audit) | **Shipped** 2026-08-30 — [living-claims](./features/living-claims/README.md); toward 100×, not a second 10× |
| **2.5.6** | P1 §2 Mínimo pack (propose + presence audit) | **Shipped** 2026-09-08 — [modes.md §16](../skills/documentation-manager/references/modes.md#16-product-domain-minimo); not a KOS leap |

## Cómo usar este roadmap

1. Trabajo **neto nuevo** → plan en [`docs/plans/<slug>/`](./plans/) y una fila aquí.
2. Cuando haya **código o comportamiento de skill real** → promover a `docs/features/<slug>/` (o sección en SKILL/references).
3. No reescribir este archivo entero por cada issue; actualizar filas de estado y links.

## Related

- Análisis de origen: conversación 2026-07-15 (v1.3.0 full project analysis)
- Planes activos: [docs/plans/](./plans/)
- Skill SSOT de comportamiento: [skills/documentation-manager/SKILL.md](../skills/documentation-manager/SKILL.md)
- Publicación: [PUBLISH.md](../PUBLISH.md)
