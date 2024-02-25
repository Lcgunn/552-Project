# 552-Project
Creating a MIPS-style CPU

Notes for Organizing Tasks: [here](https://docs.google.com/document/d/1EIT2YE9qVkbk8FTKkhfBuAA56mgEnbDFtGcCBj3Gh_Q/edit?usp=sharing)

## Phase 1
1) **Compute Instructions**

    1.1) Saturating Arithmetic for add sub
   
    1.2) Saturating Arithmetic for pad sub (4 word add/sub)
   
    1.3) Reduction (Add top bytes and lower bytes)
   
    1.4) Right rotation (take bytes off the LSB and append them to MSB)
   
         --> Opcode is Rd,Rs, imm → (imm is 4 bit)
   
2) **Memory Instructions**
   
    2.1) Load and Store word
   
         --> The LSB is always zero, so it is omitted in the instruction
   
    2.2) Load Lower and Upper Byte **NOT ACTUALLY MEMORY OPS** (More a register instruction)
   
3) **Control Instructions/Signals**
   
    3.1) Jump
   
    3.2) Branch
   
    3.3) PCS adds 2?
   
    3.4) HLT stops the next instruction
   
    3.5) Flags?	 (Seems more like a compute instruction)
   
         --> Set by other instructions for use in Branch
   
4) Compile? AKA translate instruct
   
5) **Integration**

6) **Memory** is provided?
