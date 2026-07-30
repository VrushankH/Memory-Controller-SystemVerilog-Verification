//=====================================================================
// driver.sv
// Drives generated transactions onto the interface (via drv_cb).
//=====================================================================
class driver;
    int                 no_transactions;
    virtual mem_if.DRV  vif;
    mailbox             gen2driv;

    function new(virtual mem_if.DRV vif, mailbox gen2driv);
        this.vif      = vif;
        this.gen2driv = gen2driv;
    endfunction

    // Hold the DUT in a clean, known state while reset is asserted
    task reset();
        wait(vif.rst);
        $display("[Driver] Reset Started");
        vif.drv_cb.we    <= 0;
        vif.drv_cb.re    <= 0;
        vif.drv_cb.addr  <= 0;
        vif.drv_cb.wdata <= 0;
        wait(!vif.rst);
        $display("[Driver] Reset Ended");
    endtask

    // Drive one transaction per iteration: assert we/re + addr/wdata for
    // exactly one clock, then deassert.
    task main();
        transaction trans;
        forever begin
            gen2driv.get(trans);
            @(vif.drv_cb);

            if (trans.op == WRITE) begin
                vif.drv_cb.we    <= 1;
                vif.drv_cb.re    <= 0;
                vif.drv_cb.addr  <= trans.addr;
                vif.drv_cb.wdata <= trans.wdata;
            end
            else begin // READ  
                vif.drv_cb.we    <= 0;
                vif.drv_cb.re    <= 1;
                vif.drv_cb.addr  <= trans.addr;
                vif.drv_cb.wdata <= 0;
            end

            @(vif.drv_cb);
            // Deassert controls after one active cycle
            vif.drv_cb.we <= 0;
            vif.drv_cb.re <= 0;

            trans.display("Driver");
            no_transactions++;
        end
    endtask
endclass