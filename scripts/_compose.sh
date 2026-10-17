#!/usr/bin/env bash
# Shared Docker Compose resolver for deploy-*.sh
#
# Prefer:
#   1) `docker compose` (Compose V2 plugin)
#   2) modern standalone `docker-compose` (V2)
#   3) auto-download Compose V2 binary into <repo>/.tools/
# Never use ancient Compose V1 from Ubuntu Focal apt — it cannot parse this repo.

COMPOSE_V2_VERSION="${COMPOSE_V2_VERSION:-v2.29.7}"

_compose_is_v2() {
  local out
  out="$("$@" version 2>/dev/null || true)"
  # V2 prints "Docker Compose version v2.x.y"
  # V1 prints "docker-compose version 1.x.y, build ..."
  [[ "$out" == *"Docker Compose version v2"* ]] || [[ "$out" == *"version v2."* ]]
}

_compose_download_v2() {
  local tools_dir="$1"
  local dest="$tools_dir/docker-compose"
  local arch raw_arch url
  mkdir -p "$tools_dir"

  if [[ -x "$dest" ]] && _compose_is_v2 "$dest"; then
    echo "$dest"
    return 0
  fi

  raw_arch="$(uname -m)"
  case "$raw_arch" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="aarch64" ;;
    *)
      echo "Unsupported architecture for Compose V2 auto-download: $raw_arch" >&2
      return 1
      ;;
  esac

  url="https://github.com/docker/compose/releases/download/${COMPOSE_V2_VERSION}/docker-compose-linux-${arch}"
  echo "Downloading Docker Compose ${COMPOSE_V2_VERSION} (${arch}) ..." >&2
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest.tmp"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dest.tmp" "$url"
  else
    echo "Need curl or wget to download Docker Compose V2." >&2
    return 1
  fi
  chmod +x "$dest.tmp"
  mv "$dest.tmp" "$dest"

  if ! _compose_is_v2 "$dest"; then
    echo "Downloaded Compose binary is not usable." >&2
    return 1
  fi
  echo "Installed Compose V2 to $dest" >&2
  echo "$dest"
}

resolve_compose() {
  local root tools_dir bin
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  tools_dir="$root/.tools"

  if docker compose version >/dev/null 2>&1 && _compose_is_v2 docker compose; then
    COMPOSE=(docker compose)
    return 0
  fi

  if command -v docker-compose >/dev/null 2>&1 && _compose_is_v2 docker-compose; then
    COMPOSE=(docker-compose)
    return 0
  fi

  # System docker-compose is missing or Compose V1 (Focal apt) — bootstrap V2.
  if bin="$(_compose_download_v2 "$tools_dir")"; then
    COMPOSE=("$bin")
    return 0
  fi

  cat >&2 <<'EOF'
Unable to obtain a modern Docker Compose (V2).

Install one of:
  # Official Compose V2 plugin
  https://docs.docker.com/compose/install/

  # Or place a Compose V2 binary at:
  #   <abu-deploy>/.tools/docker-compose

Ubuntu Focal apt `docker-compose` (V1) is too old for this repository.
EOF
  exit 1
}
