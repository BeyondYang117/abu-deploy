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
# Compose V1 cannot parse image defaults with ':' — keep default in .env only.
if ! grep -qE '^[[:space:]]*ABU_API_IMAGE=' .env; then
  echo 'ABU_API_IMAGE=abu116/abu-api-team:latest' >> .env
  echo "Added ABU_API_IMAGE=abu116/abu-api-team:latest to standalone/.env"
fi

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
