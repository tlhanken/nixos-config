#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo "Updating Out-of-Flake Custom Applications & Packages"
echo "========================================================"

FAILED=0

run_updater() {
  local name="$1"
  local script="$2"
  echo ""
  echo "--- [1/4] Checking $name ---"
  if "$script"; then
    echo "✔ $name up to date."
  else
    echo "✖ Failed to update $name."
    FAILED=1
  fi
}

echo ""
echo ">>> Checking God's Eye View..."
"$SCRIPT_DIR/update-gods-eye-view.sh" || FAILED=1

echo ""
echo ">>> Checking Hermes-Mod..."
"$SCRIPT_DIR/update-hermes-mod.sh" || FAILED=1

echo ""
echo "========================================================"
if [ "$FAILED" -eq 0 ]; then
  echo "All out-of-flake packages checked successfully."
  echo "========================================================"
else
  echo "One or more packages encountered an error during update."
  echo "========================================================"
  exit 1
fi
