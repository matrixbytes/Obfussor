# Configuration

Obfussor provides flexible configuration options to customize obfuscation behavior for your specific needs. This guide covers all configuration methods and available options.

## Configuration Methods

Obfussor supports three configuration methods:

1. **GUI Configuration**: Interactive configuration through the desktop application
2. **Configuration Files**: JSON-based configuration files for reproducible builds
3. **Command-Line Arguments**: Direct configuration via CLI flags

### Priority Order

When multiple configuration methods are used:
```
CLI Arguments > Configuration File > GUI Settings > Default Values
```

## Configuration File Format

### Basic Structure

Create a JSON configuration file (e.g., `obfussor.json`):

```json
{
  "version": "1.0",
  "input": {
    "files": ["src/main.c", "src/utils.c"],
    "include_dirs": ["include/"],
    "defines": ["RELEASE_BUILD"]
  },
  "output": {
    "directory": "build/obfuscated",
    "basename": "program",
    "generate_ir": true,
    "generate_report": true,
    "report_format": "json"
  },
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "medium",
      "options": {}
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "aes128",
      "options": {}
    },
    "bogus_control_flow": {
      "enabled": false
    },
    "instruction_substitution": {
      "enabled": true,
      "complexity": 3
    },
    "function_inlining": {
      "enabled": false
    }
  },
  "compiler": {
    "name": "clang",
    "optimization_level": "O2",
    "target_architecture": "x86_64",
    "additional_flags": ["-fno-inline", "-fno-unroll-loops"]
  },
  "advanced": {
    "preserve_symbols": false,
    "strip_debug_info": true,
    "seed": null
  }
}
```

### Using Configuration Files

```bash
# CLI
obfussor-cli obfuscate --config obfussor.json

# Or specify additional overrides
obfussor-cli obfuscate --config obfussor.json --intensity high
```

## Configuration Sections

### Input Configuration

Controls what source files to obfuscate and how to process them.

```json
{
  "input": {
    "files": [
      "src/main.c",
      "src/module1.c",
      "src/module2.c"
    ],
    "include_dirs": [
      "include/",
      "third_party/include/"
    ],
    "defines": [
      "RELEASE_BUILD",
      "ENABLE_OBFUSCATION",
      "VERSION=1.0"
    ],
    "exclude_patterns": [
      "*_test.c",
      "debug_*.c"
    ]
  }
}
```

**Options:**
- `files`: Array of source files to obfuscate
- `include_dirs`: Include directories for compilation
- `defines`: Preprocessor definitions
- `exclude_patterns`: Glob patterns for files to exclude

### Output Configuration

Controls output generation and reporting.

```json
{
  "output": {
    "directory": "build/obfuscated",
    "basename": "myapp",
    "generate_ir": true,
    "generate_report": true,
    "report_format": "json",
    "report_file": "obfuscation-report.json",
    "ir_directory": "build/ir/",
    "preserve_structure": false
  }
}
```

**Options:**
- `directory`: Output directory for obfuscated files
- `basename`: Base name for output files
- `generate_ir`: Generate intermediate LLVM IR files
- `generate_report`: Create obfuscation report
- `report_format`: Report format (`json`, `html`, `text`)
- `report_file`: Custom report file name
- `ir_directory`: Directory for IR files
- `preserve_structure`: Maintain input directory structure

### Technique Configuration

Each obfuscation technique can be configured individually.

#### Control Flow Flattening

```json
{
  "control_flow_flattening": {
    "enabled": true,
    "intensity": "medium",
    "options": {
      "split_basic_blocks": true,
      "dispatch_type": "switch",
      "state_variable_type": "i32",
      "bogus_states": 5,
      "preserve_functions": ["main", "init_*"],
      "min_block_size": 3
    }
  }
}
```

**Options:**
- `enabled`: Enable/disable the technique
- `intensity`: Obfuscation intensity (`low`, `medium`, `high`)
- `split_basic_blocks`: Split basic blocks before flattening
- `dispatch_type`: Dispatch mechanism (`switch`, `indirect`)
- `state_variable_type`: LLVM type for state variable
- `bogus_states`: Number of unreachable bogus states
- `preserve_functions`: Functions to exclude (glob patterns supported)
- `min_block_size`: Minimum instructions per block to flatten

#### String Encryption

```json
{
  "string_encryption": {
    "enabled": true,
    "algorithm": "aes128",
    "options": {
      "key_generation": "random",
      "encryption_key": null,
      "decrypt_function": "inline",
      "exclude_patterns": [
        "debug_*",
        "test_*"
      ],
      "min_length": 4,
      "encrypt_wide_strings": true
    }
  }
}
```

**Options:**
- `algorithm`: Encryption algorithm (`xor`, `aes128`, `aes256`, `custom`)
- `key_generation`: Key generation method (`random`, `derived`, `fixed`)
- `encryption_key`: Fixed encryption key (hex string, null for random)
- `decrypt_function`: Decryption function placement (`inline`, `function`, `constructor`)
- `exclude_patterns`: String patterns to exclude
- `min_length`: Minimum string length to encrypt
- `encrypt_wide_strings`: Also encrypt wide character strings

