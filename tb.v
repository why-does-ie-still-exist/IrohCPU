`timescale 1ns/1ns
module CPU_tb();
reg clk;
reg memclk;
reg rst;

always #(10/2) clk = ~clk;
always #(10/2) memclk = ~memclk;

IrohCPU mycpu(clk, memclk, rst);

initial begin
    rst = 1'b1;
    clk = 1'b0;
    memclk = 1'b0;
    #10
    rst = 1'b0;
end

endmodule
