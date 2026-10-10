#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

copy_package() {
  local destination=$1
  mkdir -p "$destination"
  cp -R "$root/docs" "$root/fixtures" "$root/scripts" "$destination/"
  cp "$root/README.md" "$root/SKILL.md" "$root/LICENSE" "$root/SECURITY.md" \
    "$root/CONTRIBUTING.md" "$root/CHANGELOG.md" "$destination/"
}

expect_failure() {
  local package=$1
  local description=$2
  local expected=${3:-}
  local output
  if output=$(bash "$root/scripts/validate.sh" "$package" 2>&1); then
    echo "expected validation failure: $description" >&2
    exit 1
  fi
  if [[ -n $expected && $output != *"$expected"* ]]; then
    echo "validation failure for $description did not include: $expected" >&2
    echo "$output" >&2
    exit 1
  fi
}

bash "$root/scripts/validate.sh" "$root"

expect_fixture_failure() {
  local description=$1
  local expected=$2
  shift 2
  local package=$tmp/invalid-${description//[^a-zA-Z0-9]/-}
  copy_package "$package"
  python3 - "$package/fixtures/company-research-input.json" "$@" <<'PYCASE'
import json, sys
path, mode, value = sys.argv[1:]
if mode == "raw":
    open(path, "w", encoding="utf-8").write(value)
else:
    with open(path, encoding="utf-8") as handle:
        fixture = json.load(handle)
    if mode == "root":
        fixture = json.loads(value)
    elif mode == "field":
        field, replacement = value.split("=", 1)
        fixture[field] = json.loads(replacement)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(fixture, handle)
PYCASE
  expect_failure "$package" "$description" "$expected"
}

expect_fixture_failure "malformed-json" "invalid company research input:" raw '{"company":'
expect_fixture_failure "array-root" "root must be an object" root '[]'
expect_fixture_failure "null-root" "root must be an object" root 'null'
expect_fixture_failure "sources-not-list" "requiredSources must be a non-empty list" field 'requiredSources="news"'
expect_fixture_failure "relative-url" "website must be an absolute http(s) URL" field 'website="//example.com/path"'
expect_fixture_failure "unsupported-scheme" "website must be an absolute http(s) URL" field 'website="ftp://example.com"'
expect_fixture_failure "missing-hostname" "website must be an absolute http(s) URL" field 'website="https:///path"'
expect_fixture_failure "unicode-domain" "domain must be a valid primary domain" field 'domain="münich.example"'
expect_fixture_failure "trailing-dot-domain" "domain must be a valid primary domain" field 'domain="example.com."'

workflow=$root/.github/workflows/ci.yml
grep -Fqx 'permissions:' "$workflow"
grep -Fqx '  contents: read' "$workflow"
grep -Fq 'uses: actions/checkout@v5' "$workflow"

valid_domain=$tmp/valid-domain
copy_package "$valid_domain"
python3 - "$valid_domain/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value.pop("website")
value["domain"] = "research.example.com"
open(path, "w").write(json.dumps(value))
PY
bash "$root/scripts/validate.sh" "$valid_domain"

website_only=$tmp/website-only
copy_package "$website_only"
python3 - "$website_only/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value.pop("domain", None)
value["website"] = "https://www.example.com/research"
open(path, "w").write(json.dumps(value))
PY
bash "$root/scripts/validate.sh" "$website_only"

valid_http_website=$tmp/valid-http-website
copy_package "$valid_http_website"
python3 - "$valid_http_website/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value.pop("domain", None)
value["website"] = "http://example.com:8080/company/about?view=full"
open(path, "w").write(json.dumps(value))
PY
bash "$root/scripts/validate.sh" "$valid_http_website"

for invalid_website in \
  "https://example.com:bad-port" \
  "https:// example.com" \
  " https://example.com " \
  "https://-example.com" \
  "https://user:password@example.com"; do
  malformed_website=$tmp/malformed-website-${invalid_website//[^a-zA-Z0-9]/-}
  copy_package "$malformed_website"
  python3 - "$malformed_website/fixtures/company-research-input.json" "$invalid_website" <<'PY'
import json, sys
path, website = sys.argv[1:]
value = json.load(open(path))
value.pop("domain", None)
value["website"] = website
open(path, "w").write(json.dumps(value))
PY
  expect_failure "$malformed_website" "malformed website: $invalid_website" \
    "website must be an absolute http(s) URL"
done

edit_file() {
  local path=$1
  local expression=$2
  local edited=$path.edited
  sed "$expression" "$path" > "$edited"
  mv "$edited" "$path"
}

missing_table=$tmp/missing-table
copy_package "$missing_table"
edit_file "$missing_table/docs/research-brief-template.md" \
  '/| Claim | Source | Source tier | Retrieved |/d'
expect_failure "$missing_table" "missing Evidence Log table header"

undeclared_tier=$tmp/undeclared-tier
copy_package "$undeclared_tier"
edit_file "$undeclared_tier/docs/research-brief-template.md" \
  's/Primary \/ Registry \/ Secondary/Primary \/ Database \/ Secondary/'
expect_failure "$undeclared_tier" "undeclared source tier"

missing_evidence_row=$tmp/missing-evidence-row
copy_package "$missing_evidence_row"
edit_file "$missing_evidence_row/docs/research-brief-template.md" \
  '/|  |  | Primary \/ Registry \/ Secondary |  |/d'
expect_failure "$missing_evidence_row" "missing Evidence Log example row"

wrong_company=$tmp/wrong-company
copy_package "$wrong_company"
python3 - "$wrong_company/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value["company"] = 42
open(path, "w").write(json.dumps(value))
PY
expect_failure "$wrong_company" "wrong-type company" "company must be a non-empty string"

missing_website=$tmp/missing-website
copy_package "$missing_website"
python3 - "$missing_website/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value.pop("website")
open(path, "w").write(json.dumps(value))
PY
expect_failure "$missing_website" "missing website or domain" "website or domain must be a non-empty string"

for invalid_domain in "not a domain" " example.com " "-example.com" "example..com"; do
  malformed_domain=$tmp/malformed-domain-${invalid_domain//[^a-zA-Z0-9]/-}
  copy_package "$malformed_domain"
  python3 - "$malformed_domain/fixtures/company-research-input.json" "$invalid_domain" <<'PY'
import json, sys
path, domain = sys.argv[1:]
value = json.load(open(path))
value.pop("website")
value["domain"] = domain
open(path, "w").write(json.dumps(value))
PY
  expect_failure "$malformed_domain" "malformed domain: $invalid_domain" "domain must be a valid primary domain"
done

empty_purpose=$tmp/empty-purpose
copy_package "$empty_purpose"
python3 - "$empty_purpose/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value["purpose"] = "  "
open(path, "w").write(json.dumps(value))
PY
expect_failure "$empty_purpose" "empty purpose" "purpose must be a non-empty string"

invalid_sources=$tmp/invalid-sources
copy_package "$invalid_sources"
python3 - "$invalid_sources/fixtures/company-research-input.json" <<'PY'
import json, sys
path = sys.argv[1]
value = json.load(open(path))
value["requiredSources"] = []
open(path, "w").write(json.dumps(value))
PY
expect_failure "$invalid_sources" "empty source list" "requiredSources must be a non-empty list"

echo "company-research-skill validation tests ok"
