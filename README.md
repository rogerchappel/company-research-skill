# company-research-skill

Local-first company research workflow for agent runs that need sourced,
reviewable company briefs without mixing facts, assumptions, and outreach copy.

## Quickstart

```sh
bash scripts/validate.sh
```

Use the skill instructions in `SKILL.md` with a company name, website, and the
research question you need answered. The fixture below is a safe starter input:

```sh
cat fixtures/company-research-input.json
```

## What It Produces

- Company snapshot with source links and retrieval dates.
- Product, customer, and positioning notes.
- Funding, hiring, compliance, and risk signals when available.
- Open questions separated from verified facts.
- A short evidence log that reviewers can audit before reuse.

## Repository Layout

- `SKILL.md` - reusable agent instructions.
- `fixtures/company-research-input.json` - minimal sample research brief.
- `docs/research-brief-template.md` - output template for completed research.
- `scripts/validate.sh` - local smoke check for required release files.

## Safety And Limitations

- Use public or user-provided sources only.
- Do not infer private facts, personal contact details, or financial claims.
- Mark stale, conflicting, or unsourced information as an open question.
- This skill organizes research; it does not replace legal, investment, or
  compliance review.

## Verify

```sh
bash scripts/validate.sh
```

CI runs the same validation script on every push and pull request.

## License

MIT
