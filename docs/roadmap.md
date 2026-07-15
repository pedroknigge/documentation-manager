# Roadmap — documentation-manager

> Hub: [AGENTS.md](../AGENTS.md) · Planes: [docs/plans/](./plans/)  
> **Producto:** Agent Skill (knowledge base viva, agent-first). No es una app de producto genérica.  
> **Última actualización:** 2026-07-15 · **Versión actual:** 1.7.0

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
| Skill core (`SKILL.md` + modes) | **Shipped** (v1.7.0) | + hardening + discovery |
| Feature autopilot + plan mode | **Shipped** (v1.3 → **v2 / 1.5**) | Kind + Implementation bridge opt-in |
| Templates + quality bar | **Shipped** | + skill-discovery |
| Install (`npx skills` / `install.sh`) | **Shipped** | Idempotente; dashboard script shipped |
| Validación | **Shipped** (hardening) | fixtures + golden + version sync |
| Bridge ArkGate | **Shipped** (v1.4) | [feature pack](./features/arkgate-bridge/README.md) |
| Dashboard HTML | **Shipped** (v1.6) | [feature](./features/knowledge-dashboard/README.md) |
| Polyglot / multi-repo / SaaS | **Planned** (horizonte 100×) | Ver [knowledge-os](./plans/knowledge-os/README.md) |

## Fases

### Fase 0 — Consolidar v1.3 (ahora)

**Meta:** base sólida, dogfood del propio repo, cero deuda de packaging.

- [x] Feature autopilot + plan mode
- [x] Intents integrate / audit / from-zero
- [x] Templates y quality checklist
- [x] Meta-docs de este paquete (este roadmap + planes)
- [ ] Dogfood: audit del skill tree vs README/PUBLISH
- [ ] Matriz de adopción (repos públicos + pareja ArkGate)

### Fase 1 — 10× / v2.0 (≈ 1–2 meses)

**Meta:** de “herramienta útil al pedirla” a “siempre presente y proactiva”.

| # | Epic / plan | Prioridad | Semanas (orientativo) | Estado |
|---|-------------|-----------|------------------------|--------|
| 1 | [ArkGate bridge](./plans/arkgate-bridge/README.md) → [feature](./features/arkgate-bridge/README.md) | P0 | 1–2 | **Shipped** (v1.4.0) |
| 2 | [Feature autopilot 2.0](./plans/feature-autopilot-v2/README.md) → [feature](./features/feature-autopilot-v2/README.md) | P0 | 3–4 | **Shipped** (v1.5.0) |
| 3 | [Knowledge dashboard (HTML)](./plans/knowledge-dashboard/README.md) → [feature](./features/knowledge-dashboard/README.md) | P1 | 3–4 | **Shipped** (v1.6.0) |
| 4 | [Skill hardening](./plans/skill-hardening/README.md) → [feature](./features/skill-hardening/README.md) | P1 | 5–6 | **Shipped** (v1.7.0) |
| 5 | Publicar **v2.0** + adoption matrix | P0 | fin fase | Planned · **next** |

**Métricas de éxito 10×:**

| Métrica | Baseline (v1.3) | Objetivo v2 |
|---------|-----------------|-------------|
| Fricción “instalar + pedir” | Manual | Auto-trigger / discovery |
| Precisión de claims post-cambio | Manual audit | Audit/sync tras gate o PR |
| Adopción (repos / installs) | Baja, early | ×10 vía ArkGate + docs |
| Suite de tests de skill | Smoke estructural | Fixtures + regresión de modes |

### Fase 2 — Bridge (≈ 2–4 meses post-v2)

**Meta:** salir del nicho “un repo TS AI-first”.

- Polyglot MVP (Python, Go, …) — detección de stack + layouts por lenguaje
- Monorepo: hubs por package + índice raíz
- Governance / team mode (`docs/team/`, approvals ligeros)
- Self-improving básico: telemetría **opt-in** anónima de gaps de templates
- Detalle en [knowledge-os](./plans/knowledge-os/README.md) (tramo bridge)

### Fase 3 — 100× Knowledge OS (≈ 4–12 meses)

**Meta:** sistema operativo de conocimiento AI-native.

| Capacidad | Descripción | Dependencias |
|-----------|-------------|--------------|
| Living claims + truth score | Hash/código ↔ claim; CI audit | Fase 1 audit + CI hooks |
| Org-level hub | Políticas centrales, sync multi-repo | Bridge multi-repo |
| SaaS control-plane (opcional) | Dashboard web, search semántico, Linear/Jira | Core local siempre free |
| Native agent standard | Built-in / MCP registry / “documentation mode” | Adopción + ecosistema |
| Marketplace de knowledge packs | Presets por dominio (SaaS, fintech, AI) | Templates estables |
| Meta-architect | Anti-patterns de docs a escala | Telemetría opt-in |

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
| **2.0** | Adoption matrix + release packaging | next |
| **2.0** | Hardening + discovery + suite tests + adoption matrix | “10× checklist” completa |

## Cómo usar este roadmap

1. Trabajo **neto nuevo** → plan en [`docs/plans/<slug>/`](./plans/) y una fila aquí.
2. Cuando haya **código o comportamiento de skill real** → promover a `docs/features/<slug>/` (o sección en SKILL/references).
3. No reescribir este archivo entero por cada issue; actualizar filas de estado y links.

## Related

- Análisis de origen: conversación 2026-07-15 (v1.3.0 full project analysis)
- Planes activos: [docs/plans/](./plans/)
- Skill SSOT de comportamiento: [skills/documentation-manager/SKILL.md](../skills/documentation-manager/SKILL.md)
- Publicación: [PUBLISH.md](../PUBLISH.md)
