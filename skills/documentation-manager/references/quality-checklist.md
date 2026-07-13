# Quality checklist

Run before reporting done.

## Accuracy

- [ ] Claims about behavior match code or are labeled as planned/inferred
- [ ] Paths, package names, and APIs are real (or marked TBD)
- [ ] No invented features or endpoints

## Structure

- [ ] Hub exists and links to every new/updated top-level doc
- [ ] Feature docs live under `docs/features/<kebab-slug>/`
- [ ] Relative links work from their file location
- [ ] ADRs one decision per file; status + date present

## Scope discipline

- [ ] Project bootstrap: core set only (no empty feature trees)
- [ ] Feature mode: did not force full product-vision/requirements suite
- [ ] Sync: only impacted docs touched
- [ ] No auto-commit / auto-push

## Usefulness

- [ ] Overview sections are short and scannable
- [ ] Acceptance criteria or success metrics where decisions depend on them
- [ ] Mermaid/diagrams only where they clarify
- [ ] Open questions listed instead of silent assumptions

## Agent readiness

- [ ] Hub tells agents to read docs before major work and update after
- [ ] "Code wins for how; docs capture why/what" is clear
- [ ] Last updated / status line refreshed

## Voice

- [ ] Matches repo language (or user's language)
- [ ] Concrete nouns, active voice, no filler
- [ ] Prefer "you can…" / "the system does…" over vague corporate tone
