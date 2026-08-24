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

python3 - "$root/fixtures/company-research-input.json" <<'PY'
import json
import sys
from urllib.parse import urlparse

path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as handle:
        value = json.load(handle)
except (OSError, UnicodeError, json.JSONDecodeError) as error:
    raise SystemExit(f"invalid company research input: {error}")

if not isinstance(value, dict):
    raise SystemExit("invalid company research input: root must be an object")

for field in ("company", "purpose"):
    if not isinstance(value.get(field), str) or not value[field].strip():
        raise SystemExit(f"invalid company research input: {field} must be a non-empty string")

website = value.get("website")
domain = value.get("domain")
if not any(isinstance(item, str) and item.strip() for item in (website, domain)):
    raise SystemExit("invalid company research input: website or domain must be a non-empty string")
if website is not None:
    parsed = urlparse(website) if isinstance(website, str) else None
    if not parsed or parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise SystemExit("invalid company research input: website must be an absolute http(s) URL")

sources = value.get("requiredSources")
if not isinstance(sources, list) or not sources or any(
    not isinstance(source, str) or not source.strip() for source in sources
):
    raise SystemExit("invalid company research input: requiredSources must be a non-empty list of non-empty strings")

for field in ("scope", "geography", "dateRange"):
    if field in value and (not isinstance(value[field], str) or not value[field].strip()):
        raise SystemExit(f"invalid company research input: optional {field} must be a non-empty string when provided")
PY
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
