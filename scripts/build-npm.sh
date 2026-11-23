#!/usr/bin/env bash
# Builds the npm packages for a compiler release into build/npm/:
#   @cleanlanguage/mcp                 launcher (picks the binary for this computer)
#   @cleanlanguage/mcp-<os>-<cpu>      one per platform, holds the compiler binary
#
# Usage: scripts/build-npm.sh <compiler-version>
# Reuses build/download/ from build-bundle.sh when present.
set -euo pipefail

SOURCE_REPO="${SOURCE_REPO:-Ivan-Pasco/clean-language-compiler-old}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?compiler version required (e.g. 0.33.188)}"
VERSION="${VERSION#v}"

DL="$ROOT/build/download"
OUT="$ROOT/build/npm"
rm -rf "$OUT"
mkdir -p "$DL" "$OUT"

# npm platform/arch  ->  compiler release asset
PLATFORMS=(
    "darwin arm64 cln-macos-aarch64"
    "darwin x64 cln-macos-x86_64"
    "linux x64 cln-linux-x86_64"
    "win32 x64 cln-windows-x86_64.exe"
)

for entry in "${PLATFORMS[@]}"; do
    read -r os cpu asset <<< "$entry"
    if [ ! -f "$DL/$asset" ]; then
        gh release download "v$VERSION" --repo "$SOURCE_REPO" --dir "$DL" --pattern "$asset"
    fi
    name="@cleanlanguage/mcp-$os-$cpu"
    dir="$OUT/mcp-$os-$cpu"
    bin="cln"; [ "$os" = "win32" ] && bin="cln.exe"
    mkdir -p "$dir/bin"
    cp "$DL/$asset" "$dir/bin/$bin"
    chmod +x "$dir/bin/$bin"
    jq -n --arg name "$name" --arg v "$VERSION" --arg os "$os" --arg cpu "$cpu" '{
        name: $name,
        version: $v,
        description: ("Clean Language compiler binary for " + $os + "-" + $cpu + ", used by @cleanlanguage/mcp."),
        license: "MIT",
        homepage: "https://cleanlanguage.dev",
        repository: { type: "git", url: "git+https://github.com/Ivan-Pasco/clean-language-mcp.git" },
        os: [$os],
        cpu: [$cpu],
        files: ["bin"]
    }' > "$dir/package.json"
done

mkdir -p "$OUT/mcp"
cp -R "$ROOT/npm/mcp/bin" "$OUT/mcp/bin"
cp "$ROOT/README.md" "$OUT/mcp/README.md"
deps="$(printf '%s\n' "${PLATFORMS[@]}" | awk -v v="$VERSION" '{printf "\"@cleanlanguage/mcp-%s-%s\": \"%s\"\n", $1, $2, v}' | paste -sd, -)"
jq --arg v "$VERSION" --argjson deps "{$deps}" '.version = $v | .optionalDependencies = $deps' \
    "$ROOT/npm/mcp/package.json" > "$OUT/mcp/package.json"

echo "npm packages for v$VERSION in $OUT:"
ls "$OUT"
