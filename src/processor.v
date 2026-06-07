`timescale 1ns / 1ps

// Top-level single-cycle RISC-V processor.
// Instantiates the controller, ALU controller, and datapath, and connects
// them with internal wires. The only external ports are the clock, reset,
// and the 32-bit ALU result output used for verification.

module processor
(
    input clk, reset,
    output [31:0] Result  // ALU result output, used by testbench for verification
);

    // Instruction fields from datapath to control units
    wire [6:0] opcode;   // Bits [6:0]   -- instruction type
    wire [2:0] funct3;   // Bits [14:12] -- operation subtype
    wire [6:0] funct7;   // Bits [31:25] -- differentiates ADD vs SUB and similar

    // Control signals between controller and datapath
    wire       ALUSrc;   // Selects immediate (1) or register (0) as ALU B operand
    wire       MemtoReg; // Selects memory data (1) or ALU result (0) for writeback
    wire       RegWrite; // Enables write to register file
    wire       MemRead;  // Enables data memory read
    wire       MemWrite; // Enables data memory write

    // ALUOp passes instruction class from controller to ALU controller
    wire [1:0] ALUOp;

    // ALU_CC is the 4-bit operation code from ALU controller to datapath
    wire [3:0] ALU_CC;

    // Controller decodes opcode into datapath control signals and ALUOp
    controller ctrl (
        .Opcode   (opcode),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .RegWrite (RegWrite),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUOp    (ALUOp)
    );

    // ALU controller decodes ALUOp + Funct3 + Funct7 into the ALU operation code
    aluController alu_ctrl (
        .ALUOp     (ALUOp),
        .Funct7    (funct7),
        .Funct3    (funct3),
        .Operation (ALU_CC)
    );

    // Datapath executes the instruction using the control signals
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