# Company Research Skill

Use this skill when a user asks for a sourced company brief, competitor snapshot,
account plan, partner screen, or diligence note.

## Inputs

Ask for missing essentials before researching:

- `company`: non-empty company name (required)
- `website` or `domain`: absolute HTTP(S) official website URL or DNS-style
  primary domain with at least two dot-separated labels, such as `example.com`
  (at least one required; domains omit schemes, paths, ports, and whitespace)
- `purpose`: non-empty research purpose (required)
- `requiredSources`: non-empty list of source categories to consult (required)
- `scope`, `geography`, and `dateRange`: non-empty strings when supplied (optional)

## Workflow

1. Confirm the company identity from the official website or another primary
   source.
2. Collect public evidence for product, customers, pricing, leadership, hiring,
   funding, regulatory posture, and recent news when those categories are
   relevant to the research purpose.
3. Classify every source using the tiers defined in `docs/source-policy.md`:
   `Primary`, `Registry`, or `Secondary`.
4. Prefer Primary sources. Use Registry sources for authoritative records and
   Secondary sources only to corroborate or discover leads.
5. Separate verified facts, dated observations, and inferences.
6. Produce a concise brief using `docs/research-brief-template.md`.

## Output Rules

- Include source links and retrieval dates for important claims.
- Mark unknowns explicitly instead of guessing.
- Keep outreach, sales copy, and recommendations separate from the factual
  research brief.
- Do not include private personal data, scraped contact lists, credentials, or
  confidential customer information.

## Quality Bar

A complete brief should let another reviewer answer:

- What did we verify?
- Where did each important claim come from?
- What is stale, uncertain, or missing?
- What follow-up would reduce the largest uncertainty?
