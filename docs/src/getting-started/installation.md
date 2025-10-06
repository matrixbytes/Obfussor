# Installation

This guide will walk you through installing Obfussor and all its prerequisites on your system.

## Prerequisites

Before installing Obfussor, ensure you have the following tools installed:

### Required Tools

#### 1. Node.js (v18.0.0 or later)

Node.js is required for the Angular frontend.

**Windows:**
```bash
# Download and install from nodejs.org
# Or use Chocolatey
choco install nodejs

# Verify installation
node --version
npm --version
```

**macOS:**
```bash
# Using Homebrew
brew install node

# Verify installation
node --version
npm --version
```

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Fedora
sudo dnf install nodejs

# Verify installation
node --version
npm --version
```

#### 2. Bun (Latest Version)

Bun is a fast JavaScript runtime and package manager used in this project.

**Windows:**
```powershell
# Using PowerShell
powershell -c "irm bun.sh/install.ps1 | iex"

# Verify installation
bun --version
```

**macOS/Linux:**
```bash
# Using curl
curl -fsSL https://bun.sh/install | bash

# Verify installation
bun --version
```

#### 3. Rust (Latest Stable)

Rust is required for the Tauri backend and LLVM integration.

**All Platforms:**
```bash
# Install rustup (Rust installer)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# On Windows, download and run rustup-init.exe from rustup.rs

# Follow the prompts and choose default installation

# Restart your terminal, then verify
rustc --version
cargo --version
```

**Post-Installation:**
```bash
# Update Rust to latest version
rustup update

# Add common components
rustup component add rustfmt clippy
```

#### 4. Tauri CLI

Tauri CLI is required to build and run the desktop application.

```bash
# Install Tauri CLI via Cargo
cargo install tauri-cli --version "^2.0"

# Verify installation
cargo tauri --version
```

#### 5. LLVM (Version 14.0 or later)

LLVM is the core dependency for obfuscation functionality.

**Windows:**
```bash
# Download pre-built binaries from llvm.org
# Or use Chocolatey
choco install llvm

# Add to PATH: C:\Program Files\LLVM\bin
```

**macOS:**
```bash
# Using Homebrew
brew install llvm

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
llvm-config --version
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install llvm-14 llvm-14-dev clang-14

# Fedora
sudo dnf install llvm llvm-devel clang

# Verify installation
llvm-config --version
```

### Optional Tools

#### Git
Version control for cloning the repository:

```bash
# Windows (Chocolatey)
choco install git

# macOS
brew install git

# Linux (Ubuntu/Debian)
sudo apt-get install git

# Verify
git --version
```

#### Visual Studio Code
Recommended IDE with excellent Rust, Angular, and TypeScript support:

```bash
# Download from code.visualstudio.com

# Recommended Extensions:
# - rust-analyzer
# - Angular Language Service
# - Tauri
# - ESLint
# - Prettier
```

### Platform-Specific Requirements

#### Windows

**Visual Studio Build Tools** (required for Rust compilation):

1. Download [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
2. Install with "Desktop development with C++" workload
3. Ensure the following components are selected:
   - MSVC v143 - VS 2022 C++ x64/x86 build tools
   - Windows 10/11 SDK
   - C++ CMake tools for Windows

**WebView2** (required for Tauri):
- Windows 11: Pre-installed
- Windows 10: Download [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

#### macOS

**Xcode Command Line Tools**:
```bash
xcode-select --install
```

#### Linux

**Build Dependencies**:

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y \
    libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev
```

**Fedora:**
```bash
sudo dnf install \
    webkit2gtk4.1-devel \
    openssl-devel \
    curl \
    wget \
    file \
    gtk3-devel \
    libappindicator-gtk3-devel \
    librsvg2-devel
```

**Arch Linux:**
```bash
sudo pacman -S \
    webkit2gtk \
    base-devel \
    curl \
    wget \
    file \
    openssl \
    gtk3 \
    libappindicator-gtk3 \
    librsvg
```

## Installing Obfussor

### Method 1: Clone from GitHub

```bash
# Clone the repository
git clone https://github.com/matrixbytes/Obfussor.git

# Navigate to the directory
cd Obfussor

# Install dependencies
bun install

# Verify installation
bun ng version
cargo tauri info
```

