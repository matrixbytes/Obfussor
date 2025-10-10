# Obfuscation Techniques Overview

This section covers the various obfuscation techniques implemented in Obfussor. Each technique serves a specific purpose in making your code harder to reverse engineer while maintaining functional correctness.

## Why Obfuscate?

Code obfuscation transforms your source code into a functionally equivalent but structurally complex form. This protects your intellectual property by:

- Making reverse engineering significantly more time-consuming
- Hiding proprietary algorithms and business logic
- Deterring casual pirates and competitors
- Protecting against automated analysis tools

## Available Techniques

### Control Flow Flattening

Transforms the natural control flow of your program into a state machine with a central dispatcher. Instead of following a linear or branching path, execution jumps through a switch statement, making it difficult to understand the program's logic flow.

**Best for:** Complex algorithms, proprietary business logic  
**Impact:** High protection, moderate performance overhead

[Learn more →](./control-flow-flattening.md)

### String Encryption

Encrypts all string literals in your code at compile time and decrypts them at runtime when needed. This prevents static analysis tools from extracting meaningful strings like error messages, URLs, or configuration values.

**Best for:** Protecting sensitive strings, hiding internal messages  
**Impact:** Medium protection, low performance overhead

[Learn more →](./string-encryption.md)

### Bogus Code Injection

Inserts dead code paths, fake control flow, and misleading operations that never execute but appear legitimate during analysis. This creates noise that confuses both human analysts and automated decompilers.

**Best for:** General protection, increasing analysis complexity  
**Impact:** High protection, minimal performance overhead

[Learn more →](./bogus-code-injection.md)

### Instruction Substitution

Replaces simple operations with mathematically equivalent but more complex sequences. For example, `x = x + 1` might become `x = (x ^ 0xFF) - (~0x100)` or similar complex expressions.

**Best for:** Arithmetic-heavy code, cryptographic implementations  
**Impact:** Medium protection, low to medium performance overhead

[Learn more →](./instruction-substitution.md)

### Function Inlining and Outlining

Manipulates function boundaries by selectively inlining small functions and outlining (extracting) portions of larger functions. This obscures the original program structure and makes it harder to identify function boundaries.

**Best for:** Hiding function relationships, obscuring call graphs  
**Impact:** Medium protection, minimal performance overhead

[Learn more →](./function-inlining.md)

## Combining Techniques

The real power of Obfussor comes from combining multiple techniques. Each technique protects against different types of analysis, so using them together creates layers of defense:

```text
Original Code
    ↓
Control Flow Flattening (restructure logic)
    ↓
String Encryption (hide static data)
    ↓
Instruction Substitution (complicate operations)
    ↓
Bogus Code Injection (add noise)
    ↓
Hardened Binary
```

## Performance Considerations

Different techniques have different performance profiles:

| Technique                | Compilation Time | Binary Size | Runtime Speed |
| ------------------------ | ---------------- | ----------- | ------------- |
| Control Flow Flattening  | +30-50%          | +20-40%     | -5-15%        |
| String Encryption        | +10-20%          | +5-10%      | -2-5%         |
| Bogus Code Injection     | +20-40%          | +30-60%     | ~0%           |
| Instruction Substitution | +15-30%          | +10-20%     | -3-10%        |
| Function Manipulation    | +10-25%          | +5-15%      | -1-5%         |

These are approximate values and will vary based on your codebase structure and configuration.

## Choosing an Intensity Level

Obfussor provides three preset intensity levels:

### Low Intensity

- String encryption only
- Fast compilation
- Minimal binary bloat
- Good for: Development builds, non-critical code

### Medium Intensity (Default)

- String encryption
- Control flow flattening
- Bogus code injection
- Instruction substitution
- Opaque predicates
- Good for: Most production scenarios

### High Intensity

- All techniques enabled
- Maximum protection
- Longer compilation times
- Good for: Highly sensitive code, premium features

### Custom

- Fine-grained control over each technique
- Configure based on specific needs
- Good for: Advanced users with specific requirements

## Next Steps

Explore each technique in detail to understand how they work and when to use them. The implementation details section covers how these techniques are realized in Obfussor's architecture.
