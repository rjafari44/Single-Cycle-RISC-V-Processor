`timescale 1ns / 1ps

// 32-bit ALU supporting AND, OR, ADD, SUB, SLT, NOR, and EQ operations.
// Op is a 4-bit control code produced by the ALU controller.
// A 33-bit temp register is used for ADD and SUB to capture the carry bit
// without losing the 32-bit result.

module alu32 (
    input  [31:0] A,        // First operand
    input  [31:0] B,        // Second operand (register or sign-extended immediate)
    input  [3:0]  Op,       // 4-bit operation code from ALU controller
    output reg [31:0] Result,
    output reg        CarryOut,
    output reg        Overflow,
    output reg        Zero
);

    reg [32:0] temp; // Extra bit captures carry out of bit 31

    always @(*) begin
        // Default all outputs to zero before evaluating the operation
        Result   = 32'b0;
        CarryOut = 1'b0;
        Overflow = 1'b0;
        Zero     = 1'b0;
        temp     = 33'b0;

        case (Op)

            4'b0000: begin
                // AND: bitwise AND of A and B
                Result = A & B;
                Zero = (Result == 0);
            end

            4'b0001: begin
                // OR: bitwise OR of A and B
                Result = A | B;
                Zero = (Result == 0);
            end

            4'b0010: begin
                // ADD: unsigned addition using 33-bit temp to capture carry
                temp     = {1'b0, A} + {1'b0, B};
                Result   = temp[31:0];
                CarryOut = temp[32];
                // Signed overflow: pos+pos=neg or neg+neg=pos
                Overflow = (($signed(A) > 0 && $signed(B) > 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) < 0 && $signed(Result) > 0));
                Zero = (Result == 0);
            end

            4'b0110: begin
                // SUB: unsigned subtraction using 33-bit temp
                temp   = {1'b0, A} - {1'b0, B};
                Result = temp[31:0];
                // Signed overflow: pos-neg=neg or neg-pos=pos
                Overflow = (($signed(A) > 0 && $signed(B) < 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) > 0 && $signed(Result) > 0));
                Zero = (Result == 0);
            end

            4'b0111: begin
                // SLT: set Result to 1 if A < B (signed comparison), else 0
                Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
                Zero = (Result == 0);
            end

            4'b1100: begin
                // NOR: bitwise NOR, equivalent to inverting the OR of A and B
                Result = ~(A | B);
                Zero = (Result == 0);
            end

            4'b1111: begin
                // EQ: set Result to 1 if A equals B, else 0
                Result = (A == B) ? 32'b1 : 32'b0;
                Zero = (Result == 0);
            end

            default: begin
                // Unrecognized op code defaults to ADD
                temp     = {1'b0, A} + {1'b0, B};
                Result   = temp[31:0];
                CarryOut = temp[32];
                Overflow = (($signed(A) > 0 && $signed(B) > 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) < 0 && $signed(Result) > 0));
                Zero = (Result == 0);
            end

        endcase
    end

endmodule // alu32