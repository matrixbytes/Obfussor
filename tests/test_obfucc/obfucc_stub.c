#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

int main(int argc, char** argv) {
    const char *input = NULL;
    const char *output = NULL;
    bool enable_string_encrypt = false;

    if (argc == 1) {
        printf("obfucc_test: tiny test stub.\nUse --help for usage\n");
        return 0;
    }

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            printf("obfucc_test (stub)\n");
            printf("  --input <file>       : input .ll file\n");
            printf("  --output <file>      : output .ll file\n");
            printf("  -o <file>            : short form for --output\n");
            printf("  --enable-string-encrypt : apply very small 'encryption' transformation\n");
            return 0;
        } else if (strcmp(argv[i], "--input") == 0 && i + 1 < argc) {
            input = argv[++i];
        } else if (strcmp(argv[i], "--output") == 0 && i + 1 < argc) {
            output = argv[++i];
        } else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
            output = argv[++i];
        } else if (strcmp(argv[i], "--enable-string-encrypt") == 0) {
            enable_string_encrypt = true;
        } else if (argv[i][0] != '-') {
            /* treat first non-flag as positional input */
            if (!input) input = argv[i];
        }
    }

    if (!input || !output) {
        fprintf(stderr, "ERROR: --input and --output are required\n");
        return 2;
    }

    FILE *in = fopen(input, "rb");
    if (!in) {
        fprintf(stderr, "ERROR: failed to open input: %s\n", input);
        return 3;
    }
    fseek(in, 0, SEEK_END);
    long sz = ftell(in);
    fseek(in, 0, SEEK_SET);
    if (sz < 0) { fclose(in); fprintf(stderr, "ERROR: invalid input size\n"); return 4; }
    char *buf = (char*)malloc((size_t)sz + 1);
    if (!buf) { fclose(in); return 4; }
    size_t nread = fread(buf, 1, (size_t)sz, in);
    if (nread != (size_t)sz) { free(buf); fclose(in); fprintf(stderr, "ERROR: short read\n"); return 4; }
    buf[sz] = 0;
    fclose(in);

    if (enable_string_encrypt) {
        const char *needle = "SecretString";
        const char *replacement = "<ENCRYPTED>";
        char *p = buf;
        int rep_len = (int)strlen(replacement);
        // naive in-place replacement: write to a new buffer
    size_t outcap = (size_t)sz + (size_t)rep_len * 8 + 1024;
    char *outbuf = (char*)malloc(outcap);
    if (!outbuf) { free(buf); return 5; }
    char *dst = outbuf;
        while (*p) {
            char *found = strstr(p, needle);
            if (!found) {
                strcpy(dst, p);
                break;
            }
            size_t before = found - p;
            memcpy(dst, p, before);
            dst += before;
            memcpy(dst, replacement, rep_len);
            dst += rep_len;
            p = found + strlen(needle);
        }
        // write outbuf to file
    FILE *out = fopen(output, "wb");
    if (!out) { free(buf); free(outbuf); return 6; }
    size_t outlen = strlen(outbuf);
    fwrite(outbuf, 1, outlen, out);
        fclose(out);
        free(outbuf);
    } else {
        // just copy input to output
        FILE *out = fopen(output, "wb");
        if (!out) { free(buf); return 7; }
        fwrite(buf, 1, sz, out);
        fclose(out);
    }

    free(buf);
    return 0;
}
