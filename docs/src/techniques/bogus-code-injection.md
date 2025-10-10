# Bogus Code Injection

Bogus code injection, also known as dead code insertion or junk code injection, adds executable code that appears meaningful but has no effect on program behavior. This technique creates noise that confuses both automated analysis tools and human reverse engineers.

## The Concept

The goal is to make the binary larger and more complex without changing its functionality. Attackers analyzing the code must spend time determining which code paths are real and which are decoys.

Think of it as adding red herrings throughout your code - fake clues that lead nowhere but look convincing enough to waste an attacker's time.

## Types of Bogus Code

### 1. Opaque Predicates

Conditions that always evaluate the same way, but aren't obvious:

```cpp
// Original:
if (authenticate(user)) {
    grant_access();
}

// With opaque predicate:
int x = get_timestamp();
int y = (x * 2) / 2;  // Always equal to x

if (authenticate(user)) {
    grant_access();

    if (y != x) {  // Never true, but not obvious
        // Fake error handling
        log_error("Checksum mismatch");
        exit(1);
    }
}
```

The `y != x` condition can never be true, but static analysis tools may not recognize this and will analyze the dead branch as if it could execute.

### 2. Irrelevant Computations

Complex calculations that produce unused results:

```cpp
void process_data(const uint8_t* data, size_t len) {
    // Real work
    for (size_t i = 0; i < len; i++) {
        output[i] = transform(data[i]);
    }

    // Bogus computation
    volatile uint64_t dummy = 0;
    for (size_t i = 0; i < len; i++) {
        dummy ^= ((data[i] * 0x9e3779b97f4a7c15ULL) >> 32);
        dummy = (dummy << 13) | (dummy >> 51);
    }
}
```

The `dummy` variable computation looks like it might be a hash or checksum, wasting analysis time. The `volatile` keyword ensures the compiler doesn't optimize it away.

### 3. Fake Function Calls

Calls to functions that look important but do nothing:

```cpp
// Fake anti-debugging function
static void check_debugger_presence() {
    volatile int flag = 0;
    flag = flag + 1 - 1;
}

void sensitive_operation() {
    check_debugger_presence();  // Looks like anti-debug check

    // Real work here
    perform_crypto();
}
```

An analyst might spend significant time reverse engineering `check_debugger_presence` before realizing it's a no-op.

### 4. Fake Control Flow

Branches that appear reachable but never execute:

```cpp
void license_check(const char* key) {
    bool valid = verify_license(key);

    // Real path
    if (valid) {
        enable_features();
        return;
    }

    // Fake anti-piracy logic
    int hw_id = get_hardware_id();
    if ((hw_id & 0xF) == 0x5) {  // Impossible condition
        send_to_server("Pirated copy detected", hw_id);
        corrupt_installation();
        exit(1);
    }

    // Real error handling
    show_error("Invalid license");
}
```

The hardware ID check appears to be anti-piracy logic, but the condition is crafted to never be true.

## Implementation Strategies

### Random Insertion

Insert bogus code at random locations:

```rust
fn inject_bogus_code(function: &mut Function) {
    let mut rng = thread_rng();
    let basic_blocks: Vec<_> = function.basic_blocks().collect();

    for block in basic_blocks {
        if rng.gen_bool(0.3) {  // 30% chance
            let bogus = generate_bogus_block();
            insert_after(block, bogus);
        }
    }
}
```

### Contextual Injection

Place bogus code where it looks natural:

```rust
fn inject_contextual_bogus(function: &mut Function) {
    // After error checks, add fake recovery code
    for block in function.error_handling_blocks() {
        let fake_recovery = create_fake_recovery();
        append_to_block(block, fake_recovery);
    }

    // Before sensitive operations, add fake checks
    for block in function.sensitive_blocks() {
        let fake_validation = create_fake_validation();
        prepend_to_block(block, fake_validation);
    }
}
```

### Pattern-Based Generation

Create convincing bogus code based on real patterns:

```rust
fn generate_realistic_bogus() -> Vec<Instruction> {
    let patterns = vec![
        "checksum_validation",
        "anti_tamper_check",
        "license_validation",
        "debug_detection",
    ];

    let pattern = patterns.choose(&mut thread_rng()).unwrap();
    match *pattern {
        "checksum_validation" => generate_fake_checksum(),
        "anti_tamper_check" => generate_fake_tamper_check(),
        "license_validation" => generate_fake_license_check(),
        "debug_detection" => generate_fake_debug_check(),
        _ => unreachable!(),
    }
}
```

## Opaque Predicate Construction

The key to effective bogus code is creating predicates that are:

1. Always true or always false
2. Not obvious to static analysis
3. Difficult to prove mathematically

### Mathematical Identities

```cpp
// Always true
int x = get_random_value();
if ((x * x) >= 0) {  // Squares are always non-negative
    // Real code
}

// Always false
if ((x & 1) == 0 && (x & 1) == 1) {  // Impossible
    // Dead code
}
```

### Hash-Based Predicates

```cpp
uint32_t hash(uint32_t x) {
    x ^= x >> 16;
    x *= 0x85ebca6b;
    x ^= x >> 13;
    x *= 0xc2b2ae35;
    x ^= x >> 16;
    return x;
}

void protected_function() {
    uint32_t val = get_input();

    // This is designed to always be true
    if (hash(val) != 0x12345678) {  // Hash collision is astronomically unlikely
        // Real code path
        do_work();
    } else {
        // Fake path
        trigger_fake_defense();
    }
}
```

### Time-Based Predicates

```cpp
void time_based_predicate() {
    time_t now = time(NULL);

    // Always true (timestamp will never be negative)
    if (now > 0) {
        real_operation();
    } else {
        fake_easter_egg();
    }
}
```

## Bogus Code Complexity Levels

### Low Complexity

Simple assignments and arithmetic:

```cpp
volatile int _junk1 = 0;
_junk1 = _junk1 + 1;
_junk1 = _junk1 - 1;
```

**Pros:** Minimal overhead, easy to generate  
**Cons:** Obvious to human analysts

### Medium Complexity

Multiple operations with plausible logic:

```cpp
volatile uint32_t _check = get_timestamp();
_check = (_check ^ 0xDEADBEEF) * 0x5bd1e995;
_check = (_check >> 15) ^ _check;

if (_check == 0) {  // Virtually impossible
    fake_error_path();
}
```

**Pros:** Looks meaningful, harder to dismiss  
**Cons:** More code size, slight performance impact

### High Complexity

Elaborate fake algorithms:

```cpp
void bogus_validation() {
    uint8_t state[256];
    for (int i = 0; i < 256; i++) {
        state[i] = i;
    }

    uint8_t j = 0;
    for (int i = 0; i < 256; i++) {
        j = (j + state[i] + i) & 0xFF;
        uint8_t tmp = state[i];
        state[i] = state[j];
        state[j] = tmp;
    }

    volatile uint32_t checksum = 0;
    for (int i = 0; i < 256; i++) {
        checksum += state[i];
    }

    // Result is never used
}
```

**Pros:** Very convincing, looks like RC4 or similar  
**Cons:** Noticeable performance impact, larger binary

## Configuration Options

```json
{
  "bogus_code_injection": {
    "enabled": true,
    "density": 0.3,
    "complexity": "medium",
    "types": [
      "opaque_predicates",
      "fake_calls",
      "dead_branches",
      "irrelevant_computation"
    ],
    "preserve_performance": true,
    "max_size_increase": 50
  }
}
```

Options explained:

- **density:** Probability of injecting bogus code (0.0-1.0)
- **complexity:** How elaborate the bogus code is (low/medium/high)
- **types:** Which kinds of bogus code to generate
- **preserve_performance:** Limit injection in hot paths
- **max_size_increase:** Maximum binary size growth (percentage)

## Performance Impact

