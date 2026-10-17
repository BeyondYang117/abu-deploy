#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/standalone"

cd "$DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created standalone/.env from .env.example — edit secrets before production use."
fi

docker compose pull
docker compose up -d

echo "Waiting for /ready ..."
for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:3004/ready" >/dev/null 2>&1; then
    echo "Standalone is ready: http://127.0.0.1:3004"
    exit 0
  fi
  sleep 2
done

echo "Timed out waiting for readiness. Check: docker compose -f $DIR/docker-compose.yml ps"
exit 1
