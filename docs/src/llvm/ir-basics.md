# LLVM IR Basics

LLVM Intermediate Representation (IR) is the core language that LLVM uses for program analysis and transformation. Understanding LLVM IR is essential for working with obfuscation techniques, as all transformations operate on this representation.

## What is LLVM IR?

LLVM IR is a low-level, typed, assembly-like language that serves as a universal intermediate format between high-level source code and machine code. It combines:

- **Low-level operations**: Close to machine instructions but platform-independent
- **Type safety**: Strong static typing prevents invalid operations
- **SSA form**: Static Single Assignment for optimization
- **Readability**: Human-readable text format

## Three Representations

LLVM IR exists in three equivalent forms:

### 1. Human-Readable Assembly (.ll files)
```llvm
define i32 @add(i32 %a, i32 %b) {
  %result = add i32 %a, %b
  ret i32 %result
}
```

### 2. Bitcode (binary .bc files)
Compact binary format for storage and transmission:
```bash
llvm-as source.ll -o source.bc
llvm-dis source.bc -o source.ll
```

### 3. In-Memory Representation
C++ objects used by the compiler:
```cpp
Function *F = ...;
BasicBlock *BB = ...;
Instruction *I = ...;
```

## Basic Structure

### Module

The top-level container representing a compilation unit:

```llvm
; ModuleID = 'example.c'
source_filename = "example.c"
target datalayout = "..."
target triple = "x86_64-unknown-linux-gnu"

; Global variables
@global_var = global i32 42

; Function declarations
declare i32 @external_func(i32)

; Function definitions
define i32 @my_function(i32 %param) {
  ; ... function body ...
}
```

### Functions

Functions are the primary unit of code:

```llvm
define <return_type> @function_name(<parameters>) {
  ; function body
}
```

**Example:**
```llvm
define i32 @multiply(i32 %x, i32 %y) {
entry:
  %result = mul i32 %x, %y
  ret i32 %result
}
```

### Basic Blocks

Basic blocks are sequences of instructions with single entry and exit:

```llvm
define i32 @example(i32 %n) {
entry:                              ; First basic block
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %positive, label %negative

positive:                           ; Second basic block
  %pos_result = add i32 %n, 1
  ret i32 %pos_result

negative:                           ; Third basic block
  %neg_result = sub i32 0, %n
  ret i32 %neg_result
}
```

**Rules:**
- Must have exactly one entry (label)
- Must have exactly one terminator (ret, br, switch, etc.)
- No branches except at the end

### Instructions

Instructions are operations within basic blocks:

```llvm
%result = add i32 %x, %y          ; Arithmetic
%ptr = getelementptr i32, i32* %base, i32 %offset  ; Memory
store i32 %value, i32* %ptr       ; Memory write
%loaded = load i32, i32* %ptr     ; Memory read
br label %next                     ; Control flow
```

## Type System

LLVM IR has a rich, strongly-typed type system:

### Primitive Types

#### Integer Types
```llvm
i1      ; Boolean (1 bit)
i8      ; Byte (8 bits)
i16     ; Short (16 bits)
i32     ; Int (32 bits)
i64     ; Long (64 bits)
i128    ; 128-bit integer
```

#### Floating Point Types
```llvm
half    ; 16-bit floating point
float   ; 32-bit floating point (IEEE 754)
double  ; 64-bit floating point (IEEE 754)
x86_fp80 ; 80-bit floating point (x87)
fp128   ; 128-bit floating point
```

#### Special Types
```llvm
void    ; No value (for functions)
label   ; Basic block labels
metadata ; Metadata for debug info
```

### Derived Types

#### Pointers
```llvm
i32*           ; Pointer to 32-bit integer
i8**           ; Pointer to pointer to 8-bit integer
void (i32)*    ; Pointer to function taking i32, returning void
```

#### Arrays
```llvm
[10 x i32]           ; Array of 10 32-bit integers
[5 x [3 x double]]   ; 2D array of doubles
```

#### Structures
```llvm
{i32, i8*, double}              ; Packed structure
{i32, [10 x i8], i32*}         ; With array member
%struct.Point = type {float, float}  ; Named structure
```

#### Vectors
```llvm
<4 x i32>      ; Vector of 4 32-bit integers (SIMD)
<8 x float>    ; Vector of 8 floats
```

## Static Single Assignment (SSA)

Every value in LLVM IR is assigned exactly once:

### Non-SSA (C-like):
```c
int x = 5;
x = x + 1;
x = x * 2;
```

### SSA (LLVM IR):
```llvm
%x1 = alloca i32
store i32 5, i32* %x1
%x2 = load i32, i32* %x1
%x3 = add i32 %x2, 1
store i32 %x3, i32* %x1
%x4 = load i32, i32* %x1
%x5 = mul i32 %x4, 2
```

### Phi Nodes

