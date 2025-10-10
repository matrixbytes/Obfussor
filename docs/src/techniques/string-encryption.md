# String Encryption

String encryption protects string literals in your code by encrypting them at compile time and decrypting them at runtime. This prevents attackers from extracting meaningful information through static analysis of your binaries.

## The Problem with Plain Strings

Consider this simple licensing check:

```cpp
bool verify_license(const char* key) {
    const char* valid_key = "ABC123-XYZ789-PREMIUM";

    if (strcmp(key, valid_key) == 0) {
        return true;
    }

    printf("Invalid license key: %s\n", key);
    return false;
}
```

Running `strings` on the compiled binary immediately reveals:

```text
$ strings myapp.exe | grep -i license
Invalid license key: %s
ABC123-XYZ789-PREMIUM
```

An attacker now has the valid license key without even needing a decompiler.

## How String Encryption Works

String encryption transforms each string literal through three steps:

### 1. Compile-Time Encryption

During compilation, each string is encrypted using a symmetric cipher:

```rust
fn encrypt_string(plaintext: &str, key: &[u8]) -> Vec<u8> {
    let mut encrypted = Vec::new();

    for (i, byte) in plaintext.bytes().enumerate() {
        let key_byte = key[i % key.len()];
        encrypted.push(byte ^ key_byte);
    }

    encrypted
}
```

### 2. Embedded Encrypted Data

The encrypted bytes are embedded in the binary as a data array:

```cpp
// Original:
const char* message = "Hello, World!";

// After encryption:
static const unsigned char encrypted_0[] = {
    0x42, 0x7a, 0x78, 0x78, 0x7d, 0xd4, 0xca, 0x85,
    0x7d, 0x7c, 0x78, 0x76, 0xc3
};
static const unsigned char key_0[] = {
    0x2a, 0x1f, 0x15, 0x19
};
```

### 3. Runtime Decryption

A decryption function is inserted at each use site:

```cpp
char* decrypt_string_0() {
    static char decrypted[14] = {0};
    static bool initialized = false;

    if (!initialized) {
        for (int i = 0; i < 13; i++) {
            decrypted[i] = encrypted_0[i] ^ key_0[i % 4];
        }
        decrypted[13] = '\0';
        initialized = true;
    }

    return decrypted;
}

// Usage:
const char* message = decrypt_string_0();
```

## Encryption Schemes

Obfussor supports multiple encryption algorithms:

### XOR Cipher (Default)

Simple and fast, suitable for most use cases:

```rust
fn xor_encrypt(data: &[u8], key: &[u8]) -> Vec<u8> {
    data.iter()
        .enumerate()
        .map(|(i, &byte)| byte ^ key[i % key.len()])
        .collect()
}
```

**Pros:** Fast, small code footprint  
**Cons:** Vulnerable to known-plaintext attacks

### RC4 Stream Cipher

More secure, suitable for sensitive strings:

```rust
fn rc4_encrypt(data: &[u8], key: &[u8]) -> Vec<u8> {
    let mut s: Vec<u8> = (0..=255).collect();

    // Key scheduling
    let mut j = 0u8;
    for i in 0..256 {
        j = j.wrapping_add(s[i]).wrapping_add(key[i % key.len()]);
        s.swap(i, j as usize);
    }

    // Encryption
    let mut encrypted = Vec::new();
    let mut i = 0u8;
    let mut j = 0u8;

    for &byte in data {
        i = i.wrapping_add(1);
        j = j.wrapping_add(s[i as usize]);
        s.swap(i as usize, j as usize);
        let k = s[(s[i as usize].wrapping_add(s[j as usize])) as usize];
        encrypted.push(byte ^ k);
    }

    encrypted
}
```

**Pros:** Strong encryption, resistant to cryptanalysis  
**Cons:** Larger decryption code, slightly slower

### Custom Substitution

For maximum obfuscation, use a custom substitution cipher:

```rust
fn substitution_encrypt(data: &[u8], table: &[u8; 256]) -> Vec<u8> {
    data.iter().map(|&byte| table[byte as usize]).collect()
}
```

The substitution table itself is encrypted and embedded separately.

## Key Management

Encryption keys can be generated and stored in several ways:

### Random Per-String Keys

Each string gets its own random key:

```rust
fn generate_string_key() -> [u8; 16] {
    let mut key = [0u8; 16];
    thread_rng().fill(&mut key);
    key
}
```

**Pros:** Maximum security, compromise of one key doesn't affect others  
**Cons:** More data embedded in binary

### Derived Keys

Keys are derived from a master secret and string index:

```rust
fn derive_key(master: &[u8], index: usize) -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(master);
    hasher.update(&index.to_le_bytes());
    hasher.finalize().to_vec()
}
```

**Pros:** Smaller binary, centralized key management  
**Cons:** Master key is a single point of failure

### Environment-Based Keys

Keys derived from runtime environment (hardware IDs, timestamps, etc.):

```rust
fn get_machine_key() -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(get_cpu_id());
    hasher.update(get_mac_address());
    hasher.finalize().to_vec()
}
```

