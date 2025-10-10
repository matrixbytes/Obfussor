# Instruction Substitution

Instruction substitution replaces straightforward operations with functionally equivalent but more complex sequences. This technique makes code harder to understand without significantly impacting performance.

## Core Principle

Every simple operation can be expressed in multiple ways. For example, incrementing a variable:

```cpp
// Direct
x = x + 1;

// Substitution 1
x = x - (-1);

// Substitution 2
x = -(-x - 1);

// Substitution 3
x = (x ^ 0x01) + (x & 0x01) * 2;

// Substitution 4
x = ((x << 1) + 1) - x;
```

All produce the same result, but vary in complexity and reverse-engineering difficulty.

## Common Substitutions

### Arithmetic Operations

#### Addition

```cpp
// Original: a + b
a - (-b)
(a ^ b) + ((a & b) << 1)
(a | b) + (a & b)
```

#### Subtraction

```cpp
// Original: a - b
a + (~b) + 1
a + (b ^ 0xFFFFFFFF) + 1
(a ^ b) - ((~a & b) << 1)
```

#### Multiplication by Constants

```cpp
// Original: x * 7
(x << 3) - x
(x << 2) + (x << 1) + x
x + (x << 1) + (x << 2)
```

#### Division by Power of 2

```cpp
// Original: x / 4
x >> 2
(x + (x >> 31)) >> 2  // Handles negative numbers correctly
```

### Bitwise Operations

#### XOR

```cpp
// Original: a ^ b
(a | b) & (~a | ~b)
(a & ~b) | (~a & b)
(a + b) - 2 * (a & b)
```

#### AND

```cpp
// Original: a & b
~(~a | ~b)
(a ^ ((a ^ b) & -(a < b)))
a - (a & ~b)
```

#### OR

```cpp
// Original: a | b
a + b - (a & b)
(a & ~b) + (a & b) + (~a & b)
~(~a & ~b)
```

### Comparison Operations

#### Equality

```cpp
// Original: a == b
!(a - b)
!((a ^ b) | -(a < b | b < a))
```

#### Less Than (Unsigned)

```cpp
// Original: a < b
(a - b) >> 31
!!(~a & b & 1)  // Only works for comparing with 0/1
```

## Mixed Boolean-Arithmetic (MBA)

MBA expressions combine boolean and arithmetic operators to create highly obfuscated computations:

```cpp
// Original: x
(x & 0x55555555) + (x & 0xAAAAAAAA)
(x ^ 0x55555555) - 0x55555555 + x

// Original: x & y
(x + y) - (x | y)
(x | y) - (x ^ y)

// Original: x | y
(x & y) + (x ^ y)
(x + y) - (x & y)

// Original: x ^ y
(x | y) - (x & y)
(~x & y) | (x & ~y)
```

More complex example:

```cpp
// Original: (x + y) * 2
((x ^ y) + 2 * (x & y)) * 2
4 * (x & y) + 2 * (x ^ y)
((x | y) + (x & y)) * 2
```

## Implementation Strategy

### Pattern Matching

Identify common operations in the LLVM IR:

```rust
fn substitute_instruction(inst: &Instruction) -> Vec<Instruction> {
    match inst.opcode() {
        Opcode::Add => substitute_add(inst),
        Opcode::Sub => substitute_sub(inst),
        Opcode::Mul => substitute_mul(inst),
        Opcode::Xor => substitute_xor(inst),
        _ => vec![inst.clone()],
    }
}
```

### Random Selection

Choose from multiple equivalent forms:

```rust
fn substitute_add(inst: &AddInstruction) -> Vec<Instruction> {
    let substitutions = vec![
        generate_sub_neg(inst),
        generate_xor_and(inst),
        generate_or_and(inst),
    ];

    substitutions.choose(&mut thread_rng())
        .unwrap()
        .clone()
}
```

### Cost-Aware Selection

Balance complexity with performance:

```rust
fn substitute_with_cost(inst: &Instruction, max_cost: u32) -> Vec<Instruction> {
    let options: Vec<_> = get_substitutions(inst)
        .into_iter()
        .filter(|s| s.cost <= max_cost)
        .collect();

    if options.is_empty() {
        vec![inst.clone()]
    } else {
        options.choose(&mut thread_rng()).unwrap().instructions.clone()
    }
}
```

## Real-World Example

### Original Code

```cpp
uint32_t hash(uint32_t x) {
    x = x + 1;
    x = x * 7;
    x = x ^ 0xDEADBEEF;
    return x;
}
```

### After Instruction Substitution

```cpp
uint32_t hash(uint32_t x) {
    // x = x + 1 becomes:
    x = -(-x - 1);

    // x = x * 7 becomes:
    x = (x << 3) - x;

    // x = x ^ 0xDEADBEEF becomes:
    uint32_t tmp = x | 0xDEADBEEF;
    x = tmp - (x & 0xDEADBEEF);

    return x;
}
```

Even more aggressively:

```cpp
uint32_t hash(uint32_t x) {
    // Multi-layer substitution
    uint32_t t1 = ~x;
    uint32_t t2 = -t1;
    x = t2 + (~0u);  // x + 1

    uint32_t t3 = x << 1;
    uint32_t t4 = t3 + x;
    uint32_t t5 = t4 << 1;
    x = t5 + x;  // x * 7

    uint32_t magic = 0xDEADBEEF;
    uint32_t t6 = x & ~magic;
    uint32_t t7 = ~x & magic;
    x = t6 | t7;  // x ^ magic

    return x;
}
```

## MBA Expression Generation

Automatic generation of MBA expressions:

