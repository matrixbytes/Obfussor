# LLVM - Obfussor
<!-- Badges section -->
<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)  
[![GitHub stars](https://img.shields.io/github/stars/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/stargazers)  
[![GitHub forks](https://img.shields.io/github/forks/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/network/members)  
[![GitHub issues](https://img.shields.io/github/issues/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/issues)  
[![GitHub pull requests](https://img.shields.io/github/issues-pr/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/pulls)  
[![Last commit](https://img.shields.io/github/last-commit/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/commits/main)  

[![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=flat&logo=rust&logoColor=white)](https://www.rust-lang.org/)  
[![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)  
[![Angular](https://img.shields.io/badge/angular-%23DD0031.svg?style=flat&logo=angular&logoColor=white)](https://angular.io/)  
[![Tauri](https://img.shields.io/badge/tauri-%2324C8DB.svg?style=flat&logo=tauri&logoColor=%23FFFFFF)](https://tauri.app/)  
[![LLVM](https://img.shields.io/badge/LLVM-262D3A?style=flat&logo=llvm&logoColor=white)](https://llvm.org/)  
[![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?style=flat&logo=css3&logoColor=white)](https://www.w3.org/Style/CSS/)  
[![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=flat&logo=html5&logoColor=white)](https://developer.mozilla.org/docs/Web/HTML)  
[![Nix](https://img.shields.io/badge/NIX-5277C3.svg?style=flat&logo=NixOS&logoColor=white)](https://nixos.org/)

[![Hacktoberfest](https://img.shields.io/badge/Hacktoberfest-friendly-blueviolet)](https://hacktoberfest.com/)

[![Contributors](https://img.shields.io/github/contributors/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor/graphs/contributors)  
[![Code Size](https://img.shields.io/github/languages/code-size/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor)  
[![Top Language](https://img.shields.io/github/languages/top/matrixbytes/Obfussor)](https://github.com/matrixbytes/Obfussor)  
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fmatrixbytes.github.io%2FObfussor%2F)](https://matrixbytes.github.io/Obfussor/)

![Obfucc](./assets/llvm-obfucc.png)
</div>

Obfussor - LLVM is a high-performance binary obfuscation framework that leverages LLVM's compiler infrastructure to transform source code into hardened, reverse-engineering-resistant binaries. Built for scenarios where intellectual property protection is non-negotiable.

## Reference

[Using LLVM to Obfuscate Your Code During Compilation](https://www.apriorit.com/dev-blog/687-reverse-engineering-llvm-obfuscation)

## Feature goals

### Obfuscation Techniques

- **Control Flow Flattening** - Transforms natural program flow into opaque, non-linear execution paths
- **String Encryption** - Automatic encryption of all string literals with runtime decryption
- **Bogus Code Injection** - Insertion of dead code paths that are computationally indistinguishable from real logic
- **Instruction Substitution** - Replace simple instructions with semantically equivalent but complex alternatives
- **Function Inlining/Outlining** - Strategic manipulation of function boundaries to obscure program structure

### Characteristics

- **Zero-overhead abstractions** - Obfuscation applied at IR level ensures minimal runtime penalty
- **Configurable intensity levels** - Fine-tune the security/performance tradeoff
- **Resource-efficient** - Optimized for constrained environments (tested on mid-range hardware)

## Performance Metrics & Reports

The obfuscation engine generates comprehensive reports including:

### Obfuscation Metrics

- **Control Flow Complexity** - Cyclomatic complexity increase factor
- **String Protection Coverage** - Percentage of strings encrypted
- **Code Inflation Ratio** - Size increase due to obfuscation
- **Bogus Code Distribution** - Statistical analysis of injected code
- **Entropy Analysis** - Information-theoretic metrics of output randomness
