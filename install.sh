#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PARTS="$ROOT/releases/parts"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
ARCHIVE="$WORK_DIR/spotify-noctalia-ambient.tar.xz"

for tool in tar xz base64; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'error: %s is required to install Spotify Ambient\n' "$tool" >&2
    exit 1
  fi
done

if [[ ! -d "$PARTS" ]] || ! compgen -G "$PARTS/*.b64" >/dev/null; then
  printf 'error: release source chunks are missing from %s\n' "$PARTS" >&2
  exit 1
fi

cat "$PARTS"/*.b64 | base64 --decode > "$ARCHIVE"
if ! xz --test "$ARCHIVE"; then
  printf 'error: downloaded release package failed its XZ integrity check\n' >&2
  exit 1
fi

tar -xJf "$ARCHIVE" -C "$WORK_DIR"
if [[ ! -x "$WORK_DIR/install.sh" || ! -f "$WORK_DIR/ambient.py" ]]; then
  printf 'error: release package is incomplete\n' >&2
  exit 1
fi

"$WORK_DIR/install.sh"
