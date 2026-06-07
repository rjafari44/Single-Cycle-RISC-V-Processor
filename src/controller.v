`timescale 1ns / 1ps

// Combinational controller that decodes the 7-bit opcode and drives all
// datapath control signals. Also produces a 2-bit ALUOp code that tells
// the ALU controller which class of instruction is being executed.
// No clock input -- outputs update immediately whenever Opcode changes.

module controller (
    Opcode,
    ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite,
    ALUOp
);

    input  [6:0] Opcode;
    output       ALUSrc;   // 1 = ALU B operand is immediate, 0 = register
    output       MemtoReg; // 1 = write memory read data to register (LW only)
    output       RegWrite; // 1 = write result to register file (all except SW)
    output       MemRead;  // 1 = read from data memory (LW only)
    output       MemWrite; // 1 = write to data memory (SW only)
    output [1:0] ALUOp;    // 10 = R-type, 00 = I-type, 01 = LW/SW

    // Opcode constants for each supported instruction class
    localparam R_TYPE = 7'b0110011; // AND, OR, ADD, SUB, SLT, NOR
    localparam I_TYPE = 7'b0010011; // ANDI, ORI, ADDI, SLTI, NORI
    localparam LOAD   = 7'b0000011; // LW
    localparam STORE  = 7'b0100011; // SW

    // MemtoReg and MemRead are only asserted for LW
    assign MemtoReg = (Opcode == LOAD)   ? 1'b1 : 1'b0;
    assign MemRead  = (Opcode == LOAD)   ? 1'b1 : 1'b0;

    // MemWrite is only asserted for SW
    assign MemWrite = (Opcode == STORE)  ? 1'b1 : 1'b0;

    // RegWrite is asserted for everything except SW
    assign RegWrite = (Opcode == STORE)  ? 1'b0 : 1'b1;

    // ALUSrc selects the immediate for I-type, LW, and SW; register for R-type
    assign ALUSrc   = (Opcode == R_TYPE) ? 1'b0 : 1'b1;

    // ALUOp encodes the instruction class for the ALU controller
    assign ALUOp    = (Opcode == R_TYPE) ? 2'b10 :
                      (Opcode == I_TYPE) ? 2'b00 :
                      /* LOAD or STORE */ 2'b01;

endmodule // controller