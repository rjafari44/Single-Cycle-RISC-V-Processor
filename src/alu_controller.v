`timescale 1ns / 1ps

module aluController (
    ALUOp, Funct7, Funct3, Operation
);

    // Port declarations
    input  [1:0] ALUOp;
    input  [6:0] Funct7;
    input  [2:0] Funct3;
    output [3:0] Operation;

    // -----------------------------------------------------------------------
    // Boolean equations derived from the truth table.
    // ALUOp[1]=1 → R-type, ALUOp[0]=1 → LW/SW, ALUOp=00 → I-type
    //
    // Operation encoding:
    //   AND/ANDI  0000
    //   OR/ORI    0001
    //   ADD/ADDI/LW/SW 0010
    //   SUB       0110
    //   SLT/SLTI  0111
    //   NOR/NORI  1100
    // -----------------------------------------------------------------------

    // Operation[0]: OR/ORI (Funct3=110), or SLT/SLTI (Funct3=010 and ALUOp!=01)
    // Note: LW/SW also have Funct3=010 but ALUOp[0]=1, so they are excluded here.
    // (base equation provided by the lab; kept as-is)
    assign Operation[0] =
        ((Funct3 == 3'b110) || ((Funct3 == 3'b010) && (ALUOp[0] == 1'b0)))
        ? 1'b1 : 1'b0;

    // Operation[1]: 1 for ADD/ADDI/LW/SW (Funct3=000 or Funct3=010)
    //               Also covers SUB and SLT/SLTI which share those Funct3 values.
    //               AND/ANDI (111), OR/ORI (110), NOR/NORI (100) all give 0.
    assign Operation[1] =
        ((Funct3 == 3'b000) || (Funct3 == 3'b010))
        ? 1'b1 : 1'b0;

    // Operation[2]: NOR/NORI (Funct3=100),
    //               SLT/SLTI (Funct3=010, ALUOp[0]=0 excludes LW/SW),
    //               SUB      (Funct3=000, Funct7[5]=1, ALUOp[1]=1 for R-type)
    assign Operation[2] =
        ((Funct3 == 3'b100) ||
         ((Funct3 == 3'b010) && (ALUOp[0] == 1'b0)) ||
         ((Funct3 == 3'b000) && (Funct7[5] == 1'b1) && (ALUOp[1] == 1'b1)))
        ? 1'b1 : 1'b0;

    // Operation[3]: NOR/NORI only (Funct3=100)
    assign Operation[3] =
        (Funct3 == 3'b100) ? 1'b1 : 1'b0;

endmodule // aluController