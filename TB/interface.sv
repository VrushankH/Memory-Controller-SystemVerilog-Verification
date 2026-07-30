//=====================================================================
// interface.sv
// Connects the testbench to the mem_ctrl DUT.
// Two clocking blocks are used (one for the driver, one for the
// monitor) so that driving and sampling never race with the DUT's
// own always @(posedge clk) block.
//=====================================================================
interface mem_if(input logic clk, rst);

    logic       we;
    logic       re;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic       rvalid;

    // Driver's view: drives control/address/data, reads back rdata/rvalid
    clocking drv_cb @(posedge clk);
        default input #1 output #1;
        output we, re, addr, wdata;
        input  rdata, rvalid;
    endclocking

    // Monitor's view: purely passive, only ever reads
    clocking mon_cb @(posedge clk);
        default input #1;
        input we, re, addr, wdata, rdata, rvalid;
    endclocking

    modport DRV (clocking drv_cb, input clk, rst);
    modport MON (clocking mon_cb, input clk, rst);

endinterface