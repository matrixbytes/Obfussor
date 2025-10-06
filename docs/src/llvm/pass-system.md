# LLVM Pass System

The LLVM Pass framework is the infrastructure that enables code analysis and transformation. Understanding the pass system is essential for implementing and using obfuscation techniques in Obfussor.

## What is an LLVM Pass?

An LLVM Pass is a unit of compilation work that performs analysis or transformation on LLVM IR. Passes are:

- **Modular**: Self-contained units of functionality
- **Composable**: Can be combined in sequences
- **Reusable**: Can be applied to different modules
- **Analyzable**: Can depend on other passes

## Pass Types

### 1. Module Pass

Operates on entire modules (all functions and globals):

```cpp
struct MyModulePass : public ModulePass {
  static char ID;
  
  bool runOnModule(Module &M) override {
    // Process all functions in module
    for (Function &F : M) {
      // Process function
    }
    return true; // Module was modified
  }
};
```

**Use Cases:**
- Inter-procedural analysis
- Global transformations
- Call graph construction

### 2. Function Pass

Operates on individual functions:

```cpp
struct MyFunctionPass : public FunctionPass {
  static char ID;
  
  bool runOnFunction(Function &F) override {
    // Process all basic blocks
    for (BasicBlock &BB : F) {
      // Process basic block
    }
    return true; // Function was modified
  }
};
```

**Use Cases:**
- Intra-procedural optimizations
- Function-level obfuscation
- Local analysis

### 3. BasicBlock Pass

Operates on individual basic blocks:

```cpp
struct MyBasicBlockPass : public BasicBlockPass {
  static char ID;
  
  bool runOnBasicBlock(BasicBlock &BB) override {
    for (Instruction &I : BB) {
      // Process instruction
    }
    return true; // Basic block was modified
  }
};
```

**Use Cases:**
- Local optimizations
- Instruction-level transformations

### 4. Loop Pass

Operates on loop structures:

```cpp
struct MyLoopPass : public LoopPass {
  static char ID;
  
  bool runOnLoop(Loop *L, LPPassManager &LPM) override {
    // Process loop
    for (BasicBlock *BB : L->blocks()) {
      // Process blocks in loop
    }
    return true;
  }
};
```

**Use Cases:**
- Loop optimizations
- Loop obfuscation
- Loop vectorization

## Pass Manager

The Pass Manager orchestrates pass execution:

### Legacy Pass Manager (Pre-LLVM 14)

```cpp
legacy::PassManager PM;
PM.add(createPromoteMemoryToRegisterPass());
PM.add(new MyCustomPass());
PM.run(Module);
```

### New Pass Manager (LLVM 14+)

```cpp
ModulePassManager MPM;
FunctionPassManager FPM;

// Add function passes
FPM.addPass(SimplifyCFGPass());
FPM.addPass(InstructionCombiningPass());

// Add function pass manager to module pass manager
MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));

// Run passes
ModuleAnalysisManager MAM;
MPM.run(Module, MAM);
```

## Pass Dependencies

Passes can declare dependencies on other passes:

```cpp
void MyPass::getAnalysisUsage(AnalysisUsage &AU) const {
  // This pass requires dominator tree
  AU.addRequired<DominatorTreeWrapperPass>();
  
  // This pass preserves CFG
  AU.setPreservesCFG();
  
  // This pass doesn't modify anything
  AU.setPreservesAll();
}

// Using the analysis
bool MyPass::runOnFunction(Function &F) {
  DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  // Use dominator tree...
}
```

## Common Analysis Passes

### Dominator Tree

Computes dominance relationships:

```cpp
DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();

if (DT.dominates(BB1, BB2)) {
  // BB1 dominates BB2
}

BasicBlock *IDom = DT.getNode(BB)->getIDom()->getBlock();
```

### Loop Information

Analyzes loop structure:

```cpp
LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

for (Loop *L : LI) {
  BasicBlock *Header = L->getHeader();
  unsigned Depth = L->getLoopDepth();
  // Process loop
}
```

### Alias Analysis

Determines memory aliasing:

```cpp
AliasAnalysis &AA = getAnalysis<AAResultsWrapperPass>().getAAResults();

if (AA.alias(Ptr1, Ptr2) == AliasResult::NoAlias) {
  // Pointers don't alias
}
```

### Call Graph

Represents function call relationships:

```cpp
CallGraph &CG = getAnalysis<CallGraphWrapperPass>().getCallGraph();

for (auto &Node : CG) {
  Function *F = Node.first;
  for (auto &CallRecord : *Node.second) {
    Function *Callee = CallRecord.second->getFunction();
  }
}
```

## Writing a Custom Pass

### Step 1: Define Pass Class

```cpp
#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

namespace {
  struct CountInstructionsPass : public FunctionPass {
    static char ID;
    CountInstructionsPass() : FunctionPass(ID) {}
    
    bool runOnFunction(Function &F) override {
      unsigned Count = 0;
      for (BasicBlock &BB : F) {
        Count += BB.size();
      }
      errs() << "Function " << F.getName() 
             << " has " << Count << " instructions\n";
      return false; // Didn't modify the function
    }
  };
}

char CountInstructionsPass::ID = 0;
```

### Step 2: Register the Pass

```cpp
static RegisterPass<CountInstructionsPass> X(
  "count-instructions",
  "Count instructions in functions",
  false,  // Only looks at CFG
  true    // Analysis pass
);
```

### Step 3: Build and Load

```bash
# Build pass as shared library
clang++ -shared -fPIC MyPass.cpp -o MyPass.so \
  `llvm-config --cxxflags --ldflags`

# Load and run pass
opt -load MyPass.so -count-instructions < input.bc > output.bc
```

## Pass Scheduling

The pass manager schedules passes optimally:

