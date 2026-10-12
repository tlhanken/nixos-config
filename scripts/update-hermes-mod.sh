#!/usr/bin/env bash
set -euo pipefail

PACKAGE_FILE="nix/packages/hermes-mod.nix"
LOCK_FILE="nix/packages/hermes-mod-package-lock.json"
NPM_PKG="hermes-mod"

echo "Checking latest release of $NPM_PKG on npm registry..."

METADATA=$(node -e '
const https = require("https");
https.get("https://registry.npmjs.org/'"$NPM_PKG"'/latest", res => {
  let data = "";
  res.on("data", chunk => data += chunk);
  res.on("end", () => {
    try {
      const pkg = JSON.parse(data);
      console.log(JSON.stringify({
        version: pkg.version,
        tarball: pkg.dist.tarball,
        integrity: pkg.dist.integrity
      }));
    } catch (e) {
      process.exit(1);
    }
  });
}).on("error", () => process.exit(1));
')

LATEST_VERSION=$(echo "$METADATA" | node -e 'console.log(JSON.parse(require("fs").readFileSync(0, "utf-8")).version)')
NEW_HASH=$(echo "$METADATA" | node -e 'console.log(JSON.parse(require("fs").readFileSync(0, "utf-8")).integrity)')
TARBALL_URL=$(echo "$METADATA" | node -e 'console.log(JSON.parse(require("fs").readFileSync(0, "utf-8")).tarball)')

CURRENT_VERSION=$(grep -E '^\s*version = ' "$PACKAGE_FILE" | head -n1 | cut -d'"' -f2)

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "hermes-mod is already at latest version ($CURRENT_VERSION)."
  exit 0
fi

echo "Updating $NPM_PKG from $CURRENT_VERSION to $LATEST_VERSION..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -sSfL "$TARBALL_URL" | tar -xz -C "$TMPDIR"
cd "$TMPDIR/package"

npm i --package-lock-only --ignore-scripts >/dev/null 2>&1

NEW_NPM_HASH=$(nix shell nixpkgs#prefetch-npm-deps --command prefetch-npm-deps package-lock.json)

# Return to repo root
cd - >/dev/null

cp "$TMPDIR/package/package-lock.json" "$LOCK_FILE"

# Update nix/packages/hermes-mod.nix
sed -i "s|version = \"[^\"]*\";|version = \"$LATEST_VERSION\";|" "$PACKAGE_FILE"
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_HASH\";|" "$PACKAGE_FILE"
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_NPM_HASH\";|" "$PACKAGE_FILE"

echo "Successfully updated $PACKAGE_FILE and $LOCK_FILE:"
echo "  version:     $LATEST_VERSION"
echo "  hash:        $NEW_HASH"
echo "  npmDepsHash: $NEW_NPM_HASH"