```rust
struct MBAGenerator {
    identity_rules: Vec<MBARule>,
}

struct MBARule {
    pattern: Expr,
    substitutions: Vec<Expr>,
}

impl MBAGenerator {
    fn new() -> Self {
        Self {
            identity_rules: vec![
                MBARule {
                    pattern: expr!("x"),
                    substitutions: vec![
                        expr!("(x & 0x55555555) + (x & 0xAAAAAAAA)"),
                        expr!("(x ^ 0x55555555) - 0x55555555 + x"),
                        expr!("(x | 0) + (x & 0)"),
                    ],
                },
                // More rules...
            ],
        }
    }

    fn generate(&self, expr: &Expr, depth: u32) -> Expr {
        if depth == 0 {
            return expr.clone();
        }

        for rule in &self.identity_rules {
            if rule.pattern.matches(expr) {
                let sub = rule.substitutions.choose(&mut thread_rng()).unwrap();
                return self.generate(sub, depth - 1);
            }
        }

        expr.clone()
    }
}
```

## Configuration

```json
{
  "instruction_substitution": {
    "enabled": true,
    "intensity": "medium",
    "operations": ["arithmetic", "bitwise", "comparisons"],
    "use_mba": true,
    "max_expansion": 4,
    "preserve_constants": false
  }
}
```

Options:

- **intensity:** How complex substitutions can be (low/medium/high)
- **operations:** Which operation types to substitute
- **use_mba:** Enable Mixed Boolean-Arithmetic expressions
- **max_expansion:** Maximum instruction count increase (multiplier)
- **preserve_constants:** Keep constant values visible or obfuscate them too

## Performance Impact

| Setting | Binary Size | Runtime Speed | Analysis Difficulty |
| ------- | ----------- | ------------- | ------------------- |
| Low     | +5-10%      | -1-2%         | +30%                |
| Medium  | +10-20%     | -3-7%         | +70%                |
| High    | +20-35%     | -8-15%        | +150%               |

Instruction substitution has moderate overhead because:

- More instructions execute per operation
- CPU pipeline may stall on complex dependencies
- Compiler optimizations are less effective

## When to Use

Effective for:

- **Cryptographic code** - Makes algorithm recognition harder
- **License checks** - Obscures validation logic
- **Checksums/hashes** - Hides integrity verification
- **Arithmetic-heavy code** - Good return on investment

Avoid in:

- **I/O operations** - Substitution doesn't help
- **Function calls** - The call itself is the bottleneck
- **Memory operations** - Access patterns are more important

## Advanced Techniques

### Constant Unfolding

Reverse of constant folding:

```cpp
// Original
int x = 42;

// Unfolded
int x = (0x15 << 1) | (0x2A & 0x0);
int x = 0x55 - 0x13;
int x = (0x7F ^ 0x55) + 0x18;
```

### Identity Function Insertion

Wrap expressions in identity functions:

```cpp
// Identity function
int id(int x) { return x; }

// Original
result = a + b;

// With identity
result = id(a) + id(b);
result = id(id(a + b));
```

Combined with inlining, this spreads code out without changing behavior.

### Constant Splitting

Break constants into computed values:

```cpp
// Original
if (x == 0xDEADBEEF) { ... }

// Split
const uint32_t part1 = 0xDEAD0000;
const uint32_t part2 = 0x0000BEEF;
if (x == (part1 | part2)) { ... }

// More obfuscated
const uint32_t a = 0x6F56DF77;
const uint32_t b = 0xFFFFFFFF;
const uint32_t target = (a ^ b) ^ 0x31529018;
if (x == target) { ... }
```

## Combining with Other Techniques

### With Control Flow Flattening

Substitute operations within flattened blocks:

```cpp
switch (state) {
    case 0x1234:
        // Substituted arithmetic
        tmp = (x | y) - (x & y);  // Instead of x ^ y
        next_state = compute_next(tmp);
        break;
}
```

### With String Encryption

Substitute operations in decryption code:

```cpp
// Original decryption
for (int i = 0; i < len; i++) {
    plain[i] = cipher[i] ^ key[i % keylen];
}

// With substitution
for (int i = 0; i < len; i++) {
    uint8_t c = cipher[i];
    uint8_t k = key[i % keylen];
    // XOR substituted with MBA
    plain[i] = (c | k) - (c & k);
}
```

### With Bogus Code

Mix substituted real code with bogus code:

```cpp
// Hard to tell which operations matter
uint32_t t1 = (x & 0x55555555) + (x & 0xAAAAAAAA);  // Real (identity)
uint32_t t2 = (t1 ^ 0x12345678) * 0x9E3779B9;       // Bogus
uint32_t t3 = (t1 | y) - (t1 & y);                   // Real (x ^ y)
if (t2 == 0) { fake_branch(); }                      // Bogus check
return t3;
```

## Limitations

Instruction substitution can't:

- Hide the program's overall structure
- Protect against dynamic analysis (values are the same at runtime)
- Prevent understanding of high-level algorithms

It works best as one layer in a multi-layered defense.

## Verification

Always test that substituted code is correct:

```rust
#[test]
fn verify_substitution() {
    let test_values = vec![0, 1, 42, 0xDEADBEEF, u32::MAX];

    for x in test_values {
        for y in test_values {
            // Original
            let original = x + y;

            // Substituted
            let substituted = (x ^ y) + ((x & y) << 1);

            assert_eq!(original, substituted,
                "Substitution failed for x={}, y={}", x, y);
        }
    }
}
```

## Further Reading

- [Mixed Boolean-Arithmetic Expressions](https://tel.archives-ouvertes.fr/tel-01623849/document)
- [MBA Simplification](https://github.com/softsec-unh/MBA-Blast)
- [LLVM IR Instruction Reference](https://llvm.org/docs/LangRef.html)
