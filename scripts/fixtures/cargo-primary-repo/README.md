# cargo-primary-repo (fixture)

Synthetic **Cargo workspace** with a secondary root `package.json` (tooling only). Used to lock `stack_misdetect` (#45): detect-stack must not emit `node-ts`.

- Has: `Cargo.toml` workspace, `rust-toolchain`, `crates/core` + `crates/cli`, root `package.json`
- Does **not** have: `AGENTS.md`, `docs/`, Node workspaces

Not a product app — inventory smoke only. Rust is not an MVP stack token; expect `unknown` + gap, and package paths for workspace members.
