# Quick Start

This guide will help you obfuscate your first program using Obfussor. By the end of this tutorial, you'll understand the basic workflow and be able to apply obfuscation to your own projects.

## Prerequisites

Before you begin, ensure you have:

- Completed the [Installation](./installation.md) guide
- Basic knowledge of C/C++ programming
- A simple C/C++ program to obfuscate
- LLVM toolchain properly configured

## Your First Obfuscation

### Step 1: Create a Sample Program

Let's start with a simple C program:

```c
// hello.c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    int y = 10;
    int result = add(x, y);
    
    printf("The sum of %d and %d is %d\n", x, y, result);
    printf("Hello from Obfussor!\n");
    
    return 0;
}
```

Save this as `hello.c` in your working directory.

### Step 2: Launch Obfussor

Start the Obfussor application:

```bash
# If built from source
cargo tauri dev

# Or run the installed application
./Obfussor  # Linux/macOS
# Or launch from Applications menu/Start menu
```

The Obfussor GUI will open, presenting you with the main interface.

### Step 3: Configure Obfuscation Settings

In the Obfussor interface:

1. **Select Input File**: Click "Browse" and select your `hello.c` file
2. **Choose Output Directory**: Specify where the obfuscated output should be saved
3. **Select Obfuscation Techniques**:
   - ✓ Control Flow Flattening
   - ✓ String Encryption
   - ✓ Instruction Substitution
4. **Set Intensity Level**: Choose "Medium" for this example
5. **Configure Compiler Options**:
   - Compiler: `clang`
   - Optimization Level: `-O2`
   - Target Architecture: Auto-detect

### Step 4: Run Obfuscation

Click the **"Obfuscate"** button to start the process.

Obfussor will:
1. Parse your source code to LLVM IR
2. Apply selected obfuscation passes
3. Generate obfuscated LLVM IR
4. Compile to native binary
5. Generate a detailed report

### Step 5: Review Results

After completion, you'll see:

**Obfuscation Report:**
```
Obfuscation Summary
===================
Input File: hello.c
Output File: hello_obfuscated
Techniques Applied:
  - Control Flow Flattening: ✓
  - String Encryption: ✓
  - Instruction Substitution: ✓

Metrics:
  - Functions Obfuscated: 2/2
  - Strings Encrypted: 2/2
  - Instructions Substituted: 15
  - Code Size Increase: 45%
  - Cyclomatic Complexity Increase: 3.2x

Status: Success ✓
```

### Step 6: Test the Obfuscated Program

Run the obfuscated binary to verify it works correctly:

```bash
# Navigate to output directory
cd output/

# Run the obfuscated program
./hello_obfuscated

# Expected output:
# The sum of 5 and 10 is 15
# Hello from Obfussor!
```

The program should function identically to the original!

### Step 7: Compare Original and Obfuscated

#### Original LLVM IR (simplified):
```llvm
define i32 @add(i32 %a, i32 %b) {
entry:
  %sum = add i32 %a, %b
  ret i32 %sum
}

define i32 @main() {
entry:
  %x = alloca i32
  %y = alloca i32
  store i32 5, i32* %x
  store i32 10, i32* %y
  %call = call i32 @add(i32 5, i32 10)
  ; ... printf calls ...
  ret i32 0
}
```

#### Obfuscated LLVM IR (simplified):
```llvm
define i32 @add(i32 %a, i32 %b) {
entry:
  %switch.var = alloca i32
  store i32 0, i32* %switch.var
  br label %switch.dispatch

switch.dispatch:
  %state = load i32, i32* %switch.var
  switch i32 %state, label %unreachable [
    i32 0, label %block.0
    i32 1, label %block.1
    i32 2, label %block.2
  ]

block.0:
  ; Bogus code
  %bogus1 = add i32 %a, 42
  store i32 1, i32* %switch.var
  br label %switch.dispatch

block.1:
  ; Actual computation (obfuscated)
  %t1 = sub i32 0, %b
  %t2 = sub i32 %a, %t1
  store i32 2, i32* %switch.var
  br label %switch.dispatch

block.2:
  ret i32 %t2

unreachable:
  unreachable
}
```

