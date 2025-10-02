# Accept an optional Obfucc path param and then set repo/harness paths
param(
    [string]$Obfucc = $null,
    [switch]$SkipLlvmAs = $false,
    [switch]$SkipFileCheck = $false,
    [switch]$BuildOnly = $false
)

$repo = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pytest = Join-Path $repo 'runner.py'

# If no explicit Obfucc provided, try configuring/building the tiny test project once (into repo root\build)
if (-not $Obfucc) {
    $repoRoot = Split-Path -Parent $repo
    $buildDir = Join-Path $repoRoot 'build'
    $testSrc = Join-Path $repo 'test_obfucc'
    if (Get-Command cmake -ErrorAction SilentlyContinue) {
        Write-Host "Configuring test obfucc in $buildDir -> source $testSrc"
        # Configure and build explicitly; surface errors so the wrapper can fall back cleanly.
        $configArgs = @('-S', $testSrc, '-B', $buildDir)
        $buildArgs = @('--build', $buildDir, '--target', 'obfucc_test', '--config', 'Release')
        try {
            & cmake @configArgs
            & cmake @buildArgs
            if ($BuildOnly) {
                Write-Host "--BuildOnly set; build completed. Exiting without running regression cases."
                exit 0
            }
        } catch {
            Write-Warning "CMake configure/build failed; continuing and assuming obfucc is available elsewhere."
        }
        # Prefer common MSVC output locations
        $candidates = @(
            (Join-Path $buildDir 'Release\obfucc.exe'),
            (Join-Path $buildDir 'obfucc.exe'),
            (Join-Path $buildDir 'Debug\obfucc.exe')
        )
        foreach ($c in $candidates) {
        if (Test-Path $c) { $Obfucc = $c; break }
        }
    }
}

# List test case/check/flag triplets
$cases = @(
    @{ case = (Join-Path $repo 'cases\string_encrypt.ll'); check = (Join-Path $repo 'cases\string_encrypt.check'); flag = "--enable-string-encrypt" }
    @{ case = (Join-Path $repo 'cases\control_flow_flatten.ll'); check = (Join-Path $repo 'cases\control_flow_flatten.check'); flag = "--enable-cff" }
    # Add more hashtables as: @{ case = (Join-Path $repo 'cases\other.ll'); check = (Join-Path $repo 'cases\other.check'); flag = "--enable-..." }
)

foreach ($pair in $cases) {
    Write-Host "Running regression case: $($pair.case) (flag=$($pair.flag))"
    # Build argument list for python harness
    $argsList = @($pytest, '--mode', 'regression', '--case', $pair.case, '--check', $pair.check, $pair.flag)
    if ($Obfucc) {
        # If Obfucc looks like a path, ensure it exists before resolving.
        if (Test-Path $Obfucc) {
            $resolved = (Resolve-Path $Obfucc).ProviderPath
        } else {
            # Maybe the user passed an executable name to be found on PATH
            $cmd = Get-Command $Obfucc -ErrorAction SilentlyContinue
            if ($cmd) {
                $resolved = $cmd.Path
            } else {
                Write-Error "[ERROR] Provided obfucc path '$Obfucc' does not exist and was not found on PATH."
                exit 1
            }
        }

        $argsList += '--obfucc'
        $argsList += $resolved

        # Forward explicit wrapper-level skip flags if provided by the caller
        if ($SkipLlvmAs) { $argsList += '--skip-llvm-as' }
        if ($SkipFileCheck) { $argsList += '--skip-filecheck' }

        # If neither skip flag was given, try to detect whether the binary is the
        # tiny test stub by invoking `--help` and inspecting the output. If we see
        # 'stub' or 'obfucc_test' in the help text, auto-skip llvm-as and FileCheck
        # to allow local runs without the full LLVM toolchain.
        if (-not $SkipLlvmAs -and -not $SkipFileCheck) {
            try {
                $helpOut = & $resolved --help 2>&1
                if ($helpOut -and ($helpOut -match 'stub' -or $helpOut -match 'obfucc_test')) {
                    Write-Host "Detected test stub in obfucc --help output; auto-enabling --skip-llvm-as and --skip-filecheck for harness."
                    $argsList += '--skip-llvm-as'
                    $argsList += '--skip-filecheck'
                }
            } catch {
                # If invoking --help failed, don't auto-skip; let the harness report missing tools
            }
        }
    }

    # Invoke python with the argument list
    & python @argsList
    if ($LASTEXITCODE -ne 0) { throw "Regression test failed for $($pair.case) with exitcode $LASTEXITCODE" }
    Write-Host "=> PASS: $($pair.case)"
}

Write-Host "All regression tests passed."
