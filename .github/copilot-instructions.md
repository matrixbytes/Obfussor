# GitHub Copilot Instructions for Obfussor

Welcome to the Obfussor repository! Copilot is enabled to assist with code suggestions, documentation, and best practices. Please follow these guidelines for optimal Copilot usage in this project.

---

## Project Overview

**Obfussor** is a high-performance binary obfuscation framework leveraging LLVM's compiler infrastructure to transform source code into hardened, reverse-engineering-resistant binaries. It is designed for scenarios where intellectual property protection is critical.

- **Frontend:** Angular (TypeScript)
- **Backend:** Rust (via Tauri)
- **Goal:** Provide robust, user-friendly LLVM-based obfuscation for binaries with modern GUI and advanced configuration.

---

## Main Features & Goals

- **Control Flow Flattening:** Transform program flow into opaque, non-linear execution.
- **String Encryption:** Encrypt all string literals with runtime decryption.
- **Bogus Code Injection:** Insert dead code paths for analysis resistance.
- **Instruction Substitution:** Replace simple instructions with complex, equivalent alternatives.
- **Function Inlining/Outlining:** Manipulate function boundaries to obscure structure.
- **Configurable Intensity:** Fine-tune security vs. performance.
- **Resource-Efficient:** Minimal runtime penalty, optimized for constrained environments.

---

## Repository Structure

- `src/`: Angular frontend code (UI components, routing, styles).
- `src-tauri/`: Rust backend (LLVM integration, Tauri app).
    - `src/`: Rust source (`main.rs`, `lib.rs`)
    - `build.rs`: Backend build script.
    - `tauri.conf.json`: Tauri configuration.
- `assets/`: Images and static resources.
- `docs/`: Documentation (intro, guides, architecture, advanced topics).
- `CONTRIBUTING.md`: Contribution guidelines, workflow, and coding standards.
- `README.md`: Project overview, feature list, and references.

---

## Copilot Usage Guidelines

### Code Suggestions

- **Angular/TypeScript:** Follow existing patterns for UI components, state management, and service injection.
- **Rust Backend:** Maintain modularity, leverage idiomatic Rust, and use the `obfucc_lib` for LLVM-based transformations.
- **Obfuscation Passes:** When adding new techniques, refer to `/docs/src/techniques/` for documentation and `/src-tauri/src/` for backend implementation.
- **Configuration:** Changes to build, Tauri, or Angular config files should preserve cross-platform support.

### Best Practices

- **Documentation:** Document new features and code changes in both code comments and Markdown docs (`docs/src/`).
- **Tests:** Add or update tests for new obfuscation passes and core logic where applicable.
- **Security:** Prioritize code safety, especially in transformations, to avoid breaking binaries.
- **Performance:** Profile and benchmark new passes; optimize for minimal runtime overhead.

### Documentation & Community

- Reference the documentation in `/docs/` for technical explanations, quick start, and advanced topics.
- Use the issue tracker for bugs and feature requests.
- Contribute via pull requests, following `CONTRIBUTING.md`.

---

## When Copilot Should Decline Suggestions

Copilot should avoid generating code that:
- Disables obfuscation or weakens security.
- Hardcodes sensitive information.
- Breaks cross-platform or build compatibility.
- Violates the project's coding style or architecture.

---

## References

- [LLVM Obfuscation Reference](https://www.apriorit.com/dev-blog/687-reverse-engineering-llvm-obfuscation)
- [Angular Docs](https://angular.io/) | [Tauri Docs](https://tauri.app/) | [Rust Book](https://doc.rust-lang.org/book/)

---

Thank you for contributing to Obfussor!  
For detailed guidelines, please see the `CONTRIBUTING.md` file.