#### Bogus Control Flow

```json
{
  "bogus_control_flow": {
    "enabled": true,
    "intensity": "medium",
    "options": {
      "injection_probability": 0.3,
      "max_bogus_blocks": 5,
      "opaque_predicate_complexity": 3,
      "use_external_functions": false,
      "preserve_semantics": true
    }
  }
}
```

**Options:**
- `injection_probability`: Probability of injecting bogus code (0.0-1.0)
- `max_bogus_blocks`: Maximum bogus blocks per function
- `opaque_predicate_complexity`: Complexity of opaque predicates (1-5)
- `use_external_functions`: Call external functions in bogus code
- `preserve_semantics`: Ensure bogus code doesn't affect semantics

#### Instruction Substitution

```json
{
  "instruction_substitution": {
    "enabled": true,
    "complexity": 3,
    "options": {
      "substitute_arithmetic": true,
      "substitute_boolean": true,
      "mixed_boolean_arithmetic": true,
      "max_substitution_depth": 3,
      "preserve_performance": false
    }
  }
}
```

**Options:**
- `complexity`: Substitution complexity level (1-5)
- `substitute_arithmetic`: Replace arithmetic operations
- `substitute_boolean`: Replace boolean operations
- `mixed_boolean_arithmetic`: Use MBA (Mixed Boolean-Arithmetic) expressions
- `max_substitution_depth`: Maximum recursive substitution depth
- `preserve_performance`: Limit substitutions affecting performance

#### Function Inlining/Outlining

```json
{
  "function_inlining": {
    "enabled": true,
    "strategy": "mixed",
    "options": {
      "inline_threshold": 100,
      "outline_threshold": 50,
      "inline_functions": ["small_*"],
      "outline_functions": ["compute_*"],
      "preserve_abi": true
    }
  }
}
```

**Options:**
- `strategy`: Strategy (`inline`, `outline`, `mixed`, `random`)
- `inline_threshold`: Maximum size for inlining (IR instructions)
- `outline_threshold`: Minimum size for outlining
- `inline_functions`: Function patterns to inline
- `outline_functions`: Function patterns to outline
- `preserve_abi`: Preserve ABI for external calls

### Compiler Configuration

Configure the compilation process:

```json
{
  "compiler": {
    "name": "clang",
    "version": "14.0",
    "optimization_level": "O2",
    "target_architecture": "x86_64",
    "target_os": "linux",
    "additional_flags": [
      "-fno-inline",
      "-fno-unroll-loops",
      "-fno-vectorize"
    ],
    "link_flags": [
      "-static",
      "-s"
    ],
    "emit_llvm": false
  }
}
```

**Options:**
- `name`: Compiler executable (`clang`, `gcc`, `clang++`)
- `version`: Required compiler version (optional)
- `optimization_level`: Optimization level (`O0`, `O1`, `O2`, `O3`, `Os`, `Oz`)
- `target_architecture`: Target architecture (`x86_64`, `arm64`, `i386`)
- `target_os`: Target operating system (`linux`, `windows`, `macos`)
- `additional_flags`: Extra compiler flags
- `link_flags`: Linker flags
- `emit_llvm`: Emit LLVM bitcode instead of native binary

### Advanced Configuration

Advanced options for fine-tuning:

```json
{
  "advanced": {
    "preserve_symbols": false,
    "strip_debug_info": true,
    "seed": 12345,
    "parallelism": 4,
    "cache_enabled": true,
    "cache_directory": ".obfussor-cache/",
    "verify_output": true,
    "log_level": "info",
    "dry_run": false
  }
}
```

**Options:**
- `preserve_symbols`: Keep symbol names in output
- `strip_debug_info`: Remove debug information
- `seed`: Random seed for reproducible obfuscation (null for random)
- `parallelism`: Number of parallel threads (0 for auto)
- `cache_enabled`: Enable compilation cache
- `cache_directory`: Cache directory location
- `verify_output`: Verify obfuscated IR validity
- `log_level`: Logging level (`debug`, `info`, `warn`, `error`)
- `dry_run`: Perform dry run without generating output

## Preset Configurations

### Minimal Obfuscation

For development and debugging:

```json
{
  "version": "1.0",
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "low"
    },
    "string_encryption": {
      "enabled": false
    }
  },
  "compiler": {
    "optimization_level": "O0"
  },
  "advanced": {
    "preserve_symbols": true,
    "strip_debug_info": false
  }
}
```

### Balanced Obfuscation

For most production use cases:

```json
{
  "version": "1.0",
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "medium"
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "aes128"
    },
    "instruction_substitution": {
      "enabled": true,
      "complexity": 3
    }
  },
  "compiler": {
    "optimization_level": "O2"
  },
  "advanced": {
    "preserve_symbols": false,
    "strip_debug_info": true
  }
}
```

### Maximum Obfuscation

For maximum protection (performance impact):

