#!/usr/bin/env bash
# Sync npm package versions to the given version.
# Usage: sync-npm-version.sh <version>
#   e.g. sync-npm-version.sh 0.1.1
set -euo pipefail

VERSION="${1:?Usage: sync-npm-version.sh <version>}"
echo "Syncing npm package versions to $VERSION..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NPM_DIR="$(dirname "$SCRIPT_DIR")/npm"

for pkg in "$NPM_DIR"/actual \
           "$NPM_DIR"/actual-darwin-arm64 "$NPM_DIR"/actual-darwin-x64 \
           "$NPM_DIR"/actual-linux-x64 "$NPM_DIR"/actual-linux-arm64; do
  tmp=$(mktemp)
  jq --arg v "$VERSION" \
    'if .optionalDependencies then .version = $v | .optionalDependencies |= with_entries(.value = $v) else .version = $v end' \
    "$pkg/package.json" > "$tmp"
  mv "$tmp" "$pkg/package.json"
  echo "  Updated $pkg/package.json"
done
echo "Done."
