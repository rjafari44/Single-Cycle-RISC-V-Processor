`timescale 1ns / 1ps

module processor
(
    input clk, reset,
    output [31:0] Result
);

    // Internal wires connecting the three submodules
    wire [6:0] opcode;   // data_path → Controller
    wire [2:0] funct3;   // data_path → ALUController
    wire [6:0] funct7;   // data_path → ALUController
    wire [1:0] ALUOp;    // Controller → ALUController
    wire [3:0] ALU_CC;   // ALUController → data_path
    wire       ALUSrc;   // Controller → data_path
    wire       MemtoReg; // Controller → data_path
    wire       RegWrite; // Controller → data_path
    wire       MemRead;  // Controller → data_path
    wire       MemWrite; // Controller → data_path

    // Controller instantiation
    controller ctrl (
        .Opcode   (opcode),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .RegWrite (RegWrite),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUOp    (ALUOp)
    );

    // ALU Controller instantiation
    aluController alu_ctrl (
        .ALUOp     (ALUOp),
        .Funct7    (funct7),
        .Funct3    (funct3),
        .Operation (ALU_CC)
    );

    // Datapath instantiation
    dataPath dp (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (RegWrite),
        .mem2reg    (MemtoReg),
        .alu_src    (ALUSrc),
        .mem_write  (MemWrite),
        .mem_read   (MemRead),
        .alu_cc     (ALU_CC),
        .opcode     (opcode),
        .funct7     (funct7),
        .funct3     (funct3),
        .alu_result (Result)
    );

endmodule // processor