Notice how the control flow is flattened and the simple addition is replaced with complex instructions.

## Command Line Interface (CLI)

For automation and scripting, use the CLI:

### Basic Usage

```bash
obfussor-cli obfuscate \
  --input hello.c \
  --output hello_obfuscated \
  --techniques cff,str,sub \
  --intensity medium
```

### CLI Options

```
obfussor-cli obfuscate [OPTIONS]

OPTIONS:
  -i, --input <FILE>          Input source file
  -o, --output <FILE>         Output file name
  -t, --techniques <LIST>     Comma-separated list of techniques
                              (cff, str, bog, sub, inl)
  --intensity <LEVEL>         Obfuscation intensity (low, medium, high)
  --compiler <COMPILER>       Compiler to use (clang, gcc)
  -O <LEVEL>                  Optimization level (0, 1, 2, 3, s)
  --target <ARCH>             Target architecture
  --config <FILE>             Configuration file
  --report <FILE>             Output report file
  --ir-only                   Generate LLVM IR only (no compilation)
  -v, --verbose               Verbose output
  -h, --help                  Show help message
```

### Example: Maximum Obfuscation

```bash
obfussor-cli obfuscate \
  --input myprogram.c \
  --output myprogram_protected \
  --techniques cff,str,bog,sub,inl \
  --intensity high \
  -O2 \
  --report obfuscation-report.json \
  --verbose
```

### Example: Configuration File

Create `obfuscation-config.json`:

```json
{
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "medium",
      "preserve_functions": ["main"]
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "aes128",
      "exclude_patterns": ["debug_*"]
    },
    "instruction_substitution": {
      "enabled": true,
      "complexity": 3
    }
  },
  "compiler": {
    "name": "clang",
    "optimization": "O2",
    "flags": ["-fno-inline"]
  },
  "output": {
    "ir_file": "output.ll",
    "report_file": "report.json",
    "preserve_symbols": false
  }
}
```

Use the configuration:

```bash
obfussor-cli obfuscate \
  --input myprogram.c \
  --config obfuscation-config.json
```

## Working with Projects

### Single File Projects

```bash
obfussor-cli obfuscate \
  --input main.c \
  --output main_obf \
  --techniques cff,str
```

### Multiple Files

Obfuscate each file separately and link:

```bash
# Obfuscate each source file to LLVM IR
obfussor-cli obfuscate --input file1.c --output file1_obf.ll --ir-only
obfussor-cli obfuscate --input file2.c --output file2_obf.ll --ir-only

# Compile IR files to object files
clang -c file1_obf.ll -o file1_obf.o
clang -c file2_obf.ll -o file2_obf.o
# Link obfuscated object files
clang file1_obf.o file2_obf.o -o program_obfuscated
```

### Integration with Build Systems

#### Makefile Example

```makefile
CC = clang
OBFUSSOR = obfussor-cli

SOURCES = main.c utils.c
OBJECTS = $(SOURCES:.c=.o)
OBFUSCATED = $(SOURCES:.c=_obf.o)

all: program_obfuscated

%.o: %.c
	$(CC) -c $< -o $@

%_obf.o: %.c
	$(OBFUSSOR) obfuscate --input $< --output $@ --techniques cff,str

program_obfuscated: $(OBFUSCATED)
	$(CC) $(OBFUSCATED) -o $@

clean:
	rm -f $(OBJECTS) $(OBFUSCATED) program_obfuscated
```

#### CMake Example

