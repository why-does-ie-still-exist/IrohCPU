`timescale 1ns/1ns
module memtest_TB();

reg tclk;
reg [7:0] taddr;
reg tenable;
reg twEnable;
reg [15:0] tnewWord;
wire [15:0] twordOut;

internal_mem aMemory(.clk(tclk), .addr(taddr), .enable(tenable), .wEnable(twEnable), .newWord(tnewWord), .wordOut(twordOut));

always #(10/2) tclk = ~tclk;

initial begin
    tclk = 1'b0;
    #30
    taddr = 8'd0;
    tenable = 1'b1;
    #10
    tenable = 1'b0;
    #10
    taddr = 8'd1;
    tenable = 1'b1;
    tnewWord = 16'd50000;
    twEnable = 1'b1;
    #10;
    twEnable = 1'b0;
end

endmodule
