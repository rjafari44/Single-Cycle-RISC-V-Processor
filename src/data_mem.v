`timescale 1ns / 1ps

// 512-byte data memory (128 x 32-bit words).
// Writes are synchronous (clocked on rising edge when MemWrite is high).
// Reads are combinational (output updates immediately when MemRead is high).
// Address is byte-addressed; the word index is derived from addr[8:2],
// ignoring the lower 2 bits to enforce word alignment.

module dataMem (
    input clk,
    input MemRead,             // Enable combinational read
    input MemWrite,            // Enable synchronous write
    input [8:0] addr,          // 9-bit byte address (word-aligned)
    input [31:0] write_data,   // Data to write (from rs2)
    output reg [31:0] read_data // Data read from memory
);

    reg [31:0] memory [127:0]; // 128 words of 32-bit storage
    wire [6:0] index;          // Word index derived from byte address

    // Drop the lower 2 bits to convert byte address to word index
    assign index = addr[8:2];

    // Synchronous write: data is written on the rising clock edge
    always @(posedge clk) begin
        if (MemWrite)
            memory[index] <= write_data;
    end

    // Combinational read: output is valid as long as MemRead is asserted
    always @(*) begin
        if (MemRead)
            read_data = memory[index];
        else
            read_data = 32'b0;
    end

endmodule // dataMem