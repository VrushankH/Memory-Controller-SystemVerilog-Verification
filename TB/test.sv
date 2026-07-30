//=====================================================================
// test.sv
// Top-level test: builds the environment and kicks off the run.
//=====================================================================
program test(mem_if i_intf);
    environment env;

    initial begin
        env = new(i_intf);
        env.gen.repeat_count = 100;   // was 50 -- more tries, more likely to catch the last bin
        env.run();
    end
endprogram