```json
{
  "version": "1.0",
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "high",
      "options": {
        "bogus_states": 10
      }
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "aes256"
    },
    "bogus_control_flow": {
      "enabled": true,
      "intensity": "high",
      "options": {
        "injection_probability": 0.5
      }
    },
    "instruction_substitution": {
      "enabled": true,
      "complexity": 5
    },
    "function_inlining": {
      "enabled": true,
      "strategy": "mixed"
    }
  },
  "compiler": {
    "optimization_level": "O3"
  },
  "advanced": {
    "preserve_symbols": false,
    "strip_debug_info": true
  }
}
```

## Configuration Validation

Validate your configuration file:

```bash
obfussor-cli validate-config obfussor.json
```

Output:
```
✓ Configuration file is valid
✓ All techniques are properly configured
✓ Compiler settings are compatible
⚠ Warning: High intensity may significantly impact performance
```

## Environment Variables

Override configuration with environment variables:

```bash
# Set default obfuscation intensity
export OBFUSSOR_INTENSITY=high

# Set compiler
export OBFUSSOR_COMPILER=clang-14

# Set parallelism
export OBFUSSOR_PARALLELISM=8

# Use configuration
obfussor-cli obfuscate --input main.c
```

## GUI Configuration

### Interactive Configuration

1. Launch Obfussor application
2. Navigate to **Settings** tab
3. Configure techniques:
   - Toggle each technique on/off
   - Adjust intensity sliders
   - Configure technique-specific options
4. Save configuration:
   - Click **Save Configuration**
   - Choose location for config file
5. Load configuration:
   - Click **Load Configuration**
   - Select saved config file

### Configuration Profiles

The GUI supports multiple named profiles:

1. **Create Profile**: Settings → New Profile
2. **Switch Profile**: Select from dropdown
3. **Export Profile**: Settings → Export → JSON/YAML
4. **Import Profile**: Settings → Import

## Best Practices

### 1. Version Control Configuration

Store configuration files in version control:

```bash
project/
├── src/
├── obfussor-dev.json      # Development config
├── obfussor-release.json  # Release config
└── obfussor-max.json      # Maximum protection config
```

### 2. Incremental Configuration

Start minimal and add techniques incrementally:

```bash
# Start with basic
obfussor-cli obfuscate --config obfussor-basic.json --input main.c

# Test, then increase
obfussor-cli obfuscate --config obfussor-medium.json --input main.c

# Finally, apply maximum if needed
obfussor-cli obfuscate --config obfussor-max.json --input main.c
```

### 3. Performance Testing

Always measure performance impact:

```bash
# Benchmark original
time ./program_original

# Benchmark obfuscated
time ./program_obfuscated

# Compare and adjust configuration
```

### 4. Selective Obfuscation

Obfuscate only critical code:

```json
{
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "options": {
        "preserve_functions": [
          "*",
          "!critical_*",
          "!secret_*"
        ]
      }
    }
  }
}
```

Pattern `!` means "do NOT preserve" (i.e., do obfuscate).

### 5. Reproducible Builds

Use fixed seeds for reproducible obfuscation:

```json
{
  "advanced": {
    "seed": 42
  }
}
```

## Configuration Examples

### Example 1: Mobile Application

```json
{
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "medium"
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "xor"
    },
    "instruction_substitution": {
      "enabled": true,
      "complexity": 2
    }
  },
  "compiler": {
    "optimization_level": "Os",
    "target_architecture": "arm64"
  }
}
```

### Example 2: Server Application

```json
{
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "high"
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "aes256"
    },
    "bogus_control_flow": {
      "enabled": true
    }
  },
  "compiler": {
    "optimization_level": "O3"
  },
  "advanced": {
    "parallelism": 16
  }
}
```

### Example 3: Embedded System

```json
{
  "techniques": {
    "control_flow_flattening": {
      "enabled": true,
      "intensity": "low"
    },
    "string_encryption": {
      "enabled": true,
      "algorithm": "xor"
    }
  },
  "compiler": {
    "optimization_level": "Os",
    "target_architecture": "arm",
    "additional_flags": ["-mthumb"]
  },
  "advanced": {
    "verify_output": true
  }
}
```

## Troubleshooting Configuration

### Configuration Not Applied

**Problem:** Configuration seems ignored

**Solution:**
```bash
# Verify configuration is loaded
obfussor-cli obfuscate --config config.json --verbose

# Check for CLI argument overrides
# Ensure no conflicting environment variables
```

### Invalid Configuration

**Problem:** Configuration validation fails

**Solution:**
```bash
# Validate JSON syntax
cat config.json | jq .

# Use schema validation
obfussor-cli validate-config config.json --schema
```

### Unexpected Results

**Problem:** Obfuscation doesn't match expectations

**Solution:**
```bash
# Enable detailed logging
obfussor-cli obfuscate --config config.json --log-level debug

# Generate detailed report
obfussor-cli obfuscate --config config.json --report-format html
```

## Next Steps

- **[Obfuscation Techniques](../techniques/overview.md)**: Learn about each technique
- **[CLI Reference](../api/cli.md)**: Complete CLI documentation
- **[Advanced Topics](../advanced/performance.md)**: Optimize your configuration
- **[Troubleshooting](../troubleshooting/common-issues.md)**: Solve common problems

---

With proper configuration, you can balance security, performance, and maintainability for your specific use case.
