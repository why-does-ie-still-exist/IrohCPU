`timescale 1ns/1ns
module ALU_tb ();
    reg [7:0] tfirstArg;
    reg [7:0] tsecondArg;
    reg tisAdding;
    wire toverflow;
    wire tisZero;
    wire tunsignedOverflow;
    wire tsign;
    wire [7:0] tresult;

    alu aALU( .firstArg(tfirstArg), .secondArg(tsecondArg), .isAdding(tisAdding),
    .overflow(toverflow), .unsignedOverflow(tunsignedOverflow), .isZero(tisZero),
    .sign(tsign), .result(tresult) );
    
    initial begin
        tisAdding = 1'b1;
        tfirstArg = +8'd5;
        tsecondArg = +8'd25;
        #10
        tisAdding = 1'b0;
        #10
        tsecondArg = -8'd5;
        #10
        tisAdding = 1'b1;
    end

endmodule
