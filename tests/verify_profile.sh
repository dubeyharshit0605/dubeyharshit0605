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
grep -Fq 'YC W21' "$readme" || fail "YC W21 credential is not prominent in the README"
grep -Fq 'IIIT Vadodara' "$readme" || fail "education context is missing"
grep -Fq 'assets/shipping-log-hero.svg' "$readme" || fail "README does not render the custom hero"
grep -Fq 'shipping-log-hero.svg?v=yc-w21' "$readme" || fail "hero URL is not versioned to prevent stale profile artwork"
grep -Fq '>YC W21<' "$hero" || fail "hero does not feature the YC W21 lockup"

project_count="$(grep -Ec '^\| \[\*\*' "$readme")"
(( project_count == 3 )) || fail "proof of work must feature exactly three projects (found $project_count)"

while IFS= read -r asset_path; do
  [[ -f "$repo_root/$asset_path" ]] || fail "README references missing local asset: $asset_path"
done < <(grep -Eo 'assets/[A-Za-z0-9._/-]+' "$readme" | sort -u)

line_count="$(wc -l < "$readme" | tr -d ' ')"
(( line_count <= 170 )) || fail "README is too long to scan quickly ($line_count lines)"

printf 'PASS: profile README and artwork satisfy all acceptance checks\n'