```
Module Pass 1
  Function Pass A (on each function)
  Function Pass B (on each function)
Module Pass 2
  Function Pass C (on each function)
```

This minimizes:
- Redundant analysis
- Cache misses
- Compilation time

## Obfuscation Passes

### Control Flow Flattening Pass

```cpp
struct FlatteningPass : public FunctionPass {
  bool runOnFunction(Function &F) override {
    // Don't flatten already flat functions
    if (isAlreadyFlat(&F)) return false;
    
    // Split basic blocks
    std::vector<BasicBlock*> Blocks;
    for (BasicBlock &BB : F) {
      Blocks.push_back(&BB);
    }
    
    // Create switch variable
    AllocaInst *SwitchVar = 
      new AllocaInst(Type::getInt32Ty(F.getContext()));
    
    // Create dispatcher block
    BasicBlock *Dispatcher = 
      BasicBlock::Create(F.getContext(), "dispatcher", &F);
    
    // Build switch instruction
    SwitchInst *Switch = SwitchInst::Create(
      SwitchVar, DefaultBlock, Blocks.size(), Dispatcher);
    
    // Update blocks to branch to dispatcher
    for (unsigned i = 0; i < Blocks.size(); ++i) {
      // Modify terminator to update state and branch to dispatcher
      // ... implementation details ...
    }
    
    return true;
  }
};
```

### String Encryption Pass

```cpp
struct StringEncryptionPass : public ModulePass {
  bool runOnModule(Module &M) override {
    for (GlobalVariable &GV : M.globals()) {
      if (!GV.hasInitializer()) continue;
      
      Constant *Init = GV.getInitializer();
      if (ConstantDataArray *CDA = dyn_cast<ConstantDataArray>(Init)) {
        if (CDA->isString()) {
          // Encrypt the string
          std::string Original = CDA->getAsString().str();
          std::vector<uint8_t> Encrypted = encryptString(Original);
          
          // Replace with encrypted version
          Constant *NewInit = ConstantDataArray::get(
            M.getContext(), Encrypted);
          GV.setInitializer(NewInit);
          
          // Insert decryption code at usage sites
          insertDecryptionCode(&GV, M);
        }
      }
    }
    return true;
  }
};
```

## Pass Options and Configuration

Passes can accept options:

```cpp
static cl::opt<unsigned> ObfuscationLevel(
  "obf-level",
  cl::desc("Obfuscation intensity level (1-5)"),
  cl::init(3)
);

struct ConfigurablePass : public FunctionPass {
  bool runOnFunction(Function &F) override {
    unsigned Level = ObfuscationLevel;
    // Apply obfuscation based on level
    return true;
  }
};
```

Use from command line:
```bash
opt -load ObfPass.so -my-pass -obf-level=5 < input.bc > output.bc
```

## Pass Debugging

### Print IR Before/After

```bash
# Print IR after each pass
opt -print-after-all -O2 input.ll -S -o output.ll

# Print only specific pass
opt -print-after=my-pass input.ll -S -o output.ll
```

### Verify IR

```bash
# Run verifier after each pass
opt -verify-each -O2 input.ll -S -o output.ll
```

### Debug Pass Execution

```cpp
#define DEBUG_TYPE "my-pass"

LLVM_DEBUG(dbgs() << "Processing function: " << F.getName() << "\n");
LLVM_DEBUG(dbgs() << "Found " << Count << " instructions\n");
```

Enable debug output:
```bash
opt -debug -debug-only=my-pass -my-pass < input.bc > output.bc
```

## Best Practices

### 1. Preserve Analysis When Possible

```cpp
void MyPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesCFG(); // If CFG unchanged
  AU.addPreserved<LoopInfoWrapperPass>(); // If loops unchanged
}
```

### 2. Update Analysis After Modification

```cpp
DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();

// Modify IR
BasicBlock *NewBB = SplitBlock(BB, I, &DT);

// DT is automatically updated
```

### 3. Use LLVM IR Builder

```cpp
IRBuilder<> Builder(Context);
Builder.SetInsertPoint(InsertBefore);

Value *Sum = Builder.CreateAdd(A, B, "sum");
Value *Product = Builder.CreateMul(Sum, C, "product");
```

### 4. Handle Edge Cases

```cpp
bool runOnFunction(Function &F) override {
  // Skip declarations
  if (F.isDeclaration()) return false;
  
  // Skip functions with specific attributes
  if (F.hasFnAttribute("no-obfuscate")) return false;
  
  // Process function
  return true;
}
```

## Integration with Obfussor

Obfussor uses custom passes for each obfuscation technique:

```
Source Code
    ↓
  LLVM IR
    ↓
  Control Flow Flattening Pass
    ↓
  String Encryption Pass
    ↓
  Bogus Control Flow Pass
    ↓
  Instruction Substitution Pass
    ↓
  Optimization Passes
    ↓
  Obfuscated Binary
```

Each pass:
- Operates on LLVM IR
- Preserves semantics
- Can be enabled/disabled
- Has configurable intensity

## Summary

The LLVM Pass system:
- Provides modular transformation framework
- Enables analysis and optimization
- Supports custom passes for obfuscation
- Manages dependencies automatically
- Schedules passes efficiently

Key concepts:
- Different pass types (Module, Function, BasicBlock, Loop)
- Pass Manager orchestrates execution
- Analysis passes provide information
- Transformation passes modify IR
- Dependencies ensure correct ordering

## Next Steps

- **[Compilation Pipeline](./compilation-pipeline.md)**: See passes in action
- **[Obfuscation Techniques](../techniques/overview.md)**: Obfuscation passes
- **[Custom Passes](../advanced/custom-passes.md)**: Write your own passes

---

The pass system is the engine that powers LLVM obfuscation.