**Pros:** Binary won't work on different machines  
**Cons:** Legitimate users may have issues, deployment complexity

## Selective Encryption

Not all strings need encryption. Configure which strings to protect:

```json
{
  "string_encryption": {
    "enabled": true,
    "algorithm": "xor",
    "encrypt_all": false,
    "patterns": [
      ".*license.*",
      ".*key.*",
      ".*password.*",
      ".*secret.*",
      ".*api.*"
    ],
    "min_length": 4,
    "exclude_patterns": ["^[0-9]+$", "^[a-zA-Z]$"]
  }
}
```

This configuration encrypts:

- Strings containing "license", "key", "password", "secret", or "api"
- Strings at least 4 characters long
- Excludes pure numbers or single letters

## Performance Characteristics

String encryption has minimal runtime overhead:

| Metric           | Impact                          |
| ---------------- | ------------------------------- |
| Binary Size      | +5-15%                          |
| Compilation Time | +10-20%                         |
| Runtime Speed    | -1-3% (first use), ~0% (cached) |

The performance impact depends on:

- **Encryption algorithm** - XOR is faster than RC4
- **Caching strategy** - Decrypt once vs. decrypt each use
- **String frequency** - Rarely used strings have negligible impact

## Caching Strategies

### Static Cache (Default)

Decrypt once on first use, store in static variable:

```cpp
char* decrypt_string_0() {
    static char cache[20];
    static bool ready = false;

    if (!ready) {
        // Decrypt into cache
        ready = true;
    }

    return cache;
}
```

**Pros:** Fast subsequent accesses  
**Cons:** Decrypted string remains in memory

### Stack Cache

Decrypt to stack for temporary use:

```cpp
void use_string() {
    char buffer[20];
    decrypt_string_0(buffer);
    // Use buffer
    memset(buffer, 0, sizeof(buffer));  // Clear after use
}
```

**Pros:** String cleared after use  
**Cons:** Slower, must decrypt each time

### No Cache

Decrypt directly into caller's buffer:

```cpp
size_t get_encrypted_length_0();
void decrypt_string_0(char* dest);

// Usage:
char* buffer = malloc(get_encrypted_length_0());
decrypt_string_0(buffer);
// ...
free(buffer);
```

**Pros:** Maximum flexibility  
**Cons:** Caller must manage memory

## Security Considerations

### Memory Dumping

Even with encryption, strings exist in memory after decryption:

```cpp
void secure_decrypt(char* dest, const unsigned char* src, size_t len) {
    // Decrypt
    for (size_t i = 0; i < len; i++) {
        dest[i] = src[i] ^ get_key_byte(i);
    }

    // Use string
    process_string(dest);

    // Securely erase from memory
    explicit_bzero(dest, len);
}
```

### Key Extraction

If an attacker finds the decryption function and key, they can decrypt all strings. Mitigations:

- **Combine with control flow flattening** - Obscure the decryption logic
- **Multiple key sources** - Split keys across different data sections
- **Anti-debugging** - Detect debuggers and refuse to decrypt

### Known-Plaintext Attacks

XOR encryption is vulnerable if attackers know some plaintext:

```text
ciphertext:  0x42 0x7a 0x78 0x78 0x7d
plaintext:   H    e    l    l    o
           -------------------------
key:         0x2a 0x1f 0x15 0x19 0x17
```

Defense: Use RC4 or add per-character key variations.

## Best Practices

1. **Prioritize sensitive strings** - Don't encrypt everything, focus on credentials, keys, URLs
2. **Use strong encryption for secrets** - RC4 or AES for critical data
3. **Clear memory after use** - For highly sensitive strings
4. **Combine with other techniques** - String encryption alone isn't enough
5. **Test thoroughly** - Ensure encrypted strings work in all code paths

## Example Usage

```cpp
// Original code
void authenticate() {
    const char* server = "api.example.com";
    const char* endpoint = "/v1/auth";
    const char* api_key = "sk_live_1234567890";

    connect(server, endpoint, api_key);
}

// After string encryption (conceptual)
void authenticate() {
    const char* server = DECRYPT_STR_0();    // "api.example.com"
    const char* endpoint = DECRYPT_STR_1();  // "/v1/auth"
    const char* api_key = DECRYPT_STR_2();   // "sk_live_1234567890"

    connect(server, endpoint, api_key);

    SECURE_FREE_STR(api_key);  // Clear sensitive data
}
```

Running `strings` on the obfuscated binary shows only gibberish:

```text
$ strings myapp.exe | grep -i api
<no results>
```

## Limitations

String encryption doesn't protect against:

- **Runtime dumping** - Debuggers can capture decrypted strings from memory
- **Dynamic analysis** - Watching program execution reveals strings
- **Dedicated attackers** - Given enough time, any encryption can be broken

For complete protection, combine string encryption with anti-debugging, control flow flattening, and runtime integrity checks.

## Further Reading

- [LLVM String Encryption Pass](../implementation/rust-backend.md#string-encryption-pass)
- [Encryption Performance](../advanced/performance.md#string-encryption-overhead)
- [Security Analysis](../advanced/security-analysis.md#string-protection)
