# Compilation Pipeline

Understanding the complete LLVM compilation pipeline is essential for knowing where and how obfuscation fits into the build process. This chapter explains the end-to-end compilation flow and how Obfussor integrates seamlessly.

## Standard LLVM Compilation Pipeline

### Complete Flow

```
Source Code (.c, .cpp)
        ↓
    Preprocessor
        ↓
Preprocessed Source (.i)
        ↓
Frontend (Clang)
        ↓
   LLVM IR (.ll or .bc)
        ↓
   Optimizer (opt)
        ↓
 Optimized LLVM IR
        ↓
   Backend (llc)
        ↓
Assembly Code (.s)
        ↓
Assembler (as)
        ↓
Object File (.o)
        ↓
  Linker (ld)
        ↓
Executable/Library
```

### Phase-by-Phase Breakdown

#### 1. Preprocessing

```bash
clang -E source.c -o source.i
```

**What Happens:**
- Includes header files (`#include`)
- Expands macros (`#define`)
- Processes conditionals (`#ifdef`)
- Removes comments

**Output:** Preprocessed source code

#### 2. Compilation to IR

```bash
clang -S -emit-llvm source.i -o source.ll
```

**What Happens:**
- Lexical analysis (tokenization)
- Syntax analysis (parsing)
- Semantic analysis (type checking)
- IR generation

**Output:** LLVM IR (human-readable `.ll` or bitcode `.bc`)

#### 3. Optimization

```bash
opt -O3 source.ll -S -o source_opt.ll
```

**What Happens:**
- Analysis passes gather information
- Transformation passes modify IR
- Dead code elimination
- Function inlining
- Loop optimizations
- Constant propagation

**Output:** Optimized LLVM IR

#### 4. Backend Compilation

```bash
llc -O2 source_opt.ll -o source.s
```

**What Happens:**
- Instruction selection
- Register allocation
- Instruction scheduling
- Code emission

**Output:** Assembly code for target architecture

#### 5. Assembly

```bash
as source.s -o source.o
```

**What Happens:**
- Convert assembly to machine code
- Generate object file format (ELF, Mach-O, COFF)

**Output:** Object file

#### 6. Linking

```bash
ld source.o -o executable
# Or using clang:
clang source.o -o executable
```

**What Happens:**
- Resolve symbols
- Combine object files
- Link libraries
- Generate executable

**Output:** Final executable or library

## Obfuscation-Enhanced Pipeline

### Where Obfuscation Fits

```
Source Code
        ↓
    Frontend
        ↓
   LLVM IR
        ↓
┌───────────────────┐
│ OBFUSCATION LAYER │ ← Obfussor operates here
│                   │
│ • Control Flow    │
│ • String Encrypt  │
│ • Bogus Code      │
│ • Inst. Subst.    │
└───────────────────┘
        ↓
Obfuscated LLVM IR
        ↓
   Optimizer
        ↓
    Backend
        ↓
Obfuscated Binary
```

### Obfuscation Pipeline

```bash
# 1. Compile to IR
clang -S -emit-llvm source.c -o source.ll

# 2. Apply obfuscation passes
opt -load ObfuscatorPass.so \
    -control-flow-flattening \
    -string-encryption \
    -bogus-control-flow \
    source.ll -S -o obfuscated.ll

# 3. Optimize obfuscated IR
opt -O2 obfuscated.ll -S -o obfuscated_opt.ll

# 4. Compile to binary
llc obfuscated_opt.ll -o obfuscated.s
clang obfuscated.s -o program
```

## Integration Methods

### Method 1: Standalone Pass

Apply obfuscation as separate compilation step:

```bash
# Standard pipeline with obfuscation inserted
clang -S -emit-llvm source.c -o source.ll
obfussor-cli obfuscate --input source.ll --output obf.ll
opt -O2 obf.ll -S -o obf_opt.ll
llc obf_opt.ll -o obf.s
clang obf.s -o program
```

### Method 2: Integrated with opt

Load obfuscation passes into opt:

```bash
opt -load /path/to/ObfuscatorPass.so \
    -control-flow-flattening \
    -string-encryption \
    -O2 \
    source.ll -o obfuscated.bc
```

### Method 3: Compiler Plugin

Use Clang plugin interface:

