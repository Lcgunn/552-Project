# 552-Project
Creating a MIPS-style CPU

Notes for Organizing Tasks: [here](https://docs.google.com/document/d/1EIT2YE9qVkbk8FTKkhfBuAA56mgEnbDFtGcCBj3Gh_Q/edit?usp=sharing)

## Phase 1
### WISC-S24 ISA Specifications
1) **Compute Instructions**

    1.1) Saturating Arithmetic for add sub and pad sub (4 word add/sub)

    1.2) XOR  instruction
   
    1.3) Reduction (RED)

         --> Add top bytes and lower bytes
   
    1.4) Right Rotation (ROR)

         --> Take bytes off the LSB and append them to MSB
   
         --> Opcode Rd,Rs, imm → (imm is 4 bit)

    1.5) Logical Left Shift (SLL) and Arithmetic Right Shift (SRA)
   
2) **Memory Instructions**
   
    2.1) Load Word (LW) and Store Word (SW)
   
         --> The LSB is always zero, so it is omitted in the instruction

         --> Opcode Rt,Rs, offset
   
    2.2) Load Immediate Type: Load Lower Byte (LLB) and Load Higher Byte (LHB)
   >[!Note]
   >These two are not technically loading from memory but are grouped with memory instructions.
   
4) **Control Instructions/Signals**
   
    3.1) Jump
   
    3.2) Branch
   
    3.3) PCS adds 2?
   
    3.4) HLT stops the next instruction
   
    3.5) Flags?	 (Seems more like a compute instruction)
   
         --> Set by other instructions for use in Branch
   
6) Compile? AKA translate instruct
   
7) **Integration**

8) **Memory** is provided?
