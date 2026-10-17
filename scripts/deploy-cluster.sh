#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/cluster"

cd "$DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created cluster/.env from .env.example — set SQL_DSN (MySQL) and secrets first."
  exit 1
fi

# Optional one-shot schema migrate against the shared MySQL.
if [[ "${RUN_MIGRATE:-0}" == "1" ]]; then
  docker compose --profile tools run --rm migrate up
fi

docker compose pull
docker compose up -d

echo "Waiting for gateway /ready ..."
for _ in $(seq 1 90); do
  if curl -fsS "http://127.0.0.1:8004/ready" >/dev/null 2>&1; then
    echo "Small cluster is ready: http://127.0.0.1:8004"
    exit 0
  fi
  sleep 2
done

echo "Timed out waiting for readiness. Check: docker compose -f $DIR/docker-compose.yml ps"
exit 1