```bash
clang -fplugin=/path/to/ObfuscatorPlugin.so \
      -mllvm -obfuscate \
      source.c -o program
```

### Method 4: LTO (Link-Time Optimization)

Apply obfuscation during link time:

```bash
# Compile with LTO
clang -flto -c source1.c -o source1.o
clang -flto -c source2.c -o source2.o

# Link with obfuscation
clang -flto source1.o source2.o \
      -Wl,-mllvm=-obfuscate \
      -o program
```

## Obfussor CLI Integration

### Basic Usage

```bash
obfussor-cli obfuscate \
  --input source.c \
  --output obfuscated \
  --techniques cff,str,bog
```

**Internal Pipeline:**
```
source.c → clang → IR → Obfuscation Passes → opt → llc → Binary
```

### Advanced Configuration

```bash
obfussor-cli obfuscate \
  --input source.c \
  --output obfuscated \
  --config obf-config.json \
  --ir-output obfuscated.ll \
  --optimization-level O2
```

**With Custom Passes:**
```bash
obfussor-cli obfuscate \
  --input source.c \
  --output obfuscated \
  --custom-pass /path/to/MyPass.so \
  --pass-options "level=5,seed=42"
```

## Build System Integration

### Makefile Integration

```makefile
CC = clang
OBFUSSOR = obfussor-cli
OPT_LEVEL = -O2

# Obfuscation rules
%.ll: %.c
$(CC) -S -emit-llvm $< -o $@

%.obf.ll: %.ll
$(OBFUSSOR) obfuscate --input $< --output $@

%.o: %.obf.ll
$(CC) -c $< -o $@

# Link
program: main.o utils.o
$(CC) $(OPT_LEVEL) $^ -o $@

.PHONY: clean
clean:
rm -f *.ll *.o program
```

### CMake Integration

```cmake
# Find LLVM
find_package(LLVM REQUIRED CONFIG)
include_directories(${LLVM_INCLUDE_DIRS})

# Custom command for obfuscation
function(add_obfuscated_executable target)
    set(sources ${ARGN})
    set(obfuscated_sources "")
    
    foreach(src ${sources})
        # Generate IR
        set(ir_file "${CMAKE_BINARY_DIR}/${src}.ll")
        add_custom_command(
            OUTPUT ${ir_file}
            COMMAND ${CMAKE_C_COMPILER} -S -emit-llvm 
                    ${CMAKE_SOURCE_DIR}/${src} -o ${ir_file}
            DEPENDS ${src}
        )
        
        # Obfuscate IR
        set(obf_file "${CMAKE_BINARY_DIR}/${src}.obf.ll")
        add_custom_command(
            OUTPUT ${obf_file}
            COMMAND obfussor-cli obfuscate 
                    --input ${ir_file} --output ${obf_file}
            DEPENDS ${ir_file}
        )
        
        list(APPEND obfuscated_sources ${obf_file})
    endforeach()
    
    add_executable(${target} ${obfuscated_sources})
endfunction()

# Usage
add_obfuscated_executable(my_program main.c utils.c)
```

### Bazel Integration

```python
# BUILD file
load("//tools:obfuscation.bzl", "obfuscated_cc_binary")

obfuscated_cc_binary(
    name = "my_program",
    srcs = ["main.c", "utils.c"],
    obfuscation_config = "obf-config.json",
)
```

## Multi-File Projects

### Approach 1: Individual File Obfuscation

```bash
# Obfuscate each file separately
for src in *.c; do
    clang -S -emit-llvm $src -o ${src%.c}.ll
    obfussor-cli obfuscate --input ${src%.c}.ll --output ${src%.c}.obf.ll
done

# Compile and link
clang *.obf.ll -o program
```

### Approach 2: Whole Program Obfuscation

```bash
# Combine all source files
llvm-link $(find . -name "*.ll") -S -o combined.ll

# Obfuscate combined IR
obfussor-cli obfuscate --input combined.ll --output obfuscated.ll

# Compile to binary
llc obfuscated.ll -o obfuscated.s
clang obfuscated.s -o program
```

### Approach 3: LTO-based

```bash
# Compile with LTO
clang -flto -c *.c

# Link with obfuscation at link time
clang -flto -fuse-ld=gold -Wl,-plugin-opt=obfuscate *.o -o program
```

