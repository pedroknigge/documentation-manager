# Template telemetry (v2.4 Slice D)

**Opt-in, local-first** recording of **template / skill UX gaps** so maintainers can improve templates without profiling consumer product code.

**Default: off.** Air-gapped and zero-network always work. Network upload is **out of scope** for v2.4 (local ledger only).

## Privacy hard rules (non-negotiable)

| Rule | Requirement |
|------|-------------|
| **Default off** | No ledger write unless explicit opt-in |
| **Never-send** | No source code, secrets, env dumps, or identifiable repo URLs |
| **Template gaps only** | No product code fingerprinting, ModuleIds, routes, or file contents from the consumer app |
| **Air-gapped** | Skill fully usable with telemetry off; script never opens network sockets |
| **No silent opt-in** | Agents must not enable telemetry without user consent |

## Opt-in mechanisms

Any one of:

1. Environment: `DOCS_TELEMETRY_OPT_IN=1` (or `true` / `yes`)  
2. Flag file: path containing a single line `1` / `true` / `yes` (pass `--opt-in-file`)  
3. CLI: `--opt-in` on a single `record` invocation (still no network)

Without opt-in, `record` is a **no-op** (exit 0, no file created).

## Local ledger (shipped entry point)

Package script:

```bash
# Status (always safe; prints opt-in on|off)
./scripts/template-telemetry.sh status [--ledger PATH] [--opt-in-file PATH]

# Record a template-gap event (no-op unless opt-in)
./scripts/template-telemetry.sh record \
  --gap-kind TEMPLATE_MISSING \
  --template-id plan-template \
  [--ledger PATH] [--opt-in-file PATH] [--opt-in] \
  [--skill-version 2.4.0]
```

Default ledger path (when not overridden):  
`docs/audit/generated/template-telemetry.jsonl` under the **current working directory** (consumer or package). Prefer gitignored `docs/audit/generated/` (same family as knowledge dashboard HTML).

Format: **JSONL**, one event per line.

## Payload contract

### Allowed fields (only these may be written)

| Field | Type | Description |
|-------|------|-------------|
| `ts` | ISO-8601 UTC string | Event time |
| `event` | `"template_gap"` | Fixed event name |
| `gap_kind` | enum (below) | Kind of template/skill UX gap |
| `template_id` | short slug | Template or skill surface id (e.g. `plan-template`, `team-owners`) — **not** a filesystem path to product code |
| `skill_version` | semver string | Optional Documentation Manager version |
| `host` | short token | Optional agent host label (`claude` / `grok` / `codex` / `cursor` / `unknown`) — not a machine id |

### `gap_kind` allowlist

| Kind | Meaning |
|------|---------|
| `TEMPLATE_MISSING` | Needed template/reference not found or not installed |
| `TEMPLATE_STALE` | Template version/anchors lag skill version |
| `LAYOUT_GAP` | Consumer layout signal not covered by stack/monorepo tables |
| `PROCEDURE_UNCLEAR` | Agent could not choose mode/intent from procedure tables |
| `OTHER_UX` | Other skill UX gap (still no product code) |

### Never-send (rejected if present)

- Source code, diffs, snippets  
- Secrets, tokens, API keys, env values  
- Repo remote URLs, clone paths with usernames  
- Absolute filesystem paths to product trees  
- File contents, directory listings of app source  
- PII beyond optional generic `host` token  

The script **rejects** unknown flags that look like payload smuggling (`--source`, `--url`, `--path`, `--content`, `--repo`).

## Agent procedure

1. **Default:** do nothing. Do not enable opt-in.  
2. If the user explicitly opts in to template telemetry (or maintainers dogfood with env/file):  
   - When a **template/skill UX gap** is observed, optionally run `template-telemetry.sh record …`.  
3. Never attach product code evidence to the event — put that only in the session summary for the user.  
4. Air-gapped / privacy-sensitive: leave opt-in off; skill behavior unchanged.

Announce when relevant:

```text
Telemetry: off|local-ledger | opt-in: no|yes | network: never
```

## Air-gapped proof

| Check | Expected |
|-------|----------|
| Opt-in off + `record` | exit 0, no ledger file / no new lines |
| Opt-in on + `record` | one JSONL line with only allowlisted fields |
| Network | script contains no `curl`/`wget`/HTTP client calls |

## Anti-patterns

- Enabling telemetry by default in install scripts  
- Sending ledger contents to a remote endpoint in this slice  
- Logging consumer business rules, schemas, or routes as “gaps”  
- Using telemetry to replace audit/claims matrices  

## Related

- Modes: [modes.md](modes.md) §12 Template telemetry  
- Script: `scripts/template-telemetry.sh` (package root)  
- Privacy sibling goals: [team-governance.md](team-governance.md) (no HR dump) · quality bar anti-snapshot  
