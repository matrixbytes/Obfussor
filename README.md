# C, CPP Obfucator

Application software to obfuscate the object file using Low Level Virtual Machine (LLVM).

Software obfuscation has become an essential technique in modern software engineering, particularly in the domain where intellectual property protection, reverse engineering prevention and software piracy mitigation is critical.

LLVM (Low Level Virtual Machine) is widely used compiler infrastructure that provides a modular and reusable compiler and toolchain technique. The project plans to use LLVM as a tool to compile and generate obfuscated object code from a given source code.

## Output

Generation of report which

- Logs all the input parameters
- Logs all the attributes of output file including size, method of obfuscation etc
- Give brief information about the amount of bogus code generated
- Provides details on number of cycles of obfuscation completed
- Number of string obfuscation/encryption done
- Number of fake look inserted
