# PowerShell script to test Obfussor APK build
cd android
./gradlew clean assembleDebug
$apkPath = "app/build/outputs/apk/debug/app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "[PASS] APK build successful."
    exit 0
} else {
    Write-Host "[FAIL] APK build failed."
    exit 1
}
