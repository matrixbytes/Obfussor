# Android APK Signing for Obfussor

This project supports automatic APK signing for both debug and release builds.

## How it works
- **Debug builds** use the default Android debug keystore, or you can provide your own via environment variables.
- **Release builds** require you to provide your own keystore and credentials via environment variables.
- No secrets or keystore files are committed to the repository.

## Environment Variables
Set these variables in your shell, CI/CD, or `.env` file:

### Debug signing (optional)
- `DEBUG_KEYSTORE` (path to debug keystore, default: `~/.android/debug.keystore`)
- `DEBUG_KEYSTORE_PASSWORD` (default: `android`)
- `DEBUG_KEY_ALIAS` (default: `androiddebugkey`)
- `DEBUG_KEY_PASSWORD` (default: `android`)

### Release signing (required for release builds)
- `RELEASE_KEYSTORE` (path to your release keystore)
- `RELEASE_KEYSTORE_PASSWORD`
- `RELEASE_KEY_ALIAS`
- `RELEASE_KEY_PASSWORD`

## How to add a keystore
1. Generate a keystore (for release):
   ```sh
   keytool -genkeypair -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```
2. Store the keystore securely (never commit it).
3. Set the environment variables above.

## CI/CD
- Add your keystore and credentials as CI/CD secrets.
- Reference them as environment variables in your pipeline.

## References
- [Android official signing docs](https://developer.android.com/studio/publish/app-signing)
- [Tauri Android code signing](https://tauri.app/v1/guides/distribution/android/)

---

**Never commit keystore files or passwords to the repository!**
