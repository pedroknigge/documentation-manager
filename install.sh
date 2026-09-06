#!/usr/bin/env bash
# documentation-manager skill installer — v2.0 (idempotent)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash
# Or, from a local clone:
#   ./install.sh
#   ./install.sh --uninstall
#
# Copies the full skill directory (SKILL.md + references/) into detected agent skill paths
# and ships the runtime CLI into <skill>/scripts/ (package-root scripts/ is SSOT).
# Codex gets a marked pointer block in ~/.codex/AGENTS.md (full skill lives under ~/.agents/skills).
# Does not auto-copy scripts into consumer repos (CI copy stays opt-in).
# After `npx skills add`, run this installer — npx replaces the skill folder
# and wipes scripts/ (audit-claims + discovery helpers) that this script ships.

set -euo pipefail

REPO_RAW="${DOCUMENTATION_MANAGER_RAW:-https://raw.githubusercontent.com/pedroknigge/documentation-manager/main}"
SKILL_NAME="documentation-manager"
SKILL_REL="skills/${SKILL_NAME}"
BEGIN_MARKER="<!-- BEGIN documentation-manager skill -->"
END_MARKER="<!-- END documentation-manager skill -->"

UNINSTALL=0
if [[ "${1:-}" == "--uninstall" ]]; then
  UNINSTALL=1
fi

cyan()  { printf "\033[36m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }
red()   { printf "\033[31m%s\033[0m\n" "$1"; }

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

have_local() {
  [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/${SKILL_REL}/SKILL.md" ]]
}

# Runtime CLI shipped into the installed skill. Package-root scripts/ is SSOT.
# Maintainer validate/hardening/smoke and fixtures stay at package root.
install_skill_scripts() {
  local dest="$1"
  mkdir -p "$dest/scripts"
  local script dest_script
  for script in \
    audit-claims.sh \
    detect-stack.sh \
    detect-packages.sh \
    survey-docs.sh \
    generate-docs-dashboard.sh
  do
    dest_script="${dest}/scripts/${script}"
    if have_local && [[ -f "${SCRIPT_DIR}/scripts/${script}" ]]; then
      cp -f "${SCRIPT_DIR}/scripts/${script}" "$dest_script"
      chmod +x "$dest_script"
    elif ! have_local; then
      if [[ "$script" == "audit-claims.sh" ]]; then
        curl -fsSL "${REPO_RAW}/scripts/${script}" -o "$dest_script"
        chmod +x "$dest_script"
      else
        curl -fsSL "${REPO_RAW}/scripts/${script}" -o "$dest_script" 2>/dev/null \
          && chmod +x "$dest_script" || true
      fi
    fi
  done
  if [[ ! -x "$dest/scripts/audit-claims.sh" ]]; then
    red "Failed to install audit-claims.sh into $dest/scripts"
    return 1
  fi
}

# Install full skill tree into destination directory (parent of skill folder name).
install_skill_tree() {
  local dest_parent="$1"
  local dest="${dest_parent}/${SKILL_NAME}"
  mkdir -p "$dest_parent"
  rm -rf "$dest"
  mkdir -p "$dest"

  if have_local; then
    # Prefer rsync if available; else cp -R
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --delete "${SCRIPT_DIR}/${SKILL_REL}/" "$dest/"
    else
      cp -R "${SCRIPT_DIR}/${SKILL_REL}/." "$dest/"
    fi
  else
    # Fetch SKILL.md + known references from raw GitHub
    mkdir -p "$dest/references"
    curl -fsSL "${REPO_RAW}/${SKILL_REL}/SKILL.md" -o "$dest/SKILL.md"
    local ref
    for ref in \
      agents-md-template.md \
      adr-template.md \
      feature-readme-template.md \
      feature-cluster-template.md \
      architecture-template.md \
      modes.md \
      quality-checklist.md \
      status-taxonomy.md \
      audit-template.md \
      plan-template.md \
      arkgate-bridge.md \
      implementation-bridge.md \
      knowledge-dashboard.md \
      skill-discovery.md \
      team-governance.md \
      team-owners-template.md \
      team-approval-notes-template.md \
      living-claims.md
    do
      curl -fsSL "${REPO_RAW}/${SKILL_REL}/references/${ref}" -o "$dest/references/${ref}" || true
    done
  fi

  install_skill_scripts "$dest" || return 1

  if [[ ! -f "$dest/SKILL.md" ]]; then
    red "Failed to install skill to $dest"
    return 1
  fi
  echo "$dest"
}

remove_skill_tree() {
  local dest_parent="$1"
  local dest="${dest_parent}/${SKILL_NAME}"
  if [[ -d "$dest" ]]; then
    rm -rf "$dest"
    rmdir "$dest_parent" 2>/dev/null || true
    return 0
  fi
  return 1
}

strip_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  awk -v b="$BEGIN_MARKER" -v e="$END_MARKER" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$file" > "$tmp"
  awk 'NF {p=1} p {print}' "$tmp" | awk '
    { lines[NR] = $0 }
    END {
      n = NR
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) { n-- }
      for (i = 1; i <= n; i++) print lines[i]
    }
  ' > "$file"
  rm -f "$tmp"
}

