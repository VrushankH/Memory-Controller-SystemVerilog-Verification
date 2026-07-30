//=====================================================================
// coverage.sv
// Functional coverage collector.
// Tracks:
//   - operation type (write / read)
//   - address regions (including the two boundary addresses)
//   - cross of operation x address region, so we know both write
//     AND read have been exercised across the full memory map
//=====================================================================
class coverage;
    mailbox     mon2cov;
    transaction trans;

    covergroup mem_cg;
        option.per_instance = 1;

        cp_op : coverpoint trans.op {
            bins write = {WRITE};
            bins read  = {READ};
        }

        cp_addr : coverpoint trans.addr {
            bins edge_lo = {8'h00};
            bins edge_hi = {8'hFF};
            bins low     = {[8'h01 : 8'h3F]};
            bins mid_lo  = {[8'h40 : 8'h7F]};
            bins mid_hi  = {[8'h80 : 8'hBF]};
            bins high    = {[8'hC0 : 8'hFE]};
        }

        cross_op_addr : cross cp_op, cp_addr;
    endgroup

    function new(mailbox mon2cov);
        this.mon2cov = mon2cov;
        mem_cg = new();
    endfunction

    task main();
        forever begin
            mon2cov.get(trans);
            mem_cg.sample();
        end
    endtask

    function void report();
        $display("=====================================================");
        $display(" FUNCTIONAL COVERAGE: %0.2f %%", mem_cg.get_coverage());
        $display("=====================================================");
    endfunction
endclass