Phi nodes merge values from different control flow paths:

```llvm
define i32 @select_max(i32 %a, i32 %b) {
entry:
  %cmp = icmp sgt i32 %a, %b
  br i1 %cmp, label %if.then, label %if.else

if.then:
  br label %if.end

if.else:
  br label %if.end

if.end:
  %result = phi i32 [ %a, %if.then ], [ %b, %if.else ]
  ret i32 %result
}
```

The phi node selects:
- `%a` if coming from `%if.then`
- `%b` if coming from `%if.else`

## Instruction Categories

### Arithmetic Instructions

```llvm
; Integer arithmetic
%sum = add i32 %a, %b
%diff = sub i32 %a, %b
%prod = mul i32 %a, %b
%quot = sdiv i32 %a, %b    ; Signed division
%rem = srem i32 %a, %b     ; Signed remainder

; Floating point arithmetic
%fsum = fadd float %x, %y
%fdiff = fsub float %x, %y
%fprod = fmul float %x, %y
%fquot = fdiv float %x, %y
```

### Bitwise Instructions

```llvm
%and_result = and i32 %a, %b
%or_result = or i32 %a, %b
%xor_result = xor i32 %a, %b
%shl_result = shl i32 %a, 2      ; Shift left
%lshr_result = lshr i32 %a, 2    ; Logical shift right
%ashr_result = ashr i32 %a, 2    ; Arithmetic shift right
```

### Comparison Instructions

```llvm
; Integer comparisons
%eq = icmp eq i32 %a, %b      ; Equal
%ne = icmp ne i32 %a, %b      ; Not equal
%sgt = icmp sgt i32 %a, %b    ; Signed greater than
%slt = icmp slt i32 %a, %b    ; Signed less than
%ugt = icmp ugt i32 %a, %b    ; Unsigned greater than

; Float comparisons
%feq = fcmp oeq float %x, %y  ; Ordered equal
%fgt = fcmp ogt float %x, %y  ; Ordered greater than
```

### Memory Instructions

```llvm
; Stack allocation
%ptr = alloca i32
%arr = alloca [10 x i32]

; Store
store i32 42, i32* %ptr
store i32 %value, i32* %ptr, align 4

; Load
%value = load i32, i32* %ptr
%aligned = load i32, i32* %ptr, align 4

; Pointer arithmetic
%elem_ptr = getelementptr [10 x i32], [10 x i32]* %arr, i32 0, i32 5
```

### Control Flow Instructions

```llvm
; Unconditional branch
br label %target

; Conditional branch
br i1 %condition, label %true_bb, label %false_bb

; Switch
switch i32 %value, label %default [
  i32 0, label %case0
  i32 1, label %case1
  i32 2, label %case2
]

; Return
ret i32 %result
ret void
```

### Call Instructions

```llvm
; Direct call
%result = call i32 @function(i32 %arg1, i32 %arg2)

; Indirect call through function pointer
%fn_ptr = load i32 (i32, i32)*, i32 (i32, i32)** %fptr_var
%result = call i32 %fn_ptr(i32 %arg1, i32 %arg2)

; Tail call (optimization)
%result = tail call i32 @function(i32 %arg)
```

### Conversion Instructions

```llvm
; Integer truncation/extension
%trunc = trunc i32 %value to i8
%zext = zext i8 %byte to i32      ; Zero extend
%sext = sext i8 %byte to i32      ; Sign extend

; Float conversions
%to_float = sitofp i32 %int to float
%to_int = fptosi float %f to i32

; Pointer/integer conversions
%int = ptrtoint i8* %ptr to i64
%ptr = inttoptr i64 %int to i8*

; Bitcast (reinterpret bits)
%float_bits = bitcast i32 %int to float
```

## Constants

### Integer Constants
```llvm
i32 42
i32 -17
i1 true
i1 false
```

### Floating Point Constants
```llvm
float 3.14
double 2.718281828
```

### Null and Undefined
```llvm
i32* null               ; Null pointer
i32 undef              ; Undefined value
i32 poison             ; Poison value (LLVM 12+)
```

### Aggregate Constants
```llvm
[3 x i32] [i32 1, i32 2, i32 3]
{i32, float} {i32 42, float 3.14}
<4 x i32> <i32 1, i32 2, i32 3, i32 4>
```

### Constant Expressions
```llvm
@global = global i32* getelementptr (i32, i32* @array, i32 5)
@ptr = global i8* bitcast (i32* @value to i8*)
```

## Attributes

Attributes provide additional information:

### Function Attributes
```llvm
define i32 @example() nounwind readnone {
  ret i32 42
}

; Common attributes:
; - nounwind: doesn't throw exceptions
; - readnone: doesn't read/write memory
; - readonly: doesn't write memory
; - alwaysinline: force inline
; - noinline: prevent inlining
```

