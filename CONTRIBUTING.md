# Contributing to Obfussor

Thank you for your interest in contributing to Obfussor! This guide will help you set up your development environment and understand the project structure.

## Prerequisites

Before you begin, ensure you have the following tools installed on your system:

### Required Tools

1. **Node.js** (v18.0.0 or later)
   - Download from [nodejs.org](https://nodejs.org/)
   - Verify installation: `node --version`

2. **Bun** (latest version)
   - Install via PowerShell: `powershell -c "irm bun.sh/install.ps1 | iex"`
   - Or download from [bun.sh](https://bun.sh/)
   - Verify installation: `bun --version`

3. **Rust** (latest stable)
   - Install via [rustup.rs](https://rustup.rs/)
   - Run: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh` (or use the Windows installer)
   - Verify installation: `rustc --version` and `cargo --version`

4. **Tauri CLI**
   - Install after Rust setup: `cargo install tauri-cli --version "^2.0"`
   - Verify installation: `cargo tauri --version`

### Optional Tools

- **Git** - For version control
- **VS Code** - Recommended IDE with Rust and Angular extensions

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/matrixbytes/Obfussor.git
cd Obfussor
```

### 2. Install Dependencies

Install both frontend (Angular) and backend (Rust) dependencies:

```bash
# Install Node.js dependencies using Bun
bun install

# Rust dependencies are managed by Cargo and will be installed automatically
```

### 3. Verify Installation

Check that everything is working correctly:

```bash
# Check if Angular CLI is accessible
bun ng version

# Check if Tauri CLI is working
cargo tauri info
```

## Development Workflow

### Running the Application

#### Development Mode

To start the development server with hot reload:

```bash
# This starts both the Angular dev server and Tauri
cargo tauri dev
```

This command will:
- Start the Angular development server on `http://localhost:1420`
- Launch the Tauri application window
- Enable hot reload for both frontend and backend changes

#### Frontend Only

To run just the Angular application (useful for UI development):

```bash
bun start
# or
bun ng serve
```

### Building the Application

#### Development Build

```bash
bun run build
```

#### Production Build

```bash
# Build for production and create distributable packages
cargo tauri build
```

This creates platform-specific installers in `src-tauri/target/release/bundle/`.

### Available Scripts

The following scripts are available in `package.json`:

- `bun start` - Start Angular development server
- `bun run build` - Build Angular application for production
- `bun run watch` - Build Angular in watch mode
- `bun ng` - Run Angular CLI commands
- `cargo tauri` - Run Tauri CLI commands

### Testing

Currently, the project doesn't have automated tests configured. Contributions to add testing infrastructure are welcome!

## Project Structure

```
Obfussor/
├── src/                          # Angular frontend source
│   ├── app/                      # Angular application components
│   │   ├── app.component.*       # Main application component
│   │   ├── app.config.ts         # Angular application configuration
│   │   └── app.routes.ts         # Application routing
│   ├── assets/                   # Static assets (images, etc.)
│   ├── index.html               # Main HTML file
│   ├── main.ts                  # Angular application entry point
│   └── styles.css               # Global styles
├── src-tauri/                   # Tauri backend (Rust)
│   ├── src/                     # Rust source code
│   │   ├── lib.rs              # Library entry point
│   │   └── main.rs             # Main application entry point
│   ├── capabilities/           # Tauri capability definitions
│   ├── icons/                  # Application icons
│   ├── build.rs               # Build script
│   ├── Cargo.toml             # Rust dependencies and metadata
│   └── tauri.conf.json        # Tauri configuration
├── assets/                     # Project assets
├── angular.json               # Angular workspace configuration
├── package.json              # Node.js dependencies and scripts
├── tsconfig.json             # TypeScript configuration
└── README.md                 # Project documentation
```

### Key Components

- **Frontend (Angular)**: Located in `src/`, built with Angular 20.x, handles the user interface
- **Backend (Tauri/Rust)**: Located in `src-tauri/`, provides native functionality and system integration
- **Configuration**: 
  - `tauri.conf.json` - Tauri app configuration, window settings, build commands
  - `angular.json` - Angular project configuration
  - `package.json` - Node.js dependencies and npm scripts

## Troubleshooting

### Common Setup Issues

#### 1. Bun Installation Issues (Windows)

**Problem**: PowerShell execution policy prevents Bun installation

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 2. Rust/Cargo Not Found

**Problem**: `cargo: command not found` after Rust installation

**Solutions**:
- Restart your terminal/command prompt
- Add Rust to PATH manually: `%USERPROFILE%\.cargo\bin`
- Re-run the Rust installer and ensure PATH is updated

#### 3. Tauri CLI Installation Fails

**Problem**: `cargo install tauri-cli` fails with compilation errors

**Solutions**:
- Update Rust: `rustup update`
- Install with specific version: `cargo install tauri-cli --version "^2.0"`
- On Windows, ensure you have Visual Studio Build Tools or Visual Studio with C++ tools

#### 4. Angular Dependencies Issues

**Problem**: Node modules installation fails or version conflicts

**Solutions**:
- Clear cache: `bun pm cache rm`
- Delete `node_modules` and `bun.lockb`, then run `bun install` again
- Ensure Node.js version is 18.0.0 or later

#### 5. Tauri Development Server Issues

**Problem**: `cargo tauri dev` fails to start or shows blank window

**Solutions**:
- Ensure port 1420 is not in use by another application
- Check if Angular build succeeds independently: `bun start`
- Verify `tauri.conf.json` has correct `devUrl` and `beforeDevCommand`
- Clear Tauri cache: `cargo clean` in `src-tauri` directory

#### 6. Build Failures

**Problem**: Production build fails with various errors

**Solutions**:
- Ensure all dependencies are up to date
- Check that the `dist` folder is properly generated: `bun run build`
- Verify `frontendDist` path in `tauri.conf.json` matches Angular output
- On Windows, temporarily disable antivirus during build process

#### 7. Permission Issues (Windows)

**Problem**: Access denied errors during installation or build

**Solutions**:
- Run terminal as Administrator
- Exclude project directory from Windows Defender
- Check if corporate firewall/proxy is blocking downloads

### Getting Help

If you encounter issues not covered here:

1. Check existing [GitHub Issues](https://github.com/matrixbytes/Obfussor/issues)
2. Review [Tauri Documentation](https://tauri.app/)
3. Check [Angular Documentation](https://angular.io/docs)
4. Create a new issue with detailed error messages and system information

## Development Guidelines

### Code Style

- **TypeScript/Angular**: Follow Angular style guide
- **Rust**: Use `cargo fmt` to format code before committing
- **Commits**: Use conventional commit messages

### Before Submitting

1. Ensure your code builds successfully: `cargo tauri build`
2. Test your changes in development mode: `cargo tauri dev`
3. Format your code:
   - Rust: `cargo fmt`
   - TypeScript: Format using your IDE or prettier

### Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Test thoroughly
5. Submit a pull request with a clear description

## Additional Resources

- [Tauri Documentation](https://tauri.app/)
- [Angular Documentation](https://angular.io/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Bun Documentation](https://bun.sh/docs)

Thank you for contributing to Obfussor! 🚀