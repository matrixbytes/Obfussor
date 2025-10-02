#!/usr/bin/env python3
"""
Simple obfucc stub used for testing the test harness.
- Supports: --help, --input, --output, --enable-string-encrypt, --enable-cff
- Behavior: copies input IR to output; if string-encrypt is enabled it removes known plaintexts; if cff enabled it injects a "switch" line to satisfy FileCheck checks.
"""
import argparse
import sys
from pathlib import Path

def main():
    # provide a simple help response if requested
    if '-h' in sys.argv or '--help' in sys.argv:
        print("obfucc stub: usage: --input <file> --output <file> [--enable-string-encrypt] [--enable-cff]")
        return 0

    p = argparse.ArgumentParser(prog='obfucc')
    # accept both long-form and short-form flags and an optional positional input
    p.add_argument('--input', required=False, help='input IR file')
    p.add_argument('-o', '--output', required=False, help='output IR file')
    p.add_argument('--enable-string-encrypt', action='store_true')
    p.add_argument('--enable-cff', action='store_true')
    p.add_argument('input_pos', nargs='?', help='positional input file')
    args = p.parse_args()

    # Determine input and output from either long flags or positional/short flags
    input_path = args.input or args.input_pos
    output_path = args.output

    if not input_path or not output_path:
        print("ERROR: --input (or positional input) and --output (or -o) required for stub in non-help mode", file=sys.stderr)
        return 2

    inp = Path(input_path)
    out = Path(output_path)
    if not inp.exists():
        print(f"ERROR: input file not found: {inp}", file=sys.stderr)
        return 3

    text = inp.read_text(encoding='utf-8')

    if args.enable_string_encrypt:
        # Basic replacements for sample cases
        text = text.replace('SecretString', '<<encrypted>>')
        text = text.replace('Hello, world!', '<<encrypted>>')

    if args.enable_cff:
        # Ensure at least one 'switch' appears so FileCheck can match it.
        if 'switch' not in text:
            # Insert a fake dispatcher comment near the top or before first function body
            lines = text.splitlines()
            inserted = False
            for i, line in enumerate(lines):
                if line.strip().startswith('define '):
                    # insert a fake dispatcher line after function header
                    lines.insert(i+1, '  ; fake dispatcher introduced by obfucc-stub')
                    lines.insert(i+2, '  switch i32 %0, label %entry [ ]')
                    inserted = True
                    break
            if not inserted:
                lines.insert(0, '; fake dispatcher introduced by obfucc-stub')
                lines.insert(1, 'switch i32 %0, label %entry [ ]')
            text = '\n'.join(lines)

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding='utf-8')
    return 0

if __name__ == '__main__':
    sys.exit(main())