codex_pointer_block() {
  cat <<'EOF'
# documentation-manager skill

Install location (full skill + templates): `~/.agents/skills/documentation-manager/`

Use when bootstrapping or updating project docs, or documenting a feature/module:
create/maintain `AGENTS.md` (or `agents.md`) + `docs/`, ADRs, roadmap, and
`docs/features/<slug>/`.

Slash / invoke: `/documentation-manager`

If the skill folder is missing, re-run the installer or:
`npx skills add pedroknigge/documentation-manager`
EOF
}

installed_any=0
removed_any=0

if [[ "$UNINSTALL" -eq 1 ]]; then
  cyan "→ documentation-manager skill uninstaller"
else
  cyan "→ documentation-manager skill installer (v2.0 — idempotent)"
fi

# ─── Claude Code ──────────────────────────────────────────────────────────────
if command -v claude >/dev/null 2>&1 || [[ -d "${HOME}/.claude" ]]; then
  parent="${HOME}/.claude/skills"
  if [[ "$UNINSTALL" -eq 1 ]]; then
    if remove_skill_tree "$parent"; then
      green "✓ Removed from Claude Code  → ${parent}/${SKILL_NAME}"
      removed_any=1
    fi
  else
    path="$(install_skill_tree "$parent")"
    green "✓ Installed for Claude Code  → $path"
    installed_any=1
  fi
fi

# ─── Grok Build (user) ────────────────────────────────────────────────────────
if command -v grok >/dev/null 2>&1 || [[ -d "${HOME}/.grok" ]]; then
  parent="${HOME}/.grok/skills"
  if [[ "$UNINSTALL" -eq 1 ]]; then
    if remove_skill_tree "$parent"; then
      green "✓ Removed from Grok Build (user) → ${parent}/${SKILL_NAME}"
      removed_any=1
    fi
  else
    path="$(install_skill_tree "$parent")"
    green "✓ Installed for Grok Build (user) → $path"
    installed_any=1
  fi
fi

# ─── Gemini CLI (+ Antigravity / config if those parents already exist) ───────
if command -v gemini >/dev/null 2>&1 || [[ -d "${HOME}/.gemini" ]]; then
  gemini_parents=("${HOME}/.gemini/skills")
  if [[ "$UNINSTALL" -eq 1 ]]; then
    gemini_parents+=("${HOME}/.gemini/config/skills")
    gemini_parents+=("${HOME}/.gemini/antigravity/skills")
  else
    [[ -d "${HOME}/.gemini/config/skills" ]] && gemini_parents+=("${HOME}/.gemini/config/skills")
    [[ -d "${HOME}/.gemini/antigravity/skills" ]] && gemini_parents+=("${HOME}/.gemini/antigravity/skills")
  fi
  for parent in "${gemini_parents[@]}"; do
    if [[ "$UNINSTALL" -eq 1 ]]; then
      if remove_skill_tree "$parent"; then
        green "✓ Removed from Gemini         → ${parent}/${SKILL_NAME}"
        removed_any=1
      fi
    else
      path="$(install_skill_tree "$parent")"
      green "✓ Installed for Gemini         → $path"
      installed_any=1
    fi
  done