```cmake
# Add custom command for obfuscation
function(add_obfuscated_executable target)
    set(SOURCES ${ARGN})
    set(OBFUSCATED_SOURCES "")
    
    foreach(source ${SOURCES})
        get_filename_component(source_name ${source} NAME_WE)
        set(obf_source "${CMAKE_BINARY_DIR}/${source_name}_obf.c")
        
        add_custom_command(
            OUTPUT ${obf_source}
            COMMAND obfussor-cli obfuscate 
                --input ${CMAKE_CURRENT_SOURCE_DIR}/${source}
                --output ${obf_source}
                --techniques cff,str
            DEPENDS ${source}
            COMMENT "Obfuscating ${source}"
        )
        
        list(APPEND OBFUSCATED_SOURCES ${obf_source})
    endforeach()
    
    add_executable(${target} ${OBFUSCATED_SOURCES})
endfunction()

# Usage
add_obfuscated_executable(my_program main.c utils.c)
```

## Verifying Obfuscation

### Visual Inspection

Compare the disassembly of original and obfuscated binaries:

```bash
# Disassemble original
objdump -d hello > hello_original.asm

# Disassemble obfuscated
objdump -d hello_obfuscated > hello_obfuscated.asm

# Compare
diff hello_original.asm hello_obfuscated.asm
```

### Using Analysis Tools

Analyze with tools like Ghidra or IDA Pro:

1. Load the original binary
2. Note the control flow graph structure
3. Load the obfuscated binary
4. Compare the complexity and readability

### Automated Testing

Ensure functionality is preserved:

```bash
# Create test script
cat > test.sh << 'EOF'
#!/bin/bash

# Test original
./hello > original_output.txt

# Test obfuscated
./hello_obfuscated > obfuscated_output.txt

# Compare outputs
if diff original_output.txt obfuscated_output.txt; then
    echo "✓ Functionality preserved"
else
    echo "✗ Output differs - obfuscation error!"
    exit 1
fi
EOF

chmod +x test.sh
./test.sh
```

## Understanding the Report

Obfussor generates detailed JSON reports:

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "input_file": "hello.c",
  "output_file": "hello_obfuscated",
  "techniques": [
    {
      "name": "control_flow_flattening",
      "status": "applied",
      "functions_affected": 2,
      "metrics": {
        "blocks_added": 15,
        "complexity_increase": 3.2
      }
    },
    {
      "name": "string_encryption",
      "status": "applied",
      "strings_encrypted": 2,
      "encryption_algorithm": "xor"
    }
  ],
  "overall_metrics": {
    "original_size": 8432,
    "obfuscated_size": 12227,
    "size_increase_percent": 45,
    "original_complexity": 5,
    "obfuscated_complexity": 16
  }
}
```

## Next Steps

Now that you've obfuscated your first program:

1. **[Configuration Guide](./configuration.md)**: Learn about advanced configuration options
2. **[Obfuscation Techniques](../techniques/overview.md)**: Understand each technique in detail
3. **[LLVM Fundamentals](../llvm/overview.md)**: Learn how LLVM powers obfuscation
4. **[Advanced Topics](../advanced/custom-passes.md)**: Create custom obfuscation passes

## Common Pitfalls

### 1. Over-Obfuscation

**Problem:** Applying all techniques at maximum intensity
**Solution:** Start with medium intensity and specific techniques based on threat model

### 2. Breaking Debug Symbols

**Problem:** Obfuscation removes debug information
**Solution:** Keep separate debug builds; use `--preserve-symbols` for development

### 3. Performance Degradation

**Problem:** High intensity obfuscation significantly slows execution
**Solution:** Profile your application; selectively obfuscate critical functions only

### 4. Compilation Errors

**Problem:** Obfuscated IR fails to compile
**Solution:** Check LLVM version compatibility; verify input code compiles without obfuscation first

## Tips for Success

1. **Start Simple**: Begin with one technique, verify it works, then add more
2. **Test Thoroughly**: Always test obfuscated binaries match original behavior
3. **Version Control**: Keep original source separate from obfuscated versions
4. **Document Configuration**: Save your obfuscation configs for reproducibility
5. **Benchmark Performance**: Measure performance impact before deploying

---

**Congratulations!** You've successfully obfuscated your first program with Obfussor.
