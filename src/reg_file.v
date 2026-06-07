`timescale 1ns / 1ps

// 32x32 register file with dual-port asynchronous read and single-port synchronous write.
// Register 0 is hardwired to zero -- writes to address 0 are ignored.
// All registers are cleared to zero on reset.
// Reads are combinational: output is valid immediately after address is applied.
// Writes are clocked: data is written on the rising clock edge when rg_wrt_en is high.

module regFile (
    input clk,
    input reset,
    input        rg_wrt_en,           // Write enable
    input  [4:0] rg_wrt_addr,         // Destination register address (rd)
    input  [4:0] rg_rd_addr1,         // Source register 1 address (rs1)
    input  [4:0] rg_rd_addr2,         // Source register 2 address (rs2)
    input  [31:0] rg_wrt_data,        // Data to write to destination register
    output wire [31:0] rg_rd_data1,   // Data read from rs1
    output wire [31:0] rg_rd_data2    // Data read from rs2
);

    reg [31:0] register_file [31:0]; // 32 general-purpose registers
    integer i;

    // Synchronous write with asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear all registers on reset
            for (i = 0; i < 32; i = i + 1)
                register_file[i] <= 32'b0;
        end
        else if (rg_wrt_en && (rg_wrt_addr != 0)) begin
            // Write to destination register, skipping register 0 (hardwired zero)
            register_file[rg_wrt_addr] <= rg_wrt_data;
        end
    end

    // Asynchronous reads: return 0 if address is undefined (handles simulation X states)
    assign rg_rd_data1 = (rg_rd_addr1 === 5'bx) ? 32'b0 : register_file[rg_rd_addr1];
    assign rg_rd_data2 = (rg_rd_addr2 === 5'bx) ? 32'b0 : register_file[rg_rd_addr2];

endmodule // regFile