## Cross-Compilation

### Targeting Different Architectures

```bash
# Compile for ARM64
clang -target aarch64-linux-gnu -S -emit-llvm source.c -o source.ll

# Obfuscate (platform-independent)
obfussor-cli obfuscate --input source.ll --output obf.ll

# Compile for ARM64
llc -march=aarch64 obf.ll -o obf.s
aarch64-linux-gnu-gcc obf.s -o program-arm64
```

### Multi-Target Build

```bash
#!/bin/bash

TARGETS=("x86_64-linux-gnu" "aarch64-linux-gnu" "arm-linux-gnueabi")

for target in "${TARGETS[@]}"; do
    # Generate IR (target-independent)
    clang -S -emit-llvm source.c -o source.ll
    
    # Obfuscate (once, for all targets)
    obfussor-cli obfuscate --input source.ll --output obf.ll
    
    # Compile for specific target
    llc -march=${target%%-*} obf.ll -o obf-${target}.s
    ${target}-gcc obf-${target}.s -o program-${target}
done
```

## Optimization Considerations

### Before or After Obfuscation?

#### Optimize Before Obfuscation

```bash
# Optimize first
opt -O3 source.ll -S -o optimized.ll

# Then obfuscate
obfussor-cli obfuscate --input optimized.ll --output obf.ll
```

**Pros:**
- Better performance
- Cleaner IR for obfuscation

**Cons:**
- Optimizations may undo obfuscation

#### Optimize After Obfuscation

```bash
# Obfuscate first
obfussor-cli obfuscate --input source.ll --output obf.ll

# Then optimize
opt -O2 obf.ll -S -o obf_opt.ll
```

**Pros:**
- Preserves obfuscation
- Can optimize obfuscated code

**Cons:**
- May have performance impact

#### Recommended: Both

```bash
# Light optimization before
opt -O1 source.ll -S -o pre_opt.ll

# Obfuscate
obfussor-cli obfuscate --input pre_opt.ll --output obf.ll

# Optimize after (carefully)
opt -O2 -disable-simplify-cfg obf.ll -S -o final.ll
```

## Debugging Obfuscated Code

### Preserve Debug Info

```bash
# Compile with debug info
clang -g -S -emit-llvm source.c -o source.ll

# Obfuscate while preserving debug metadata
obfussor-cli obfuscate --input source.ll --output obf.ll \
    --preserve-debug-info

# Compile with debug info
llc -filetype=obj obf.ll -o obf.o
clang -g obf.o -o program
```

### Separate Debug and Release Pipelines

```bash
# Debug build (minimal obfuscation)
obfussor-cli obfuscate \
    --input source.ll \
    --output debug.ll \
    --config debug-config.json  # Minimal obfuscation

# Release build (maximum obfuscation)
obfussor-cli obfuscate \
    --input source.ll \
    --output release.ll \
    --config release-config.json  # Maximum obfuscation
```

## Performance Profiling

### Measure Compilation Time

```bash
#!/bin/bash

echo "Baseline compilation:"
time clang -O2 source.c -o baseline

echo "With obfuscation:"
time obfussor-cli obfuscate \
    --input source.c \
    --output obfuscated \
    --config obf-config.json
```

### Measure Runtime Impact

```bash
# Build both versions
clang -O2 source.c -o baseline
obfussor-cli obfuscate --input source.c --output obfuscated

# Benchmark
echo "Baseline:"
time ./baseline

echo "Obfuscated:"
time ./obfuscated
```

## Summary

The LLVM compilation pipeline:
- Transforms source code through multiple stages
- Obfuscation integrates at IR level
- Can be applied at various points
- Supports multiple build systems
- Works with cross-compilation

Key integration points:
- Standalone obfuscation pass
- Integrated with opt
- Compiler plugin
- Link-time obfuscation

Best practices:
- Choose appropriate optimization strategy
- Use build system integration
- Consider multi-file projects
- Profile performance impact

## Next Steps

- **[Obfuscation Techniques](../techniques/overview.md)**: Learn about specific techniques
- **[Configuration](../getting-started/configuration.md)**: Configure the pipeline
- **[Advanced Topics](../advanced/performance.md)**: Optimize your pipeline

---

Understanding the pipeline enables effective obfuscation integration.
