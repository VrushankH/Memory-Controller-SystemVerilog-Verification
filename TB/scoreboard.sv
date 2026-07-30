//=====================================================================
// scoreboard.sv
// Self-checking reference model.
//   - WRITE : updates an internal shadow memory (no DUT check needed
//             here -- correctness is proven later, by READs)
//   - READ  : compares the DUT's reported rdata against the shadow
//             memory's contents at that address
//=====================================================================
class scoreboard;
    mailbox mon2scb;
    int     no_transactions;
    int     pass_count;
    int     fail_count;

    // Reference / shadow memory, kept in lock-step with the DUT
    bit [7:0] ref_mem [0:255];

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
        foreach (ref_mem[i])
            ref_mem[i] = 8'h00;   // matches DUT's memory state after reset
    endfunction

    task main();
        transaction trans;
        forever begin
            mon2scb.get(trans);

            if (trans.op == WRITE) begin
                ref_mem[trans.addr] = trans.wdata;
                $display("[Scoreboard] WRITE addr=%0d data=%0d (model updated)",
                           trans.addr, trans.wdata);
            end
            else begin // READ
                if (trans.rvalid && (trans.rdata == ref_mem[trans.addr])) begin
                    $display("[Scoreboard] READ  addr=%0d PASS (data=%0d)",
                               trans.addr, trans.rdata);
                    pass_count++;
                end
                else begin
                    $display("[Scoreboard] READ  addr=%0d FAIL: expected=%0d actual=%0d rvalid=%0b",
                               trans.addr, ref_mem[trans.addr], trans.rdata, trans.rvalid);
                    fail_count++;
                end
            end

            trans.display("Scoreboard");
            no_transactions++;
        end
    endtask

    function void report();
        $display("=====================================================");
        $display(" SCOREBOARD SUMMARY: %0d reads checked -> %0d PASS, %0d FAIL",
                   pass_count + fail_count, pass_count, fail_count);
        $display("=====================================================");
    endfunction
endclass