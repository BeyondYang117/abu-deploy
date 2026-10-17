#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/cluster"
# shellcheck source=./_compose.sh
source "$ROOT/scripts/_compose.sh"
resolve_compose

cd "$DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created cluster/.env from .env.example — set SQL_DSN (MySQL) and secrets first."
  exit 1
fi
# Compose V1 cannot parse image defaults with ':' — keep default in .env only.
if ! grep -qE '^[[:space:]]*ABU_API_IMAGE=' .env; then
  echo 'ABU_API_IMAGE=abu116/abu-api-team:latest' >> .env
  echo "Added ABU_API_IMAGE=abu116/abu-api-team:latest to cluster/.env"
fi

# Optional one-shot schema migrate against the shared MySQL.
if [[ "${RUN_MIGRATE:-0}" == "1" ]]; then
  "${COMPOSE[@]}" --profile tools run --rm migrate up
fi

"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d

echo "Waiting for gateway /ready ..."
for _ in $(seq 1 90); do
  if curl -fsS "http://127.0.0.1:8004/ready" >/dev/null 2>&1; then
    echo "Small cluster is ready: http://127.0.0.1:8004"
    exit 0
  fi
  sleep 2
done

echo "Timed out waiting for readiness. Check: ${COMPOSE[*]} -f $DIR/docker-compose.yml ps"
exit 1
