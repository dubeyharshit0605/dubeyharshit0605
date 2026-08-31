#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme="$repo_root/README.md"
hero="$repo_root/assets/shipping-log-hero.svg"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -f "$readme" ]] || fail "README.md is missing"
[[ -f "$hero" ]] || fail "shipping-log hero artwork is missing"

xmllint --noout "$hero" 2>/dev/null || fail "hero artwork is not valid XML"

grep -Fq 'Software Engineer @ Venu AI' "$readme" || fail "current role is not immediately visible"
grep -Fq 'YC W21' "$readme" || fail "Venu AI YC context is missing"
grep -Fq 'IIIT Vadodara' "$readme" || fail "education context is missing"
grep -Fq 'assets/shipping-log-hero.svg' "$readme" || fail "README does not render the custom hero"

while IFS= read -r asset_path; do
  [[ -f "$repo_root/$asset_path" ]] || fail "README references missing local asset: $asset_path"
done < <(grep -Eo 'assets/[A-Za-z0-9._/-]+' "$readme" | sort -u)

line_count="$(wc -l < "$readme" | tr -d ' ')"
(( line_count <= 170 )) || fail "README is too long to scan quickly ($line_count lines)"

printf 'PASS: profile README and artwork satisfy all acceptance checks\n'
