#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEARCH_PATHS=("$ROOT/docs" "$ROOT/skills")

unsafe_ports="$(
  grep -RInE \
    --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' \
    -- '(-p|--publish)[[:space:]]+[^[:space:]]*:1433|^[[:space:]]*-[[:space:]]+["'"'"']?[^[:space:]"'"'"']*:1433' \
    "${SEARCH_PATHS[@]}" |
    grep -vE '127\.0\.0\.1:[^:[:space:]"]+:1433' || true
)"

known_passwords="$(
  grep -RInE \
    --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' \
    -- 'MSSQL_SA_PASSWORD[:=][^[:cntrl:]]*YourStr0ng_Passw0rd' \
    "${SEARCH_PATHS[@]}" || true
)"

if [[ -n "$unsafe_ports" ]]; then
  echo "Container examples must bind published SQL ports to 127.0.0.1:" >&2
  echo "$unsafe_ports" >&2
fi

if [[ -n "$known_passwords" ]]; then
  echo "Container examples must not assign the public example SA password:" >&2
  echo "$known_passwords" >&2
fi

if [[ -n "$unsafe_ports" || -n "$known_passwords" ]]; then
  exit 1
fi

echo "Secure container example checks passed."