### Parameter Attributes
```llvm
define void @example(i32* noalias %ptr, i32 signext %value) {
  ; ...
}

; Common attributes:
; - noalias: pointer doesn't alias
; - readonly: parameter not modified
; - nocapture: pointer not captured
; - signext/zeroext: sign/zero extended
```

### Calling Conventions
```llvm
define fastcc i32 @fast_function(i32 %arg) {
  ; ...
}

; Conventions:
; - ccc: C calling convention (default)
; - fastcc: Fast calling convention
; - coldcc: Cold calling convention
```

## Metadata

Metadata provides debugging and optimization hints:

```llvm
define i32 @example(i32 %n) !dbg !1 {
  %result = add i32 %n, 1, !dbg !2
  ret i32 %result
}

!llvm.dbg.cu = !{!0}
!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1)
!1 = !DIFile(filename: "example.c", directory: "/path")
!2 = !DILocation(line: 5, column: 12, scope: !1)
```

## Example: Complete Function

Here's a complete example showing various IR features:

```llvm
; Function: Compute factorial
define i64 @factorial(i64 %n) {
entry:
  ; Check if n <= 1
  %cmp = icmp sle i64 %n, 1
  br i1 %cmp, label %base_case, label %recursive_case

base_case:
  ; Base case: return 1
  ret i64 1

recursive_case:
  ; Recursive case: n * factorial(n-1)
  %n_minus_1 = sub i64 %n, 1
  %rec_result = call i64 @factorial(i64 %n_minus_1)
  %result = mul i64 %n, %rec_result
  ret i64 %result
}
```

## Working with LLVM IR

### Generating IR from C

```bash
# Generate human-readable IR
clang -S -emit-llvm example.c -o example.ll

# Generate optimized IR
clang -S -emit-llvm -O2 example.c -o example_opt.ll

# Generate bitcode
clang -c -emit-llvm example.c -o example.bc
```

### Inspecting IR

```bash
# View IR
cat example.ll
less example.ll

# Disassemble bitcode
llvm-dis example.bc -o example.ll

# View with syntax highlighting
vim example.ll  # or your preferred editor
```

### Validating IR

```bash
# Check IR is well-formed
opt -verify example.ll -S -o /dev/null

# Run specific verification
opt -verify-each example.ll -S -o /dev/null
```

## IR in Obfuscation

Understanding IR is crucial for obfuscation:

### Why IR Level?

1. **Platform Independence**: Transform once, compile anywhere
2. **Rich Information**: Type and structure information available
3. **Analysis Power**: Leverage LLVM's analysis passes
4. **Composability**: Combine with standard optimizations

### Transformation Examples

**Original:**
```llvm
define i32 @simple(i32 %x) {
  %result = add i32 %x, 10
  ret i32 %result
}
```

**After Control Flow Flattening:**
```llvm
define i32 @simple(i32 %x) {
entry:
  %state = alloca i32
  store i32 0, i32* %state
  br label %dispatcher

dispatcher:
  %s = load i32, i32* %state
  switch i32 %s, label %exit [
    i32 0, label %block0
    i32 1, label %block1
  ]

block0:
  %result = add i32 %x, 10
  store i32 1, i32* %state
  br label %dispatcher

block1:
  ret i32 %result

exit:
  unreachable
}
```

## Common Patterns

### Allocating and Using Local Variables

```llvm
define void @local_vars() {
  %x = alloca i32
  store i32 42, i32* %x
  %val = load i32, i32* %x
  ; use %val...
  ret void
}
```

### Array Access

```llvm
define i32 @array_access() {
  %arr = alloca [10 x i32]
  %elem_ptr = getelementptr [10 x i32], [10 x i32]* %arr, i32 0, i32 5
  store i32 42, i32* %elem_ptr
  %val = load i32, i32* %elem_ptr
  ret i32 %val
}
```

### Structure Access

```llvm
%struct.Point = type { float, float }

define float @get_x(%struct.Point* %p) {
  %x_ptr = getelementptr %struct.Point, %struct.Point* %p, i32 0, i32 0
  %x = load float, float* %x_ptr
  ret float %x
}
```

## Summary

LLVM IR is:
- **Low-level** but **platform-independent**
- **Strongly typed** ensuring correctness
- In **SSA form** simplifying analysis
- **Human-readable** for debugging
- **The foundation** for LLVM transformations

Key concepts:
- Modules contain functions
- Functions contain basic blocks
- Basic blocks contain instructions
- All values are typed
- SSA form with phi nodes
- Rich instruction set for operations

## Next Steps

- **[LLVM Pass System](./pass-system.md)**: Learn about transformation passes
- **[Compilation Pipeline](./compilation-pipeline.md)**: See IR in the full compilation flow
- **[Obfuscation Techniques](../techniques/overview.md)**: How techniques transform IR

---

Mastering LLVM IR is essential for understanding and customizing obfuscation techniques.