| Complexity | Binary Size | Runtime Speed | Analysis Time |
| ---------- | ----------- | ------------- | ------------- |
| Low        | +5-15%      | ~0%           | +20%          |
| Medium     | +20-40%     | -1-3%         | +50%          |
| High       | +40-80%     | -3-8%         | +100%         |

The analysis time column shows how much longer reverse engineering takes - the real benefit of this technique.

## Combining with Other Techniques

Bogus code injection is most effective when combined with:

### Control Flow Flattening

Add fake cases to the dispatcher:

```cpp
switch (state) {
    case 0x1234:
        real_operation_1();
        break;

    case 0x5678:  // Fake case, never reached
        fake_operation();
        break;

    case 0x9abc:
        real_operation_2();
        break;
}
```

### String Encryption

Add fake encrypted strings:

```cpp
const uint8_t fake_str[] = {0xDE, 0xAD, 0xBE, 0xEF};  // Never decrypted
const uint8_t real_str[] = {0x48, 0x65, 0x6C, 0x6C};  // "Hell"
```

### Instruction Substitution

Make bogus code look more complex:

```cpp
// Instead of: _junk = 0;
_junk = ((_junk ^ 0xFF) & 0x00) | ((_junk << 8) >> 8);
```

## Best Practices

1. **Be strategic** - Focus on protecting sensitive areas
2. **Stay realistic** - Bogus code should look plausible
3. **Vary patterns** - Don't repeat the same bogus code everywhere
4. **Watch performance** - Don't inject in hot loops
5. **Test thoroughly** - Ensure bogus code doesn't cause crashes

## Anti-Pattern: Obviously Dead Code

Avoid code that's trivially identified as dead:

```cpp
// BAD: Obviously unreachable
if (false) {
    fake_code();
}

// BAD: Clearly unused
int unused_var = 42;

// BAD: No-op loop
for (int i = 0; i < 0; i++) {
    do_nothing();
}
```

Instead, make it non-obvious:

```cpp
// GOOD: Opaque condition
if ((get_pid() & 0) == 1) {  // Always false, but not obvious
    fake_anti_debug();
}

// GOOD: Volatile usage suggests it matters
volatile int check = compute_complex_value();

// GOOD: Loop looks normal
for (int i = 0; i < (compute() & 0); i++) {  // Bound is always 0
    fake_validation();
}
```

## Security Considerations

Bogus code injection alone won't stop a determined attacker, but it:

- **Increases reverse engineering cost** - More time and effort required
- **Defeats automated tools** - Increase false positives in analysis
- **Obscures real logic** - Harder to identify critical code paths
- **Psychological effect** - Analysts may give up when faced with too much complexity

## Example: Complete Protection

```cpp
// Original sensitive function
bool check_license(const char* key) {
    return strcmp(key, SECRET_KEY) == 0;
}

// After bogus code injection
bool check_license(const char* key) {
    // Fake hardware check
    volatile uint64_t hw = get_hardware_id();
    if ((hw & 0x1) == 0x2) {  // Impossible
        send_telemetry("hw_mismatch");
        return false;
    }

    // Fake timing check
    uint64_t start = rdtsc();
    volatile int dummy = 0;
    for (int i = 0; i < 100; i++) {
        dummy += i;
    }
    uint64_t elapsed = rdtsc() - start;

    if (elapsed < 0) {  // Impossible (time always increases)
        anti_debug_detected();
        exit(1);
    }

    // Real check (hidden among fakes)
    bool result = strcmp(key, SECRET_KEY) == 0;

    // More fake validation
    if ((result & 0x2) == 0x2) {  // Impossible for bool
        trigger_fake_flag();
    }

    return result;
}
```

An analyst sees multiple checks and must determine which are real - a time-consuming process.

## Further Reading

- [Opaque Predicates in LLVM](../implementation/rust-backend.md#opaque-predicates)
- [Binary Size Analysis](../advanced/performance.md#size-impact)
- [Combining Techniques](./overview.md#combining-techniques)
