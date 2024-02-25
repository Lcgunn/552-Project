# Phase 1
## WISC-S24 ISA Specifications
1) **Compute Instructions**

    1.1) Saturating Arithmetic for add sub and pad sub (4 word add/sub)

    1.2) **XOR**  instruction
   
    1.3) Reduction (**RED**)

         --> Add top bytes and lower bytes
   
    1.4) Right Rotation (**ROR**)

         --> Take bytes off the LSB and append them to MSB
   
         --> Opcode Rd,Rs, imm → (imm is 4 bit)

    1.5) Logical Left Shift (**SLL**) and Arithmetic Right Shift (**SRA**)
   
2) **Memory Instructions**
   
    2.1) Load Word (**LW**) and Store Word (**SW**)
   
         --> The LSB is always zero, so it is omitted in the instruction

         --> Opcode Rt,Rs, offset
   
    2.2) Load Immediate Type: Load Lower Byte (**LLB**) and Load Higher Byte (**LHB**)
>[!Note]
>These two are not technically loading from memory but are grouped with memory instructions.
   
3) **Control Instructions/Signals**
   
    3.1) Branch (**B**)

         --> Conditionally jumps to the address obtained by: signed imm + (PC + 2)
   
    3.2) Branch Register (**BR**)

         --> Jumps to register
   
    3.3) **PCS**

         --> Saves the next PC into rd (PC + 2)

         --> PCS rd
   
    3.4) **HLT**

         --> Stops the advancement of PC

   
## Memory System   
1) Single-cycle Instruction Memory
2) Data Memory
>[!Note]
>Verilog modules are provided for both memories

## Implementation
1) Design
2) Reset Sequence
3) Flags
4) Interface
