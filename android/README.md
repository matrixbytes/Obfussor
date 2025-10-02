[⬅ Back to main README](../README.md)

# Obfussor Android Build Instructions

## Prerequisites

- **Java JDK 17** (required for Gradle 8.x and Android plugin 8.x)
- **Android Studio** (recommended, includes Android SDK)
- **Android SDK** (ensure ANDROID_HOME is set or local.properties points to your SDK)
- **Gradle** (wrapper included, no need to install globally)

## Environment Setup

1. **Set JAVA_HOME to JDK 17**
   - Download JDK 17 from [Adoptium](https://adoptium.net/) or [Oracle](https://www.oracle.com/java/technologies/downloads/).
   - Set JAVA_HOME (Windows example):
     ```powershell
     setx JAVA_HOME "C:\Program Files\Java\jdk-17"
     ```
   - Restart your terminal after setting JAVA_HOME.

2. **Set ANDROID_HOME (if not using local.properties):**
   - Default path (if installed via Android Studio):
     ```powershell
     setx ANDROID_HOME "%USERPROFILE%\AppData\Local\Android\Sdk"
     ```
   - Or create a file `android/local.properties` with:
     ```
     sdk.dir=C:\Users\Usuario\AppData\Local\Android\Sdk
     ```

3. **Generate debug keystore (if missing):**
   - Run this command in PowerShell:
     ```powershell
     keytool -genkey -v -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -alias androiddebugkey -keypass android -dname "CN=Android Debug,O=Android,C=US" -keyalg RSA -keysize 2048 -validity 10000
     ```

## Building the APK

1. Open a terminal in the `android` directory.
2. Run:
   ```powershell
   ./gradlew clean assembleDebug
   ```
3. The APK will be generated at:
   ```
   app\build\outputs\apk\debug\app-debug.apk
   ```

## Changing the App Icon

1. Replace the icon file at:
   ```
   app/src/main/res/mipmap/ic_launcher.png
   ```
   with your own PNG file (recommended sizes: 48x48, 72x72, 96x96, 144x144, 192x192 for different densities).
2. Optionally, update all `mipmap-*dpi` folders for best results.

## Custom Release Signing (Optional)

To sign a release APK, set these environment variables before building:
- `RELEASE_KEYSTORE` (path to your keystore)
- `RELEASE_KEYSTORE_PASSWORD`
- `RELEASE_KEY_ALIAS`
- `RELEASE_KEY_PASSWORD`

Or edit the `signingConfigs` in `app/build.gradle` with your release credentials.

## Troubleshooting
- If you see `Unsupported class file major version`, ensure you are using JDK 17.
- If you see `resource mipmap/ic_launcher not found`, make sure the icon file exists in the correct folder.
- If you see `Cannot mutate the dependencies...`, ensure there are no duplicate or misplaced `build.gradle` files.

---

For more help, see the official [Android developer documentation](https://developer.android.com/studio/build).
