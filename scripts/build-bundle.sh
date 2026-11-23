#!/usr/bin/env bash
# Builds clean-language-mcp.mcpb from a compiler release and writes server.json.
#
# The MCP server lives in the compiler binary (`cln mcp-server`). This script
# downloads the release binaries, wraps them into one MCP bundle, and fills in
# the registry entry with the bundle's URL and checksum.
#
# Usage: scripts/build-bundle.sh <compiler-version> [bundle-release-tag]
#   compiler-version    e.g. 0.33.188 (or "latest")
#   bundle-release-tag  tag of this repo's release, e.g. v0.33.188 (defaults to v<compiler-version>)
#
# Needs: gh, jq, lipo (macOS), zip-capable npx (@anthropic-ai/mcpb), shasum.
set -euo pipefail

SOURCE_REPO="${SOURCE_REPO:-Ivan-Pasco/clean-language-compiler-old}"
THIS_REPO="${THIS_REPO:-Ivan-Pasco/clean-language-mcp}"
BUNDLE_NAME="clean-language-mcp.mcpb"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?compiler version required (e.g. 0.33.188 or latest)}"
if [ "$VERSION" = "latest" ]; then
    VERSION="$(gh release view --repo "$SOURCE_REPO" --json tagName -q .tagName)"
fi
VERSION="${VERSION#v}"
TAG="${2:-v$VERSION}"

WORK="$ROOT/build"
STAGE="$WORK/stage"
DL="$WORK/download"
rm -rf "$WORK"
mkdir -p "$STAGE/server/darwin" "$STAGE/server/linux" "$STAGE/server/win32" "$DL"

echo "Downloading compiler v$VERSION from $SOURCE_REPO..."
gh release download "v$VERSION" --repo "$SOURCE_REPO" --dir "$DL" \
    --pattern cln-macos-aarch64 \
    --pattern cln-macos-x86_64 \
    --pattern cln-linux-x86_64 \
    --pattern cln-windows-x86_64.exe

echo "Assembling binaries..."
lipo -create "$DL/cln-macos-aarch64" "$DL/cln-macos-x86_64" -output "$STAGE/server/darwin/cln"
cp "$DL/cln-linux-x86_64" "$STAGE/server/linux/cln"
cp "$DL/cln-windows-x86_64.exe" "$STAGE/server/win32/cln.exe"
chmod +x "$STAGE/server/darwin/cln" "$STAGE/server/linux/cln"

cp "$ROOT/bundle/icon.png" "$STAGE/icon.png"
jq --arg v "$VERSION" '.version = $v' "$ROOT/bundle/manifest.json" > "$STAGE/manifest.json"

echo "Smoke test: server answers initialize..."
if [ "$(uname -s)" = "Darwin" ]; then
    reply="$(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"build","version":"1"}}}' \
        | HOME="$WORK" "$STAGE/server/darwin/cln" mcp-server 2>/dev/null | head -n 1)"
    echo "$reply" | jq -e '.result.serverInfo.version' >/dev/null || { echo "Server did not answer: $reply"; exit 1; }
fi

echo "Packing bundle..."
npx -y @anthropic-ai/mcpb validate "$STAGE/manifest.json"
npx -y @anthropic-ai/mcpb pack "$STAGE" "$WORK/$BUNDLE_NAME"

SHA="$(shasum -a 256 "$WORK/$BUNDLE_NAME" | awk '{print $1}')"
URL="https://github.com/$THIS_REPO/releases/download/$TAG/$BUNDLE_NAME"

jq --arg v "$VERSION" --arg url "$URL" --arg sha "$SHA" '
    .version = $v
    | .packages[0].identifier = $url
    | .packages[0].fileSha256 = $sha
    | .packages[1].version = $v
' "$ROOT/server.json" > "$WORK/server.json"
cp "$WORK/server.json" "$ROOT/server.json"

echo "Bundle:  $WORK/$BUNDLE_NAME ($(du -h "$WORK/$BUNDLE_NAME" | awk '{print $1}'))"
echo "SHA-256: $SHA"
echo "URL:     $URL"
