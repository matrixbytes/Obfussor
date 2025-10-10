# Function Inlining and Outlining

Function inlining and outlining strategically manipulate function boundaries to obscure program structure. This technique makes it harder to understand call relationships and identify logical units of code.

## Two Complementary Approaches

### Inlining: Removing Boundaries

Inlining replaces function calls with the function body:

```cpp
// Original
int add(int a, int b) {
    return a + b;
}

int compute(int x) {
    return add(x, 10) * 2;
}

// After inlining
int compute(int x) {
    // add() is now inline
    return (x + 10) * 2;
}
```

### Outlining: Creating Boundaries

Outlining extracts code segments into new functions:

```cpp
// Original
void process() {
    step1();
    step2();
    step3();
}

// After outlining
void process_part1() {
    step1();
}

void process_part2() {
    step2();
}

void process() {
    process_part1();
    process_part2();
    step3();
}
```

## Why This Works

### Breaking Mental Models

Developers think in terms of functions as logical units. By restructuring function boundaries:

- **Inlining** removes organizational clarity
- **Outlining** creates artificial structure
- Together, they hide the original design

### Defeating Analysis Tools

Many reverse engineering tools rely on function boundaries:

- **Call graph analysis** becomes misleading
- **Function signature detection** fails
- **Decompiler output** looks unnatural

## Strategic Inlining

### Small Utility Functions

Prime candidates for inlining:

```cpp
// Before
inline bool is_valid(int x) {
    return x >= 0 && x < 100;
}

void check_input(int val) {
    if (!is_valid(val)) {
        handle_error();
    }
}

// After inlining
void check_input(int val) {
    if (!(val >= 0 && val < 100)) {
        handle_error();
    }
}
```

Benefits:

- Eliminates call overhead
- Hides the validation logic's organization
- Makes the function appear more complex

### Frequently Called Functions

Functions called from many locations:

```cpp
// Before: Helper called from 10+ places
void log_debug(const char* msg) {
    if (debug_enabled) {
        fprintf(stderr, "[DEBUG] %s\n", msg);
    }
}

// After: Inlined everywhere
// Now each call site has the full code
// No single "logging function" to find
```

Advantage: Removes central point that reveals debugging structure.

### Critical Path Functions

Inline functions on the critical path for performance:

```cpp
// Before
int get_value(Cache* cache, int key) {
    if (cache_contains(cache, key)) {
        return cache_get(cache, key);
    }
    return -1;
}

// After inlining cache_contains and cache_get
int get_value(Cache* cache, int key) {
    // Inlined cache_contains
    bool found = false;
    for (int i = 0; i < cache->size; i++) {
        if (cache->entries[i].key == key) {
            found = true;
            break;
        }
    }

    if (found) {
        // Inlined cache_get
        for (int i = 0; i < cache->size; i++) {
            if (cache->entries[i].key == key) {
                return cache->entries[i].value;
            }
        }
    }

    return -1;
}
```

## Strategic Outlining

### Large Function Splitting

Break down complex functions:

```cpp
// Before: Large authentication function
bool authenticate(User* user, const char* password) {
    // Step 1: Validate input (20 lines)
    if (!user || !password) return false;
    // ... more validation

    // Step 2: Check database (30 lines)
    DB_Result result = query_database(user->id);
    // ... database logic

    // Step 3: Verify password (25 lines)
    Hash hash = compute_hash(password);
    // ... verification logic

    return success;
}

// After outlining
static bool validate_auth_input(User* user, const char* password) {
    if (!user || !password) return false;
    // ... validation
    return true;
}

static DB_Result check_user_database(int user_id) {
    DB_Result result = query_database(user_id);
    // ... database logic
    return result;
}

static bool verify_password_hash(const char* password, Hash expected) {
    Hash hash = compute_hash(password);
    // ... verification
    return matches;
}

bool authenticate(User* user, const char* password) {
    if (!validate_auth_input(user, password)) return false;
    DB_Result result = check_user_database(user->id);
    return verify_password_hash(password, result.hash);
}
```

Outlining benefits:

- Original flow is less obvious
- Each piece looks like it could be called elsewhere
- Harder to grasp the complete authentication logic

### Loop Body Extraction

Extract loop bodies into functions:

```cpp
// Before
for (int i = 0; i < count; i++) {
    // Complex processing (15 lines)
    process_item(&items[i]);
}

// After outlining
static void process_single_item(Item* item, int index) {
    // Complex processing moved here
    process_item(item);
}

for (int i = 0; i < count; i++) {
    process_single_item(&items[i], i);
}
```

### Exception Handling Paths

Outline error handling:

```cpp
// Before
void critical_operation() {
    if (!check1()) {
        log_error("Check 1 failed");
        cleanup();
        return;
    }

    if (!check2()) {
        log_error("Check 2 failed");
        cleanup();
        return;
    }

    // Main logic
}

// After outlining
static void handle_check1_failure() {
    log_error("Check 1 failed");
    cleanup();
}

static void handle_check2_failure() {
    log_error("Check 2 failed");
    cleanup();
}

void critical_operation() {
    if (!check1()) {
        handle_check1_failure();
        return;
    }

    if (!check2()) {
        handle_check2_failure();
        return;
    }

    // Main logic
}
```

## Implementation Strategies

### Inline at IR Level

Work with LLVM IR to inline precisely:

```rust
fn inline_function_call(call_inst: &CallInst, function: &Function) {
    let caller = call_inst.parent_function();
    let call_block = call_inst.parent_block();

    // Clone function body
    let body = function.body().clone();

    // Replace parameters with arguments
    for (param, arg) in function.params().zip(call_inst.arguments()) {
        body.replace_all_uses_of(param, arg);
    }

    // Insert body at call site
    call_block.insert_before(call_inst, body);

    // Replace return with direct value
    let ret_val = body.return_value();
    call_inst.replace_all_uses_with(ret_val);
    call_inst.remove();
}
```

### Outline with Region Extraction

Extract basic block sequences:

```rust
fn outline_region(blocks: &[BasicBlock], name: &str) -> Function {
    // Create new function
    let new_func = Function::new(name);

    // Identify live inputs (values defined outside region)
    let inputs = find_live_in_values(blocks);
    for input in inputs {
        new_func.add_parameter(input.type());
    }

    // Clone blocks into new function
    for block in blocks {
        new_func.add_block(block.clone());
    }

    // Identify live outputs (values used outside region)
    let outputs = find_live_out_values(blocks);
    new_func.set_return_type(/* tuple of outputs */);

    // Replace original blocks with call
    let call = create_call(&new_func, &inputs);
    replace_blocks_with_call(blocks, call);

    new_func
}
```

## Selective Application

Not all functions should be inlined or outlined:

### Good Candidates for Inlining

- Functions < 10 lines
- Called from few locations (<= 5)
- Hot path functions
- Utility functions with no state

### Good Candidates for Outlining

- Functions > 100 lines
- Code blocks with clear boundaries
- Error handling paths
- Repeated code patterns

### Avoid Inlining

- Recursive functions
- Virtual functions (C++)
- Functions with many local variables
- Already large functions

### Avoid Outlining

- Single-use code snippets
- Tightly coupled code with many dependencies
- Simple operations (< 5 lines)

## Configuration

```json
{
  "function_manipulation": {
    "enabled": true,
    "inline": {
      "enabled": true,
      "max_size": 50,
      "max_call_sites": 5,
      "aggressive": false
    },
    "outline": {
      "enabled": true,
      "min_size": 100,
      "split_loops": true,
      "extract_errors": true
    }
  }
}
```

## Performance Considerations

### Inlining Effects

**Benefits:**

- Eliminates call overhead
- Enables further optimizations
- Improves instruction cache locality

**Costs:**

- Increases code size
- May worsen instruction cache if too aggressive
- Slows compilation

### Outlining Effects

**Benefits:**

- Reduces code size if duplicated code is outlined
- Can improve instruction cache if rarely executed

**Costs:**

- Adds call overhead
- Increases call stack depth
- May prevent optimizations

| Approach           | Binary Size | Runtime Speed | Compile Time |
| ------------------ | ----------- | ------------- | ------------ |
| Aggressive Inline  | +15-30%     | +2-5% faster  | +20-40%      |
| Balanced           | +5-10%      | ~0%           | +10-15%      |
| Aggressive Outline | -5-10%      | -2-8% slower  | +10-20%      |