### Method 2: Download Release Binary

1. Visit [GitHub Releases](https://github.com/matrixbytes/Obfussor/releases)
2. Download the latest release for your platform:
   - Windows: `Obfussor-{version}-x64-setup.exe`
   - macOS: `Obfussor-{version}-x64.dmg` or `Obfussor-{version}-aarch64.dmg`
   - Linux: `Obfussor-{version}-amd64.AppImage` or `.deb`/`.rpm`
3. Install following platform-specific instructions

### Post-Installation Verification

Verify all components are correctly installed:

```bash
# Check Node.js
node --version  # Should be >= 18.0.0

# Check Bun
bun --version

# Check Rust
rustc --version
cargo --version

# Check Tauri
cargo tauri --version

# Check LLVM
llvm-config --version  # Should be >= 14.0

# Check Clang
clang --version
```

### Building from Source

If you cloned from GitHub, build Obfussor:

```bash
# Development build
cargo tauri dev

# Production build
cargo tauri build
```

The production build will create installers in:
- Windows: `src-tauri/target/release/bundle/msi/` or `src-tauri/target/release/bundle/nsis/`
- macOS: `src-tauri/target/release/bundle/dmg/` or `src-tauri/target/release/bundle/macos/`
- Linux: `src-tauri/target/release/bundle/appimage/` or `src-tauri/target/release/bundle/deb/`

## Environment Configuration

### Setting up LLVM Environment Variables

**Windows:**
```powershell
# Add to System Environment Variables
setx LLVM_SYS_140_PREFIX "C:\Program Files\LLVM"
setx PATH "%PATH%;C:\Program Files\LLVM\bin"
```

**macOS/Linux:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export LLVM_SYS_140_PREFIX="/usr/local/opt/llvm"
export PATH="/usr/local/opt/llvm/bin:$PATH"

# Apply changes
source ~/.zshrc  # or source ~/.bashrc
```

### Rust Environment

Ensure Rust environment is properly configured:

```bash
# Verify cargo is in PATH
which cargo

# If not found, add to PATH
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Troubleshooting Installation Issues

### Common Problems

#### 1. Bun Installation Fails on Windows

**Error:** PowerShell execution policy prevents installation

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 2. Rust/Cargo Not Found

**Error:** `cargo: command not found`

**Solution:**
- Restart terminal
- Manually add to PATH: `$HOME/.cargo/bin` (Unix) or `%USERPROFILE%\.cargo\bin` (Windows)
- Re-run Rust installer

#### 3. LLVM Not Found

**Error:** `could not find native static library 'LLVM'`

**Solution:**
```bash
# Verify LLVM is installed
llvm-config --version

# Set LLVM_SYS_140_PREFIX environment variable
export LLVM_SYS_140_PREFIX=$(llvm-config --prefix)

# Try installation again
```

#### 4. WebKit2GTK Missing (Linux)

**Error:** `Package webkit2gtk-4.1 was not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install libwebkit2gtk-4.1-dev

# Older systems may need webkit2gtk-4.0:
sudo apt-get install libwebkit2gtk-4.0-dev
```

#### 5. Tauri CLI Installation Fails

**Error:** Compilation errors during `cargo install tauri-cli`

**Solution:**
```bash
# Update Rust
rustup update

# Install with specific version
cargo install tauri-cli --version "^2.0"

# Windows: Ensure Visual Studio Build Tools are installed
```

### Getting Help

If you encounter issues not covered here:

1. Check [Troubleshooting Guide](../troubleshooting/common-issues.md)
2. Review [GitHub Issues](https://github.com/matrixbytes/Obfussor/issues)
3. Consult [Tauri Prerequisites](https://tauri.app/v1/guides/getting-started/prerequisites)
4. Open a new issue with detailed error messages

## Next Steps

Once installation is complete:

1. **[Quick Start Guide](./quickstart.md)**: Learn to obfuscate your first program
2. **[Configuration](./configuration.md)**: Understand configuration options
3. **[LLVM Overview](../llvm/overview.md)**: Learn about LLVM fundamentals

---

**Congratulations!** You now have Obfussor installed and ready to use.
