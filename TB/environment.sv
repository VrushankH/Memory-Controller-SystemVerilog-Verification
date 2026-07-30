//=====================================================================
// environment.sv
// Instantiates and wires up every testbench component, and drives
// the overall pre_test / test / post_test flow.
//=====================================================================
class environment;
    generator  gen;
    driver     driv;
    monitor    mon;
    scoreboard scb;
    coverage   cov;

    mailbox gen2driv;
    mailbox mon2scb;
    mailbox mon2cov;

    virtual mem_if vif;

    function new(virtual mem_if vif);
        this.vif = vif;

        gen2driv = new();
        mon2scb  = new();
        mon2cov  = new();

        gen  = new(gen2driv);
        driv = new(vif, gen2driv);          // narrows to intf.DRV automatically
        mon  = new(vif, mon2scb, mon2cov);  // narrows to intf.MON automatically
        scb  = new(mon2scb);
        cov  = new(mon2cov);
    endfunction

    task pre_test();
        driv.reset();
    endtask

    task test();
        fork
            gen.main();
            driv.main();
            mon.main();
            scb.main();
            cov.main();
        join_any
    endtask

    task post_test();
        wait(gen.ended.triggered);
        wait(gen.repeat_count == driv.no_transactions);
        wait(gen.repeat_count == scb.no_transactions);
        scb.report();
        cov.report();
    endtask

    task run();
        pre_test();
        test();
        post_test();
        $finish;
    endtask
endclass