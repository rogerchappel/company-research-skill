#!/usr/bin/env bash
set -euo pipefail

required_files=(
  README.md
  SKILL.md
  docs/research-brief-template.md
  fixtures/company-research-input.json
  LICENSE
  SECURITY.md
  CONTRIBUTING.md
  CHANGELOG.md
)

for path in "${required_files[@]}"; do
  test -s "$path"
done

python3 -m json.tool fixtures/company-research-input.json >/dev/null
grep -qi "Safety" README.md
grep -qi "Evidence Log" docs/research-brief-template.md
grep -qi "source links" SKILL.md

echo "company-research-skill validation ok"
