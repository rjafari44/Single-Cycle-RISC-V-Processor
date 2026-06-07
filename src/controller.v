`timescale 1ns / 1ps

module controller (
    Opcode,
    ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite,
    ALUOp
);

    // Port declarations
    input  [6:0] Opcode;
    output       ALUSrc;
    output       MemtoReg;
    output       RegWrite;
    output       MemRead;
    output       MemWrite;
    output [1:0] ALUOp;

    // Opcode parameters
    localparam R_TYPE = 7'b0110011; // AND, OR, ADD, SUB, SLT, NOR
    localparam I_TYPE = 7'b0010011; // ANDI, ORI, ADDI, SLTI, NORI
    localparam LOAD   = 7'b0000011; // LW
    localparam STORE  = 7'b0100011; // SW

    // Assignments
    assign MemtoReg = (Opcode == LOAD)   ? 1'b1 : 1'b0;
    assign MemRead  = (Opcode == LOAD)   ? 1'b1 : 1'b0;
    assign MemWrite = (Opcode == STORE)  ? 1'b1 : 1'b0;
    assign RegWrite = (Opcode == STORE)  ? 1'b0 : 1'b1;
    assign ALUSrc   = (Opcode == R_TYPE) ? 1'b0 : 1'b1;

    assign ALUOp    = (Opcode == R_TYPE) ? 2'b10 :
                      (Opcode == I_TYPE) ? 2'b00 :
                      /* LOAD or STORE */ 2'b01;

endmodule // controller