## Advanced Techniques

### Partial Inlining

Inline only part of a function:

```cpp
// Original
int process(int x) {
    if (unlikely_condition(x)) {
        expensive_operation();
        return special_value();
    }
    return x * 2;
}

// Partial inline: inline fast path, outline slow path
static int __cold_path(int x) {
    expensive_operation();
    return special_value();
}

int process(int x) {
    if (unlikely_condition(x)) {
        return __cold_path(x);
    }
    return x * 2;  // Fast path inlined
}
```

### Function Cloning

Create multiple copies of functions:

```cpp
// Original: One function
int compute(int x, bool flag);

// Cloned: Specialized versions
int compute_true_path(int x);   // Specialized for flag=true
int compute_false_path(int x);  // Specialized for flag=false

// Dispatch based on flag
int compute(int x, bool flag) {
    return flag ? compute_true_path(x) : compute_false_path(x);
}
```

This obscures which version actually executes in production.

### Interprocedural Outlining

Outline common code across multiple functions:

```cpp
// Before: Two functions with similar code
void func_a() {
    setup_state();
    // ... func_a specific
    teardown_state();
}

void func_b() {
    setup_state();
    // ... func_b specific
    teardown_state();
}

// After: Extracted common pattern
static void manage_state(void (*callback)()) {
    setup_state();
    callback();
    teardown_state();
}

void func_a() {
    manage_state(func_a_core);
}

void func_b() {
    manage_state(func_b_core);
}
```

## Combining with Other Techniques

### With Control Flow Flattening

Inline before flattening for maximum confusion:

```cpp
// 1. Inline helper functions
// 2. Apply control flow flattening to result
// Result: One large flattened function with no visible structure
```

### With Bogus Code Injection

Outline bogus code into fake functions:

```cpp
static void __unused_check1() {
    // Bogus validation that's never called
    volatile int x = compute_checksum();
}

static void __unused_check2() {
    // More bogus code
    volatile int y = verify_integrity();
}

// These look like they might be called via function pointers
```

### With String Encryption

Outline string decryption into separate functions:

```cpp
// Instead of inline decryption everywhere:
const char* get_string_0();
const char* get_string_1();
const char* get_string_2();

// Each is outlined, harder to find all string usage
```

## Real-World Example

Starting with clean code:

```cpp
class LicenseValidator {
    bool validate(const char* key) {
        if (!check_format(key)) return false;
        if (!check_checksum(key)) return false;
        if (!verify_signature(key)) return false;
        return true;
    }

    bool check_format(const char* key);
    bool check_checksum(const char* key);
    bool verify_signature(const char* key);
};
```

After function manipulation:

```cpp
// check_format inlined
// check_checksum split into multiple outlined pieces
// verify_signature partially inlined

class LicenseValidator {
    bool validate(const char* key) {
        // Inlined check_format
        if (strlen(key) != 20) return false;
        if (key[5] != '-' || key[11] != '-') return false;

        // Outlined checksum pieces
        if (!__checksum_part1(key)) return false;
        if (!__checksum_part2(key)) return false;

        // Partially inlined verify_signature
        if (__signature_slow_path(key)) {
            return verify_signature_cold(key);
        }
        return __signature_fast_path(key);
    }

    // Many small outlined functions
    bool __checksum_part1(const char* key);
    bool __checksum_part2(const char* key);
    bool __signature_fast_path(const char* key);
    bool __signature_slow_path(const char* key);
    bool verify_signature_cold(const char* key);
};
```

Original structure is completely obscured.

## Verification

Test that transformations preserve behavior:

```rust
#[test]
fn test_inline_correctness() {
    let original = parse_function("int add(int a, int b) { return a + b; }");
    let caller_before = parse_function("int f() { return add(1, 2); }");

    let caller_after = inline_function(&caller_before, &original);

    assert_eq!(
        execute(&caller_before),
        execute(&caller_after),
        "Inlining changed behavior"
    );
}
```

## Further Reading

- [LLVM Inlining](https://llvm.org/docs/Passes.html#inline)
- [Partial Inlining in LLVM](https://reviews.llvm.org/D54226)
- [Function Outlining Research](https://dl.acm.org/doi/10.1145/3297858.3304017)
