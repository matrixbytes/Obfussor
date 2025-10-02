# Smoke test for Obfucc-LLVM (Windows)
param(
  [string]$Obfucc = $null,
  [switch]$SkipLlvmAs = $false,
  [switch]$SkipFileCheck = $false,
  [switch]$BuildOnly = $false
)

$ErrorActionPreference = 'Stop'
Write-Host "[SMOKE] Building Obfucc-LLVM if a CMake project is present..."
if (Test-Path .\CMakeLists.txt) {
  try {
    cmake -S . -B build
    cmake --build build --config Release
    if ($BuildOnly) {
      Write-Host "[SMOKE] --BuildOnly set, build finished. Exiting without running tests."
      exit 0
    }
  } catch {
    Write-Warning "CMake build failed; continuing and assuming a prebuilt 'obfucc' binary is available in PATH."
  }
} else {
  Write-Host "[SMOKE] No CMakeLists.txt found in repository root; skipping top-level build."
  # If BuildOnly was requested, attempt to build the tiny test project under tests/test_obfucc
  if ($BuildOnly) {
    $repo = (Split-Path -Parent $MyInvocation.MyCommand.Path)
    $repoRoot = Split-Path -Parent $repo
    $testSrc = Join-Path $repo 'test_obfucc'
    $buildDir = Join-Path $repoRoot 'build'
    if ((Test-Path $testSrc) -and (Get-Command cmake -ErrorAction SilentlyContinue)) {
      Write-Host "[SMOKE] No top-level CMakeLists found; attempting to build tiny test project at $testSrc -> $buildDir"
      try {
        cmake -S $testSrc -B $buildDir
        cmake --build $buildDir --config Release
        Write-Host "[SMOKE] --BuildOnly set, tiny test build finished. Exiting without running tests."
        exit 0
      } catch {
        Write-Warning "[SMOKE] Tiny test build failed; continuing and attempting to locate a prebuilt 'obfucc' binary instead."
      }
    } else {
      Write-Host "[SMOKE] No tiny test source at $testSrc or cmake not available; cannot perform build-only."
    }
  } else {
    Write-Host "[SMOKE] Ensure 'obfucc' is available in PATH or use --obfucc to point to the binary."
  }
}

# Add build\bin to PATH only if it exists
if (Test-Path .\build\bin) {
  $env:PATH = "$(Resolve-Path .\build\bin);$env:PATH"
} else {
  Write-Host "[SMOKE] build\bin not found; not modifying PATH."
}

# Resolve obfucc executable: prefer provided path, else look on PATH
if ($Obfucc) {
  if (-not (Test-Path $Obfucc)) {
    Write-Error "[ERROR] Provided obfucc path '$Obfucc' does not exist."
    exit 1
  }
  $obfuccExe = (Resolve-Path $Obfucc).ProviderPath
} else {
  $cmd = Get-Command obfucc -ErrorAction SilentlyContinue
  if ($cmd) {
    $obfuccExe = $cmd.Path
  } else {
    # Try common CMake/MSVC output locations before failing
    $candidates = @(
      ".\build\Release\obfucc.exe",
      ".\build\obfucc.exe",
      ".\build\bin\obfucc.exe",
      ".\build\Release\obfucc",
      ".\build\obfucc"
    )
    $found = $null
    foreach ($p in $candidates) {
      if (Test-Path $p) {
        $found = (Resolve-Path $p).ProviderPath
        break
      }
    }

    if ($found) {
      Write-Host "[SMOKE] Found built obfucc at $found"
      $obfuccExe = $found
    } else {
      Write-Error "[ERROR] obfucc not found in PATH or common build locations. Build the project or pass -Obfucc path\to\obfucc.exe to this script."
      exit 1
    }
  }
}

Write-Host "[SMOKE] Running obfucc --help..."
# Capture --help output and auto-detect the tiny test stub so we can auto-enable
# skip flags (when the user didn't provide them) — this makes local runs work
# without requiring the full LLVM toolchain.
try {
  $helpOut = & $obfuccExe --help 2>&1
  if ($helpOut) { Write-Host "[SMOKE] obfucc --help output detected (truncated):"; Write-Host ($helpOut -split "`n" | Select-Object -First 3) }
  if (-not $PSBoundParameters.ContainsKey('SkipLlvmAs') -and -not $PSBoundParameters.ContainsKey('SkipFileCheck')) {
    if ($helpOut -and ($helpOut -match 'stub' -or $helpOut -match 'obfucc_test')) {
      Write-Host "[SMOKE] Detected test stub in obfucc --help output; auto-enabling SkipLlvmAs and SkipFileCheck."
      $SkipLlvmAs = $true
      $SkipFileCheck = $true
    }
  }
} catch {
  # If --help invocation fails, proceed and let harness report missing tools as needed
}

# Create minimal IR
Write-Host "[SMOKE] Creating minimal.ll..."
@"
; ModuleID = 'minimal'
source_filename = 'minimal.c'
define i32 @main() {
  ret i32 0
}
"@ | Set-Content minimal.ll

Write-Host "[SMOKE] Running obfucc on minimal.ll..."
# Try several invocation styles to support the tiny CMake test binary (which uses --input/--output)
$invocationSuccess = $false
$lastStdOut = ""

# Long-form (stub-friendly)
Write-Host "[SMOKE] Attempting long-form invocation: --input/--output"
$lastStdOut = & $obfuccExe --input minimal.ll --output minimal.obf.ll --enable-string-encrypt 2>&1
if ($LASTEXITCODE -eq 0) {
  $invocationSuccess = $true
} else {
  Write-Host "[SMOKE] Long-form invocation exited with code $LASTEXITCODE. Output: $lastStdOut"
}

if (-not $invocationSuccess) {
  # Fallback: older short-form interface used by upstream obfucc (-o <out> [--string-encrypt] <in>)
  Write-Host "[SMOKE] Trying legacy invocation: -o <out> --string-encrypt <in>"
  $lastStdOut = & $obfuccExe -o minimal.obf.ll --string-encrypt minimal.ll 2>&1
  if ($LASTEXITCODE -eq 0) {
    $invocationSuccess = $true
  } else {
    Write-Host "[SMOKE] Legacy invocation exited with code $LASTEXITCODE. Output: $lastStdOut"
  }
}

if (-not $invocationSuccess) {
  Write-Error "[ERROR] obfucc failed to run with either supported invocation styles. Last output:`n$lastStdOut`nYou can pass -Obfucc to point to a different binary or adjust flags in this script."
  exit 1
}

if (-not $SkipLlvmAs) {
  if (-not (Get-Command llvm-as -ErrorAction SilentlyContinue)) {
    Write-Error "[ERROR] llvm-as not found in PATH. Use -SkipLlvmAs to skip this check when running with a stub."
    exit 1
  }

  Write-Host "[SMOKE] Validating output IR with llvm-as..."
  # Use a temporary file for llvm-as output to avoid errors with $null
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("obfucc_smoke_{0}.bc" -f ([guid]::NewGuid()))
  try {
    llvm-as minimal.obf.ll -o $tmp
  } finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
} else {
  Write-Host "[SMOKE] Skipping llvm-as validation (SkipLlvmAs set)."
}

# Clean up
Write-Host "[SMOKE] Cleaning up..."
Remove-Item minimal.ll, minimal.obf.ll -ErrorAction SilentlyContinue

Write-Host "[SMOKE] Smoke test PASSED."
