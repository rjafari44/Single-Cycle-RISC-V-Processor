`timescale 1ns / 1ps

// Combinational ALU controller that produces a 4-bit operation code for the ALU.
// Uses ALUOp from the controller along with Funct3 and Funct7 from the instruction
// to distinguish between instructions that share the same opcode class.
//
// ALUOp encoding:   10 = R-type, 00 = I-type, 01 = LW/SW
//
// Operation encoding:
//   AND / ANDI          0000
//   OR  / ORI           0001
//   ADD / ADDI / LW /SW 0010
//   SUB                 0110
//   SLT / SLTI          0111
//   NOR / NORI          1100

module aluController (
    ALUOp, Funct7, Funct3, Operation
);

    input  [1:0] ALUOp;    // Instruction class from controller
    input  [6:0] Funct7;   // Instruction bits [31:25]
    input  [2:0] Funct3;   // Instruction bits [14:12]
    output [3:0] Operation; // 4-bit ALU operation code

    // Operation[0]: high for OR/ORI (Funct3=110) and SLT/SLTI (Funct3=010, not LW/SW)
    // LW/SW share Funct3=010 but have ALUOp[0]=1, so they are excluded by the ALUOp check
    assign Operation[0] =
        ((Funct3 == 3'b110) || ((Funct3 == 3'b010) && (ALUOp[0] == 1'b0)))
        ? 1'b1 : 1'b0;

    // Operation[1]: high for any instruction using Funct3=000 or Funct3=010
    // covers ADD, ADDI, SUB, SLT, SLTI, LW, SW -- everything except AND, OR, NOR variants
    assign Operation[1] =
        ((Funct3 == 3'b000) || (Funct3 == 3'b010))
        ? 1'b1 : 1'b0;

    // Operation[2]: high for NOR/NORI (Funct3=100), SLT/SLTI (Funct3=010 excluding LW/SW),
    // and SUB (Funct3=000 with Funct7[5]=1, R-type only)
    assign Operation[2] =
        ((Funct3 == 3'b100) ||
         ((Funct3 == 3'b010) && (ALUOp[0] == 1'b0)) ||
         ((Funct3 == 3'b000) && (Funct7[5] == 1'b1) && (ALUOp[1] == 1'b1)))
        ? 1'b1 : 1'b0;

    // Operation[3]: high only for NOR/NORI (Funct3=100)
    assign Operation[3] =
        (Funct3 == 3'b100) ? 1'b1 : 1'b0;

endmodule // aluController