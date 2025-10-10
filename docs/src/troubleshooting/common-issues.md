# Common Issues

This page covers some common problems you might run into when using Obfussor and how to fix them.

## Installation Problems

### Tauri CLI not found

If you get an error saying `cargo tauri` command not found after installation:

**Solution:** Make sure cargo's bin directory is in your PATH. On Windows, restart your terminal after installing Rust. You can also try running:

```bash
cargo install tauri-cli --version "^2.0" --force
```

### Bun installation fails on Windows

Sometimes the PowerShell install script doesn't work properly.

**Solution:** Try downloading the installer directly from bun.sh or use WSL if you're comfortable with it.

## Build Issues

### LLVM not found

Error message: `Could not find LLVM installation`

**Solution:** Install LLVM from llvm.org and add it to your system PATH. Make sure the version matches what's required in the docs (usually LLVM 14+).

### Rust compilation errors

If you see errors about missing dependencies or outdated packages:

**Solution:**

1. Update Rust to the latest stable version: `rustup update`
2. Clean the build cache: `cargo clean`
3. Rebuild: `cargo build`

### Node modules issues

Sometimes npm/bun dependencies get corrupted.

**Solution:**

```bash
rm -rf node_modules
rm bun.lockb  # or package-lock.json
bun install
```

## Runtime Errors

### Application won't start

The app window opens but immediately closes.

**Solution:** Check the console logs. Usually this is because of missing dependencies or conflicting Node versions. Try using Node 18 LTS.

### Obfuscation fails silently

The obfuscation process completes but the output binary is the same as input.

**Solution:** This usually means the LLVM pass didn't run correctly. Check:

- Your input file is valid C/C++ code
- LLVM is properly configured
- You have write permissions in the output directory

### "Permission denied" errors

Can't write the obfuscated binary to disk.

**Solution:** Run the application with proper permissions or choose a different output directory where you have write access.

## Performance Issues

### Obfuscation takes too long

For large codebases, obfuscation can be slow.

**Tips:**

- Start with lighter obfuscation settings
- Obfuscate only critical parts of your code
- Use a faster machine if possible
- Consider splitting your project into modules

### High memory usage

The application uses too much RAM during obfuscation.

**Solution:** This is normal for large files. Close other applications or obfuscate smaller files separately. The LLVM IR can be memory-intensive.

## Platform-Specific Issues

### macOS: "App is damaged" warning

macOS Gatekeeper blocks the app.

**Solution:** Right-click the app and select "Open" instead of double-clicking. Or run:

```bash
xattr -cr /path/to/Obfussor.app
```

### Linux: Missing system libraries

Error about missing libssl, libgtk, etc.

**Solution:** Install required system dependencies. On Ubuntu/Debian:

```bash
sudo apt install libwebkit2gtk-4.0-dev libssl-dev libgtk-3-dev
```

## Still Having Issues?

If none of these solutions work:

1. Check the [GitHub Issues](https://github.com/matrixbytes/Obfussor/issues) to see if someone else had the same problem
2. Search existing discussions
3. Open a new issue with:
   - Your OS and version
   - Obfussor version
   - Steps to reproduce the problem
   - Any error messages you're seeing

We're here to help!
