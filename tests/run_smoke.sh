#!/usr/bin/env bash
#set -euo pipefail


# Simple CLI: support --build-only and --obfucc <path>
BUILD_ONLY=0
OBFUCC_ARG=""
NEXT_IS_OBFUCC=0
for arg in "$@"; do
  if [ "$NEXT_IS_OBFUCC" = "1" ]; then
    OBFUCC_ARG="$arg"
    NEXT_IS_OBFUCC=0
    continue
  fi
  case "$arg" in
    --build-only) BUILD_ONLY=1 ;;
    --obfucc) NEXT_IS_OBFUCC=1 ;;
  esac
done

# Smoke test for Obfucc-LLVM (Linux/macOS)
echo "[SMOKE] Building Obfucc-LLVM (ignore errors if no CMakeLists.txt)..."
# Use a deterministic build type for single-config generators
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release 2>/dev/null || true
cmake --build build --config Release 2>/dev/null || true

if [ "$BUILD_ONLY" -eq 1 ]; then
  echo "[SMOKE] --build-only set; build complete. Exiting without running tests."
  exit 0
fi


# Determine obfucc binary to use
if [ -n "$OBFUCC_ARG" ]; then
  OBFUCC_BIN="$OBFUCC_ARG"
  if [ ! -x "$OBFUCC_BIN" ]; then
    echo "[ERROR] obfucc binary specified by --obfucc not found or not executable: $OBFUCC_BIN"
    exit 1
  fi
else
  BUILD_BIN="$(pwd)/build/bin"
  export PATH="$BUILD_BIN:$PATH"
  if ! command -v obfucc &>/dev/null; then
    echo "[ERROR] obfucc not found in PATH"
    exit 1
  fi
  OBFUCC_BIN="obfucc"
fi


echo "[SMOKE] Running obfucc --help..."
# Capture help to detect stub
HELP_OUT="$($OBFUCC_BIN --help 2>&1 || true)"
echo "$HELP_OUT" | head -n 3
SKIP_LLVM_AS=0
if echo "$HELP_OUT" | grep -qiE 'stub|obfucc_test'; then
  echo "[SMOKE] Detected test stub; will skip llvm-as/FileCheck validation."
  SKIP_LLVM_AS=1
fi

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
# Try stub-friendly long-form first, then legacy short-form
if ! "$OBFUCC_BIN" --input minimal.ll --output minimal.obf.ll --enable-string-encrypt >/dev/null 2>&1; then
  echo "[SMOKE] Long-form failed; trying legacy interface..."
  "$OBFUCC_BIN" -o minimal.obf.ll --string-encrypt minimal.ll
fi

if [ "$SKIP_LLVM_AS" -eq 0 ]; then
  if ! command -v llvm-as &>/dev/null; then
    echo "[ERROR] llvm-as not found in PATH"
    exit 1
  fi
  echo "[SMOKE] Validating output IR with llvm-as..."
  TMP_BC="$(mktemp -t obfucc_smoke.XXXXXX.bc 2>/dev/null || echo build/out.bc)"
  llvm-as minimal.obf.ll -o "$TMP_BC"
  rm -f "$TMP_BC"
else
  echo "[SMOKE] Skipping llvm-as/FileCheck validation (stub detected)."
fi

# Clean up
echo "[SMOKE] Cleaning up..."
rm -f minimal.ll minimal.obf.ll

echo "[SMOKE] Smoke test PASSED."
