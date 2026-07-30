//=====================================================================
// monitor.sv
// Passively observes the bus (via mon_cb) and reconstructs the
// transaction actually seen by the DUT. Forwards a copy to both
// the scoreboard (for checking) and the coverage collector
// (for functional coverage).
//=====================================================================
class monitor;
    virtual mem_if.MON vif;
    mailbox            mon2scb;
    mailbox            mon2cov;

    function new(virtual mem_if.MON vif, mailbox mon2scb, mailbox mon2cov);
        this.vif     = vif;
        this.mon2scb = mon2scb;
        this.mon2cov = mon2cov;
    endfunction

    task main();
        forever begin
            transaction trans;

            @(vif.mon_cb);
            // Wait until the driver asserts either write or read enable
            wait (vif.mon_cb.we || vif.mon_cb.re);

            trans        = new();
            trans.op     = vif.mon_cb.we ? WRITE : READ;
            trans.addr   = vif.mon_cb.addr;
            trans.wdata  = vif.mon_cb.wdata;

            if (trans.op == READ) begin
                // rdata / rvalid appear one cycle after re is sampled
                @(vif.mon_cb);
                trans.rdata  = vif.mon_cb.rdata;
                trans.rvalid = vif.mon_cb.rvalid;
            end

            mon2scb.put(trans);
            mon2cov.put(trans);
            trans.display("Monitor");
        end
    endtask
endclass