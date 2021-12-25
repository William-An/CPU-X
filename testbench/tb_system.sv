`timescale 1ns/1ns
module tb_system;
	
    localparam CLK_PERIOD = 10;
    logic tb_clk;
    logic tb_nrst;

    system dut(tb_clk, tb_nrst);

    always #CLK_PERIOD tb_clk = ~tb_clk;

    initial begin
        tb_clk = 1'b0;
        tb_nrst = 1'b1;

        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b0;
        repeat (3) @(posedge tb_clk);
        tb_nrst = 1'b1;
        repeat (3) @(posedge tb_clk);

        repeat (100) @(posedge tb_clk);
        $stop;
    end
endmodule