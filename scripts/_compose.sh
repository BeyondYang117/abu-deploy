#!/usr/bin/env bash
# Shared Docker Compose resolver for deploy-*.sh
# Prefer Compose V2 plugin (`docker compose`), fall back to standalone `docker-compose`.

resolve_compose() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
    return 0
  fi
  if command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
    return 0
  fi

  cat >&2 <<'EOF'
Docker Compose is not installed.

Install one of:
  # Debian/Ubuntu (Compose V2 plugin, recommended)
  sudo apt-get update && sudo apt-get install -y docker-compose-plugin

  # Or standalone binary (Compose V1 / docker-compose)
  sudo apt-get install -y docker-compose

  # Official docs
  https://docs.docker.com/compose/install/

Then re-run this script.
EOF
  exit 1
}
