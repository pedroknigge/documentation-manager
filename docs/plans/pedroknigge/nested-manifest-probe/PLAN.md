# Plan: Bounded nested manifest probe (#56)

> **Plan (not SSOT).** Captain chose **Approach A** (2026-11). Do not reopen B/C without HITL.  
> Hub: [AGENTS.md](../../../../AGENTS.md) · Issue: [#56](https://github.com/pedroknigge/documentation-manager/issues/56)  
> **Cold-agent readable:** intent, gate, multi-manifest rule, and acceptance live here.  
> **Implementation** targets skill **2.5.25**. No tag from the PR branch.

**Status:** In progress  
**Slug:** `nested-manifest-probe`  
**Owners:** Pedro (captain) · skill maintainers  
**Last updated:** 2026-11-10  
**Code path:** [`scripts/detect-stack.sh`](../../../../scripts/detect-stack.sh) · [`scripts/detect-packages.sh`](../../../../scripts/detect-packages.sh) · shared [`scripts/lib/nested-manifest-probe.sh`](../../../../scripts/lib/nested-manifest-probe.sh)

## Problem

Repos with **no root** `package.json` / workspace file and **only** a nested Node package (e.g. `tools/<pkg>/package.json`) get `unknown` from `detect-stack.sh` and empty stdout from `detect-packages.sh`. Agents mis-label the stack and miss the lone package path.

## Approach A (locked)

**When:** Root has **no** primary manifest and **no** workspace file (see gate below).  
**Then:** Bounded filesystem probe — max **depth 2** below repo root — for package manifests used by the polyglot MVP detectors.

**Skip directory basenames** while walking (not exhaustive tree walk):  
`node_modules`, `vendor`, `dist`, `build`, `coverage`, `fixtures`, `templates`, `template`, `.git`, `__pycache__`, `.venv`, `venv`.

**Positive manifest files** (same family as root stack signals, at the package directory):

| Token | File(s) in probed dir |
|-------|------------------------|
| `node-ts` | `package.json` |
| `python` | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile` |
| `go` | `go.mod` |

Nested `Cargo.toml` alone does **not** add an MVP token (rust stays non-MVP). Root `Cargo.toml` / toolchain rules unchanged (#45).

### Root gate (no probe when any of these)

- `package.json`, `pnpm-workspace.yaml`, `go.mod`, `go.work`, `Cargo.toml`
- `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`
- Root `tsconfig.json` (existing Slice A signal — unchanged)
- `rust-toolchain` / `rust-toolchain.toml` at root

## Interface that gets simpler

**Callers** (`detect-stack.sh`, `detect-packages.sh`, agents reading stdout) keep the same contract: space-separated stack tokens or one package path per line. No new flags, env vars, or tokens.

**Hidden complexity** (in `nested-manifest-probe.sh`):

- Root gate vs existing cargo / workspace / strong-node rules
- Depth-bounded walk with skip list
- Deterministic ordering when multiple nested roots exist

## Multiple nested manifests (deterministic)

1. Collect every probed directory that contains a qualifying manifest (depth ≤ 2).
2. Sort paths **lexicographically** (`LC_ALL=C`).
3. **`detect-packages.sh`:** print **all** sorted paths (one per line).
4. **`detect-stack.sh`:** derive MVP tokens from the **set** of manifest kinds found across those paths; emit tokens in fixed order `node-ts`, `python`, `go` (same as multi-root today). Two languages → space-separated tokens (announce `mixed`). Do **not** print a `mixed` token string.

No “pick one arbitrary package” for stack when several exist — language set is the union of nested manifests.

## Non-goals

- Depth &gt; 2, full-repo `find`, or respecting `.gitignore`
- Treating nested `Cargo.toml` as stack primary
- Changing cargo-primary (#45), `go.work` (#51), or root-manifest fixtures
- Installing probe helpers into consumer repos (lib stays dev/scripts only; both detectors `source` it)

## Acceptance

- Fixture `scripts/fixtures/nested-node-tools/` — only `tools/<pkg>/package.json`, no root manifest
- `scripts/test-skill-hardening.sh` asserts `node-ts` + package path `tools/<pkg>`
- Existing cargo-primary and go-workspace fixtures unchanged
- `./scripts/validate-skill.sh` passes
- Skill **2.5.25** bump: `SKILL.md` prefix + metadata, `CHANGELOG`, README badge only

## Verifiable next actions

1. Add `scripts/lib/nested-manifest-probe.sh` + wire both detectors  
2. Add fixture + hardening asserts  
3. Short note in [skill-discovery.md](../../../../skills/documentation-manager/references/skill-discovery.md) Polyglot / Monorepo sections  
4. Version 2.5.25 + validate
