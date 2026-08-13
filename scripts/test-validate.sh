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
  if bash "$root/scripts/validate.sh" "$package" >/dev/null 2>&1; then
    echo "expected validation failure: $description" >&2
    exit 1
  fi
}

bash "$root/scripts/validate.sh" "$root"

missing_table=$tmp/missing-table
copy_package "$missing_table"
sed -i.bak '/| Claim | Source | Source tier | Retrieved |/d' \
  "$missing_table/docs/research-brief-template.md"
rm "$missing_table/docs/research-brief-template.md.bak"
expect_failure "$missing_table" "missing Evidence Log table header"

undeclared_tier=$tmp/undeclared-tier
copy_package "$undeclared_tier"
sed -i.bak 's/Primary \/ Registry \/ Secondary/Primary \/ Database \/ Secondary/' \
  "$undeclared_tier/docs/research-brief-template.md"
rm "$undeclared_tier/docs/research-brief-template.md.bak"
expect_failure "$undeclared_tier" "undeclared source tier"

echo "company-research-skill validation tests ok"
