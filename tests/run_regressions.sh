#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PYTEST="$ROOT_DIR/tests/runner.py"

# support --build-only
BUILD_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --build-only) BUILD_ONLY=1 ;;
  esac
done

# List test case/check pairs
declare -a CASES=(
  "tests/cases/string_encrypt.ll::tests/cases/string_encrypt.check::--enable-string-encrypt"
  "tests/cases/control_flow_flatten.ll::tests/cases/control_flow_flatten.check::--enable-cff"
  # Add more pairs as: "tests/cases/other.ll::tests/cases/other.check::--flag"
)

for pair in "${CASES[@]}"; do
  # Split on literal '::' into case, check, flag
  rest="$pair"
  case="${rest%%::*}"
  rest="${rest#*::}"
  check="${rest%%::*}"
  flag="${rest#*::}"
  echo "Running regression case: $case (flag=$flag)"
  if [ "$BUILD_ONLY" -eq 1 ]; then
    echo "--build-only set; skipping test execution. To run tests, invoke without --build-only."
    exit 0
  fi

  # Pass the flag only if non-empty so it's a separate argv
  if [ -n "$flag" ]; then
    python3 "$PYTEST" --mode regression --case "$case" --check "$check" "$flag"
  else
    python3 "$PYTEST" --mode regression --case "$case" --check "$check"
  fi
  echo "=> PASS: $case"
done

echo "All regression tests passed."
