`timescale 1ns / 1ps

// Top-level datapath for the single-cycle RISC-V processor.
// Integrates the PC, instruction memory, register file, immediate generator,
// ALU source MUX, ALU, data memory, and writeback MUX.
// Control signals are driven externally by the controller and ALU controller.
// The opcode, funct3, and funct7 fields are extracted from the instruction
// and exposed as outputs so the control units can decode them.

module dataPath #(
    parameter PC_W      = 8,  // Program counter width in bits
    parameter INS_W     = 32, // Instruction width in bits
    parameter RF_ADDRESS = 5, // Register file address width (32 registers)
    parameter DATA_W    = 32, // Data path width in bits
    parameter DM_ADDRESS = 9, // Data memory address width
    parameter ALU_CC_W  = 4   // ALU control code width
)(
    input clk,
    input reset,
    input reg_write,               // Enable register file write
    input mem2reg,                 // Writeback source: 1 = memory, 0 = ALU
    input alu_src,                 // ALU B source: 1 = immediate, 0 = register
    input mem_write,               // Enable data memory write
    input mem_read,                // Enable data memory read
    input [ALU_CC_W-1:0] alu_cc,   // ALU operation code from ALU controller
    output [6:0] opcode,           // Instruction [6:0] to controller
    output [6:0] funct7,           // Instruction [31:25] to ALU controller
    output [2:0] funct3,           // Instruction [14:12] to ALU controller
    output [DATA_W-1:0] alu_result // ALU output exposed for testbench verification
);

    // Internal signals
    reg  [PC_W-1:0]  pc_out;                    // Current program counter value
    wire [PC_W-1:0]  pc_plus4;                  // Next PC value (PC + 4)
    wire [INS_W-1:0] instruction;               // Full 32-bit instruction from memory
    wire [DATA_W-1:0] rg_rd_data1, rg_rd_data2; // Register file read outputs
    wire [DATA_W-1:0] imm_out;                  // Sign-extended immediate
    wire [DATA_W-1:0] alu_b;                    // ALU B operand (register or immediate)
    wire [DATA_W-1:0] alu_out;                  // ALU computation result
    wire [DATA_W-1:0] dm_read_data;             // Data read from data memory
    wire [DATA_W-1:0] wb_data;                  // Data written back to register file
    wire              zero, overflow, carry_out; // ALU status flags (unused by control)
    wire [4:0]        rd, rs1, rs2;             // Destination and source register addresses

    // PC increments by 4 each cycle (byte addressing, 32-bit instructions)
    assign pc_plus4 = pc_out + 8'd4;

    // PC register with synchronous reset -- resets to 0, advances to PC+4 each cycle
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 0;
        else
            pc_out <= pc_plus4;
    end

    // Instruction memory: combinational read using PC as word-aligned address
    instMem imem (
        .addr(pc_out),
        .instruction(instruction)
    );

    // Instruction decode: extract fields from the 32-bit instruction word
    assign opcode = instruction[6:0];   // Determines instruction type
    assign rd     = instruction[11:7];  // Destination register
    assign funct3 = instruction[14:12]; // Operation subtype
    assign rs1    = instruction[19:15]; // Source register 1
    assign rs2    = instruction[24:20]; // Source register 2
    assign funct7 = instruction[31:25]; // Differentiates ADD/SUB and similar

    // Register file: synchronous write, asynchronous dual-port read
    regFile rf (
        .clk(clk),
        .reset(reset),
        .rg_wrt_en(reg_write),
        .rg_wrt_addr(rd),
        .rg_rd_addr1(rs1),
        .rg_rd_addr2(rs2),
        .rg_wrt_data(wb_data),
        .rg_rd_data1(rg_rd_data1),
        .rg_rd_data2(rg_rd_data2)
    );

    // Immediate generator: sign-extends the immediate field based on instruction type
    immGen imm (
        .InstCode(instruction),
        .ImmOut(imm_out)
    );

    // ALU source MUX: selects between register rs2 and sign-extended immediate
    mux32 alu_mux (
        .s(alu_src),
        .d0(rg_rd_data2), // s=0: R-type uses register
        .d1(imm_out),     // s=1: I-type and memory ops use immediate
        .y(alu_b)
    );

    // ALU: performs the operation specified by alu_cc on operands A and B
    alu32 alu (
        .A(rg_rd_data1),
        .B(alu_b),
        .Op(alu_cc),
        .Result(alu_out),
        .CarryOut(carry_out),
        .Overflow(overflow),
        .Zero(zero)
    );

    assign alu_result = alu_out;

    // Data memory: synchronous write, combinational read
    // Address is the word-aligned ALU result (used as effective memory address)
    dataMem dmem (
        .clk(clk),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .addr(alu_out[DM_ADDRESS-1:0]),
        .write_data(rg_rd_data2), // Store value comes from rs2
        .read_data(dm_read_data)
    );

    // Writeback MUX: selects between ALU result and memory read data
    mux32 wb_mux (
        .s(mem2reg),
        .d0(alu_out),     // s=0: write ALU result (R-type and I-type)
        .d1(dm_read_data), // s=1: write loaded data (LW)
        .y(wb_data)
    );

endmodule // dataPath