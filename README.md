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
- `docs/source-policy.md` - source quality tiers and minimum evidence rules.
- `scripts/validate.sh` - package and Evidence Log contract validation.
- `scripts/test-validate.sh` - offline positive and negative validation tests.

## Safety And Limitations

- This skill is a research workflow scaffold, not a source of verified company
  data by itself.
- Use public or user-provided sources only, and check generated findings against
  primary sources such as the company site, filings, or official announcements.
- Do not infer private employee, customer, financial, credential, or personal
  contact data.
- Mark stale, conflicting, or unsourced information as an open question.
- This skill organizes research; it does not replace legal, investment, or
  compliance review.

## Verify

```sh
bash scripts/validate.sh
```

CI runs the same validation script on every push and pull request.

The validation script enforces required release files, fixture JSON syntax, the
Evidence Log table schema, and the exact `Primary`, `Registry`, and `Secondary`
source-tier vocabulary declared by the source policy. Run the offline executable
coverage, including malformed-template cases, with:

```sh
bash scripts/test-validate.sh
```

## License

MIT
