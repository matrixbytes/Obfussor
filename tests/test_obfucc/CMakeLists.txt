cmake_minimum_required(VERSION 3.10)
project(obfucc_test C)

# Create a tiny test obfucc that simulates minimal behavior:
# - reads --input <file> and --output <file>
# - if --enable-string-encrypt is present, it replaces occurrences of "SecretString" with "<ENCRYPTED>"
# - if --help is requested, prints a short help and exits 0

add_executable(obfucc_test obfucc_stub.c)

# ensure we build a portable exe name on Windows (obfucc_test.exe) but we install/copy as 'obfucc'
if(WIN32)
  set_target_properties(obfucc_test PROPERTIES OUTPUT_NAME "obfucc")
else()
  set_target_properties(obfucc_test PROPERTIES OUTPUT_NAME "obfucc")
endif()
