#!/usr/bin/env bash
set -euo pipefail

# Simple CLI: support --build-only to only configure/build the tiny test
BUILD_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --build-only) BUILD_ONLY=1 ;;
  esac
done

# Smoke test for Obfucc-LLVM (Linux/macOS)
echo "[SMOKE] Building Obfucc-LLVM..."
cmake -S . -B build
cmake --build build --config Release

if [ "$BUILD_ONLY" -eq 1 ]; then
  echo "[SMOKE] --build-only set; build complete. Exiting without running tests."
  exit 0
fi

export PATH="$(pwd)/build/bin:$PATH"

if ! command -v obfucc &>/dev/null; then
  echo "[ERROR] obfucc not found in PATH"
  exit 1
fi

echo "[SMOKE] Running obfucc --help..."
obfucc --help > /dev/null

# Create minimal IR
echo "[SMOKE] Creating minimal.ll..."
cat > minimal.ll <<EOF
; ModuleID = 'minimal'
source_filename = "minimal.c"
define i32 @main() {
  ret i32 0
}
EOF

echo "[SMOKE] Running obfucc on minimal.ll..."
obfucc -o minimal.obf.ll --string-encrypt minimal.ll

if ! command -v llvm-as &>/dev/null; then
  echo "[ERROR] llvm-as not found in PATH"
  exit 1
fi

echo "[SMOKE] Validating output IR with llvm-as..."
llvm-as minimal.obf.ll -o /dev/null

# Clean up
echo "[SMOKE] Cleaning up..."
rm -f minimal.ll minimal.obf.ll

echo "[SMOKE] Smoke test PASSED."
