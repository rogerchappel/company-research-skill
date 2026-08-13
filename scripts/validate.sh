#!/usr/bin/env bash
set -euo pipefail

root=${1:-.}

required_files=(
  README.md
  SKILL.md
  docs/research-brief-template.md
  docs/source-policy.md
  fixtures/company-research-input.json
  LICENSE
  SECURITY.md
  CONTRIBUTING.md
  CHANGELOG.md
)

for path in "${required_files[@]}"; do
  test -s "$root/$path"
done

python3 -m json.tool "$root/fixtures/company-research-input.json" >/dev/null
grep -qi "Safety" "$root/README.md"
grep -qi "source links" "$root/SKILL.md"

for heading in "## Request" "## Snapshot" "## Evidence Log" "## Open Questions" "## Suggested Follow-Up"; do
  grep -Fqx "$heading" "$root/docs/research-brief-template.md"
done

template=$root/docs/research-brief-template.md
policy=$root/docs/source-policy.md

grep -Fqx '| Claim | Source | Source tier | Retrieved |' "$template"
grep -Fqx '| --- | --- | --- | --- |' "$template"
grep -Fqx '|  |  | Primary / Registry / Secondary |  |' "$template"

grep -Fqx '## Source Tiers' "$policy"
grep -Fqx 'Use exactly these labels in the research brief Evidence Log: `Primary`,' "$policy"
grep -Fqx '`Registry`, or `Secondary`.' "$policy"
for tier in Primary Registry Secondary; do
  grep -Eq "^- ${tier}:" "$policy"
done

echo "company-research-skill validation ok"
