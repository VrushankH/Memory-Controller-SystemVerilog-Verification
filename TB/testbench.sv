//=====================================================================
// testbench.sv
// Top-level module: generates clock/reset, instantiates the
// interface + DUT, and pulls in all testbench class files.
//=====================================================================
`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "environment.sv"
`include "test.sv"

module top;
    bit clk, rst;

    always #5 clk = ~clk;

    initial begin
        rst = 1;
        #12 rst = 0;   // hold reset comfortably past the first clock edge
    end

    mem_if i_intf(clk, rst);

    test t1(i_intf);

    mem_ctrl dut (
        .clk    (i_intf.clk),
        .rst    (i_intf.rst),
        .we     (i_intf.we),
        .re     (i_intf.re),
        .addr   (i_intf.addr),
        .wdata  (i_intf.wdata),
        .rdata  (i_intf.rdata),
        .rvalid (i_intf.rvalid)
    );

    initial begin
        $dumpfile("mem_ctrl.vcd");
        $dumpvars;
    end
endmodule