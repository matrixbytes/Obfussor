cmake_minimum_required(VERSION 3.10)
project(obfucc_test C)

# Create a tiny test obfucc that simulates minimal behavior:
# - reads --input <file> and --output <file>
# - if --enable-string-encrypt is present, it replaces occurrences of "SecretString" with "<ENCRYPTED>"
# - if --help is requested, prints a short help and exits 0

add_executable(obfucc_test obfucc_stub.c)

# Set output name to 'obfucc' on all platforms (CMake will append .exe on Windows)
set_target_properties(obfucc_test PROPERTIES OUTPUT_NAME "obfucc")

# Optionally install the test binary (not required for harness which copies from build/)
install(TARGETS obfucc_test DESTINATION bin OPTIONAL)
