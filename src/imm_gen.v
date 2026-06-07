`timescale 1ns / 1ps

// Immediate generator that sign-extends the immediate field of an instruction
// to 32 bits. The format depends on the instruction type, identified by the opcode.
//
// Supported formats:
//   I-type (LW, ANDI, ORI, ADDI, SLTI, NORI): bits [31:20] sign-extended to 32 bits
//   S-type (SW):                               bits [31:25] and [11:7] concatenated and sign-extended
//   U-type (AUIPC):                            bits [31:12] shifted left by 12 (lower 12 bits zeroed)
//   All others (R-type):                       output is zero since no immediate is used

module immGen (
    input  [31:0] InstCode, // Full 32-bit instruction word
    output reg [31:0] ImmOut // Sign-extended immediate output
);

    always @(*) begin
        case (InstCode[6:0])

            7'b0000011: // LW (I-type): sign-extend bits [31:20]
                ImmOut = {{20{InstCode[31]}}, InstCode[31:20]};

            7'b0010011: // ANDI, ORI, ADDI, SLTI, NORI (I-type): sign-extend bits [31:20]
                ImmOut = {{20{InstCode[31]}}, InstCode[31:20]};

            7'b0100011: // SW (S-type): concatenate imm[11:5] and imm[4:0], then sign-extend
                ImmOut = {{20{InstCode[31]}}, InstCode[31:25], InstCode[11:7]};

            7'b0010111: // AUIPC (U-type): upper 20 bits placed in [31:12], lower 12 zeroed
                ImmOut = {InstCode[31:12], 12'b0};

            default: // R-type and unrecognized: no immediate, output zero
                ImmOut = 32'b0;

        endcase
    end

endmodule // immGen