`timescale 1ns / 1ps

// Instruction memory for single-cycle RISC-V processor
// Holds 20 test instructions preceded by a NOP at index 0
// Address is byte-addressed; word index = addr[7:2]

module instMem (
    input  [7:0]  addr,
    output [31:0] instruction
);

    reg [31:0] memory [0:63];

    assign instruction = memory[addr[7:2]];

    initial begin
        // Index 0: NOP (required for synchronous reset)
        memory[0]  = 32'h00000000;

        // R-type and I-type arithmetic
        memory[1]  = 32'h00007033; // AND  r0,  r0,  r0       -> 0x00000000
        memory[2]  = 32'h00100093; // ADDI r1,  r0,  1        -> 0x00000001
        memory[3]  = 32'h00200113; // ADDI r2,  r0,  2        -> 0x00000002
        memory[4]  = 32'h00308193; // ADDI r3,  r1,  3        -> 0x00000004
        memory[5]  = 32'h00408213; // ADDI r4,  r1,  4        -> 0x00000005
        memory[6]  = 32'h00510293; // ADDI r5,  r2,  5        -> 0x00000007
        memory[7]  = 32'h00610313; // ADDI r6,  r2,  6        -> 0x00000008
        memory[8]  = 32'h00718393; // ADDI r7,  r3,  7        -> 0x0000000B
        memory[9]  = 32'h00208433; // ADD  r8,  r1,  r2       -> 0x00000003
        memory[10] = 32'h404404b3; // SUB  r9,  r8,  r4       -> 0xFFFFFFFE

        // R-type logical and comparison
        memory[11] = 32'h00317533; // AND  r10, r2,  r3       -> 0x00000000
        memory[12] = 32'h0041e5b3; // OR   r11, r3,  r4       -> 0x00000005
        memory[13] = 32'h0041a633; // SLT  r12, r3,  r4       -> 0x00000001
        memory[14] = 32'h007346b3; // NOR  r13, r6,  r7       -> 0xFFFFFFF4

        // I-type logical and comparison
        memory[15] = 32'h4d34f713; // ANDI r14, r9,  0x4D3    -> 0x000004D2
        memory[16] = 32'h8d35e793; // ORI  r15, r11, 0x8D3    -> 0xFFFFF8D7
        memory[17] = 32'h4d26a813; // SLTI r16, r13, 0x4D2    -> 0x00000001
        memory[18] = 32'h4d244893; // NORI r17, r8,  0x4D2    -> 0xFFFFFB2C

        // Memory access
        memory[19] = 32'h02b02823; // SW   r11, 48(r0)        -> 0x00000030
        memory[20] = 32'h03002603; // LW   r12, 48(r0)        -> 0x00000030
    end

endmodule // instMem