fi

# ─── Open agent skills path (~/.agents/skills) ────────────────────────────────
if [[ -d "${HOME}/.agents" ]] || command -v codex >/dev/null 2>&1 || true; then
  parent="${HOME}/.agents/skills"
  if [[ "$UNINSTALL" -eq 1 ]]; then
    if remove_skill_tree "$parent"; then
      green "✓ Removed from ~/.agents/skills → ${parent}/${SKILL_NAME}"
      removed_any=1
    fi
  else
    # Always install here so Codex pointer + multi-agent discovery work
    mkdir -p "${HOME}/.agents"
    path="$(install_skill_tree "$parent")"
    green "✓ Installed for agents path     → $path"
    installed_any=1
  fi
fi

# ─── Project-local (if in a git repo) ─────────────────────────────────────────
if [[ -d ".git" || -f ".grok/config.toml" || -d ".agents" ]]; then
  # Prefer .agents/skills for open ecosystem; also support .grok/skills
  for parent in ".agents/skills" ".grok/skills" ".claude/skills"; do
    if [[ "$parent" == ".grok/skills" && ! -d ".grok" && ! -f ".grok/config.toml" ]]; then
      continue
    fi
    if [[ "$parent" == ".claude/skills" && ! -d ".claude" ]]; then
      continue
    fi
    # Only write project-local when directory already exists OR .git present for .agents
    if [[ "$parent" == ".agents/skills" ]] || [[ -d "$(dirname "$parent")" ]]; then
      if [[ "$UNINSTALL" -eq 1 ]]; then
        if remove_skill_tree "$parent"; then
          green "✓ Removed project-local → ${parent}/${SKILL_NAME}"
          removed_any=1
        fi
      else
        if [[ -d ".git" || -d "$(dirname "$parent")" ]]; then
          path="$(install_skill_tree "$parent")"
          green "✓ Installed project-local  → $path"
          installed_any=1
        fi
      fi
    fi
  done
fi

# ─── Codex CLI pointer ────────────────────────────────────────────────────────
if command -v codex >/dev/null 2>&1 || [[ -d "${HOME}/.codex" ]]; then
  target="${HOME}/.codex/AGENTS.md"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  strip_block "$target"

  if [[ "$UNINSTALL" -eq 1 ]]; then
    green "✓ Removed Codex AGENTS.md block → $target"
    removed_any=1
  else
    {
      [[ -s "$target" ]] && echo ""
      echo "$BEGIN_MARKER"
      codex_pointer_block
      echo "$END_MARKER"
    } >> "$target"
    green "✓ Updated Codex AGENTS.md   → $target"
    installed_any=1
  fi
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
if [[ "$UNINSTALL" -eq 1 ]]; then
  if [[ "$removed_any" -eq 0 ]]; then
    yellow "Nothing to remove — no install found."
    exit 0
  fi
  cyan "→ Done. documentation-manager has been removed."
  exit 0
fi

if [[ "$installed_any" -eq 0 ]]; then
  yellow "No supported agent path detected."
  yellow "Manual install: copy ${SKILL_REL}/ to your agent's skills directory."
  exit 1
fi

cyan "→ Done. Invoke with /documentation-manager"
cyan "  If you also use npx skills add, run this AFTER npx (npx wipes scripts/)."
cyan "  Update anytime by re-running this script. Uninstall: ./install.sh --uninstall"
