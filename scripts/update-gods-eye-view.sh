#!/usr/bin/env bash
set -euo pipefail

MODULE_FILE="nix/modules/apps/gods-eye-view.nix"
OWNER="bilawalsidhu"
REPO="gods-eye-view"

echo "Checking latest commit on https://github.com/$OWNER/$REPO..."
PREFETCH_JSON=$(nix shell nixpkgs#nix-prefetch-github --command nix-prefetch-github --json "$OWNER" "$REPO")

NEW_REV=$(echo "$PREFETCH_JSON" | grep -o '"rev": "[^"]*"' | head -n1 | cut -d'"' -f4)
NEW_HASH=$(echo "$PREFETCH_JSON" | grep -o '"hash": "[^"]*"' | head -n1 | cut -d'"' -f4)

OLD_REV=$(grep -E '^\s*rev = ' "$MODULE_FILE" | head -n1 | cut -d'"' -f2)

echo "Current rev: $OLD_REV"
echo "Latest rev:  $NEW_REV"

if [ "$OLD_REV" = "$NEW_REV" ]; then
  echo "God's Eye View is already at the latest commit ($NEW_REV)."
  exit 0
fi

echo "Upstream has new commits. Computing npmDepsHash for $NEW_REV..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -sSfL "https://raw.githubusercontent.com/$OWNER/$REPO/$NEW_REV/package-lock.json" > "$TMPDIR/package-lock.json"
NEW_NPM_HASH=$(nix shell nixpkgs#prefetch-npm-deps --command prefetch-npm-deps "$TMPDIR/package-lock.json")

echo "Updating $MODULE_FILE..."
sed -i "s|rev = \"[^\"]*\";|rev = \"$NEW_REV\";|" "$MODULE_FILE"
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_HASH\";|" "$MODULE_FILE"
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_NPM_HASH\";|" "$MODULE_FILE"

echo "Successfully updated $MODULE_FILE:"
echo "  rev:         $NEW_REV"
echo "  hash:        $NEW_HASH"
echo "  npmDepsHash: $NEW_NPM_HASH"
echo ""
echo "Next steps:"
echo "  1. Verify: just check"
echo "  2. Deploy: just remote-switch well-of-mimir-2"
