`timescale 1ns / 1ps

// Testbench for the single-cycle RISC-V processor.
// Drives clock and reset, then checks the ALU result output against
// the expected value for each of the 20 pre-loaded instructions.
// Results are reported per instruction -- pass or fail with expected vs actual.
// A summary at the end shows the total number of passing tests.

module tb_processor ();

    reg         clk;
    reg         rst;
    wire [31:0] result;

    // Instantiate processor under test
    processor uut (
        .clk    (clk),
        .reset  (rst),
        .Result (result)
    );

    // Tracking variables
    integer passed = 0;
    integer failed = 0;
    integer cycle  = 0;

    // Task to check one instruction result and report pass or fail
    task check;
        input [31:0] expected;
        input [63:0] name; // 8-char instruction label packed into 64 bits
        begin
            cycle = cycle + 1;
            if (result == expected) begin
                $display("PASS  cycle %02d  %-6s  result = 0x%08x", cycle, name, result);
                passed = passed + 1;
            end else begin
                $display("FAIL  cycle %02d  %-6s  expected = 0x%08x  got = 0x%08x", cycle, name, expected, result);
                failed = failed + 1;
            end
        end
    endtask

    // Clock generation: 20 ns period (50 MHz)
    initial clk = 0;
    always #10 clk = ~clk;

    // Reset sequence: hold high for two falling clock edges then release
    initial begin
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
    end

    // Main test sequence
    initial begin
        $display("--------------------------------------------------");
        $display("  RISC-V Single-Cycle Processor Testbench");
        $display("--------------------------------------------------");

        @(negedge rst);   // Wait for reset to release
        @(posedge clk);   // Sync to first active clock edge

        // Check each instruction result on the falling edge of each cycle
        @(negedge clk); check(32'h00000000, "AND   ");
        @(negedge clk); check(32'h00000001, "ADDI  ");
        @(negedge clk); check(32'h00000002, "ADDI  ");
        @(negedge clk); check(32'h00000004, "ADDI  ");
        @(negedge clk); check(32'h00000005, "ADDI  ");
        @(negedge clk); check(32'h00000007, "ADDI  ");
        @(negedge clk); check(32'h00000008, "ADDI  ");
        @(negedge clk); check(32'h0000000b, "ADDI  ");
        @(negedge clk); check(32'h00000003, "ADD   ");
        @(negedge clk); check(32'hfffffffe, "SUB   ");
        @(negedge clk); check(32'h00000000, "AND   ");
        @(negedge clk); check(32'h00000005, "OR    ");
        @(negedge clk); check(32'h00000001, "SLT   ");
        @(negedge clk); check(32'hfffffff4, "NOR   ");
        @(negedge clk); check(32'h000004d2, "ANDI  ");
        @(negedge clk); check(32'hfffff8d7, "ORI   ");
        @(negedge clk); check(32'h00000001, "SLTI  ");
        @(negedge clk); check(32'hfffffb2c, "NORI  ");
        @(negedge clk); check(32'h00000030, "SW    ");
        @(negedge clk); check(32'h00000030, "LW    ");

        $display("--------------------------------------------------");
        $display("  Results: %0d / %0d passed", passed, passed + failed);
        $display("--------------------------------------------------");

        $finish;
    end

    // Simulation timeout in case something hangs
    initial begin
        #500;
        $display("TIMEOUT: simulation exceeded 500 ns");
        $finish;
    end

endmodule // tb_processor