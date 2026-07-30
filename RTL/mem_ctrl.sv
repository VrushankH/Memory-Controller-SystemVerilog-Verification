//=====================================================================
// design.sv
// DUT: Memory Read/Write Controller
//=====================================================================
// A simple synchronous memory controller with:
//   - a 256 x 8-bit internal memory array
//   - one write-enable (we) and one read-enable (re) input
//   - synchronous write:  mem[addr] <= wdata      (when we=1)
//   - synchronous read:   rdata    <= mem[addr]   (when re=1)
//     the read result becomes valid ONE cycle after 're' is asserted,
//     flagged by 'rvalid'
//   - if we and re are both asserted in the same cycle, write wins
//     (priority chosen and documented so the testbench/scoreboard
//      can model the same behavior)
//=====================================================================
module mem_ctrl (
    input              clk,
    input              rst,
    input              we,      // write enable
    input              re,      // read enable
    input      [7:0]   addr,    // memory address (256 locations)
    input      [7:0]   wdata,   // write data
    output reg [7:0]   rdata,   // read data (valid one cycle after re)
    output reg         rvalid   // pulses high the cycle rdata is valid
);

    // Internal memory array
    reg [7:0] mem [0:255];
    integer   i;

    always @(posedge clk) begin
        if (rst) begin
            rdata  <= 8'h00;
            rvalid <= 1'b0;
            // Explicitly clear every location so read-before-write behavior
            // is well-defined and matches the scoreboard's reference model
            // (which also assumes all-zero at reset), instead of relying on
            // whatever a given simulator defaults uninitialized memory to.
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 8'h00;
        end
        else begin
            rvalid <= 1'b0;              // default: no valid read this cycle

            if (we) begin
                mem[addr] <= wdata;       // synchronous write (priority over read)
            end
            else if (re) begin
                rdata  <= mem[addr];      // synchronous read
                rvalid <= 1'b1;
            end
        end
    end

endmodule