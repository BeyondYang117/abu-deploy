#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/standalone"
# shellcheck source=./_compose.sh
source "$ROOT/scripts/_compose.sh"
resolve_compose

cd "$DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created standalone/.env from .env.example — edit secrets before production use."
fi

# Merge missing keys from .env.example so upgrades stay Compose-V1-safe
# (defaults must live in .env, not ${VAR:-...} in compose).
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  key="${line%%=*}"
  [[ -z "$key" || "$key" == "$line" ]] && continue
  if ! grep -qE "^[[:space:]]*${key}=" .env; then
    echo "$line" >> .env
    echo "Added $key to standalone/.env from .env.example"
  fi
done < .env.example

"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d

echo "Waiting for /ready ..."
for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:8003/ready" >/dev/null 2>&1; then
    echo "Standalone is ready: http://127.0.0.1:8003 (LAN/public: http://<host-ip>:8003)"
    exit 0
  fi
  sleep 2
done

echo "Timed out waiting for readiness. Check: ${COMPOSE[*]} -f $DIR/docker-compose.yml ps"
exit 1
