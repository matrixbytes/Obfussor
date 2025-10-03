# LLVM - Obfussor

![Obfucc](./assets/llvm-obfucc.png)

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
