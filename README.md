# 552-Project
Creating a MIPS-style CPU

Notes for Organizing Tasks: [here](https://docs.google.com/document/d/1EIT2YE9qVkbk8FTKkhfBuAA56mgEnbDFtGcCBj3Gh_Q/edit?usp=sharing)

## Phase 1
### WISC-S24 ISA Specifications
1) **Compute Instructions**

    1.1) Saturating Arithmetic for add sub and pad sub (4 word add/sub)

    1.2) XOR  instruction
   
    1.3) Reduction

         --> Add top bytes and lower bytes
   
    1.4) Right rotation

         --> Take bytes off the LSB and append them to MSB
   
         --> Opcode is Rd,Rs, imm → (imm is 4 bit)

    1.5) SLL, SRA
   
3) **Memory Instructions**
   
    2.1) Load and Store word
   
         --> The LSB is always zero, so it is omitted in the instruction
   
    2.2) Load Lower and Upper Byte **NOT ACTUALLY MEMORY OPS** (More a register instruction)
   
4) **Control Instructions/Signals**
   
    3.1) Jump
   
    3.2) Branch
   
    3.3) PCS adds 2?
   
    3.4) HLT stops the next instruction
   
    3.5) Flags?	 (Seems more like a compute instruction)
   
         --> Set by other instructions for use in Branch
   
5) Compile? AKA translate instruct
   
6) **Integration**

7) **Memory** is provided?
