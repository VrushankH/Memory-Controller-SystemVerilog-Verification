//=====================================================================
// generator.sv
// Produces randomized transactions and sends them to the driver.
//=====================================================================
class generator;
    transaction trans;
    int         repeat_count;   // number of transactions to generate
    mailbox     gen2driv;
    event       ended;

    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    task main();
        repeat (repeat_count) begin
            trans = new();
            if (!trans.randomize())
                $display("[Generator] ERROR: Randomization failed");
            trans.display("Generator");
            gen2driv.put(trans);
        end
        -> ended;
    endtask
endclass