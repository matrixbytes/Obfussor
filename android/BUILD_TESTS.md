# Obfussor Android Build Proof Tests

This document provides basic test instructions and scripts to verify that the Obfussor Android APK builds successfully and is installable. These tests serve as proof that the build system is working as intended.

## 1. Clean and Build APK

Run the following command from the `android` directory:

```sh
./gradlew clean assembleDebug
```

**Expected Result:**
- The build completes without errors.
- The APK is generated at `android/app/build/outputs/apk/debug/app-debug.apk`.

## 2. Verify APK Existence

You can add a simple script to check that the APK file exists after the build. For example, in PowerShell:

```powershell
$apkPath = "android/app/build/outputs/apk/debug/app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "APK build successful: $apkPath exists."
    exit 0
} else {
    Write-Host "APK build failed: $apkPath not found."
    exit 1
}
```

## 3. (Optional) Install APK on Device/Emulator

If you have ADB installed and a device/emulator running, you can install the APK:

```sh
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
```

**Expected Result:**
- The APK installs successfully on the device/emulator.

## 4. (Optional) Automated Build Test Script

You can create a script (e.g., `test_build.ps1`) in the project root:

```powershell
# test_build.ps1
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
```

---

These steps and scripts provide meaningful, repeatable proof that the Obfussor APK builds correctly. You can include screenshots of the output or the installed app as further evidence if needed.