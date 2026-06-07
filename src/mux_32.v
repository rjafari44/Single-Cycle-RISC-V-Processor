`timescale 1ns / 1ps

// 32-bit 2-to-1 multiplexer.
// Used twice in the datapath:
//   1. ALU source MUX: selects between register rs2 and sign-extended immediate
//   2. Writeback MUX: selects between ALU result and data memory read output
// Output defaults to d0 for any unrecognized select value.

module mux32 (
    input        s,          // Select signal: 0 = d0, 1 = d1
    input [31:0] d0,         // Input selected when s = 0
    input [31:0] d1,         // Input selected when s = 1
    output reg [31:0] y      // Selected output
);

    always @(*) begin
        case (s)
            1'b0:    y = d0;
            1'b1:    y = d1;
            default: y = d0;
        endcase
    end

endmodule // mux32