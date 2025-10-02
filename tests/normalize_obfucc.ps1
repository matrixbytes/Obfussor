<#
Normalize built obfucc path helper for local testing.
This mirrors the 'Normalize built obfucc path (Windows)' step in
.github/workflows/tests.yml so you can run it locally before pushing.
#>
try {
    $dst = Join-Path (Get-Location) 'build\Release\obfucc.exe'
    $candidates = @(
        'build\obfucc.exe',
        'build\bin\obfucc.exe',
        'build\Release\obfucc_test.exe',
        'build\obfucc_test.exe'
    )
    $found = $null
    foreach ($p in $candidates) {
        if (Test-Path $p) {
            $found = (Resolve-Path $p).ProviderPath
            break
        }
    }
    Write-Host "Normalize step: candidate found = '$found'   dst = '$dst'"

    if (-not $found) {
        Write-Host "No secondary build found; assuming obfucc already exists at $dst"
    } else {
        # Normalize both paths using .NET and compare OrdinalIgnoreCase
        $foundFull = [System.IO.Path]::GetFullPath($found).TrimEnd('\')
        $dstFull = [System.IO.Path]::GetFullPath($dst).TrimEnd('\')
        if ($foundFull.Equals($dstFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Host "Obfucc already at destination: $dstFull; skipping copy"
        } else {
            Write-Host "Copying obfucc: $foundFull -> $dstFull"
            Copy-Item -Path $found -Destination $dst -Force
            Write-Host "Copied $found -> $dst"
        }
    }
} catch {
    Write-Host "Normalization step encountered an error: $_"
    Write-Host "Attempting safe copy (best-effort)"
    if ($found -and $found -ne $dst) {
        Copy-Item -Path $found -Destination $dst -Force
        Write-Host "Copied $found -> $dst (fallback)"
    } else {
        Write-Host "Skipping copy in fallback: found='$found' dst='$dst'"
    }
}
