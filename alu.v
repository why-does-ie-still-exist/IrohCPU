module add1 ( input a, input b, input cin,   output sum, output cout );
    assign cout = (a & b) | (cin & (a ^ b));
    assign sum = (a ^ b ^ cin);
endmodule

module add8( 
    input [7:0] a,
    input [7:0] b,
    input cin,
    output cout,
    output [7:0] sum);
    
    wire [7:0] carries;
    assign cout = carries[7];
    genvar i;
    generate
        for(i = 0; i <= 7; i = i + 1) begin: looping
            if(i == 0) begin: first_adder
                add1 firstadder(.a(a[i]), .b(b[i]), .cin(cin), .sum(sum[i]), .cout(carries[i]));
            end else begin: other_adders
                add1 adder1(.a(a[i]), .b(b[i]), .cin(carries[i - 1]), .sum(sum[i]), .cout(carries[i]));
            end
        end
    endgenerate

endmodule

module alu(
    input [7:0] firstArg,
    input [7:0] secondArg,
    input isAdding,
    output overflow,
    output unsignedOverflow,
    output isZero,
    output sign,
    output [7:0] result );

    wire [7:0] updatedSecond = isAdding ? secondArg : ~secondArg;

    assign isZero = result == 8'b0;
    assign sign = result[7];

    assign overflow = (isAdding & ((firstArg[7] & secondArg[7] & ~result[7]) | (~firstArg[7] & ~secondArg[7] & result[7]))) |
    (~isAdding & ((firstArg[7] & ~secondArg[7] & ~result[7]) | (~firstArg[7] & secondArg[7] & result[7])));

    // always @ * begin
    //     overflow = 1'b0;
    //     if(isAdding) begin
    //         if(firstArg[7] & secondArg[7] & ~result[7]) begin
    //             overflow = 1'b1;
    //         end else if(~firstArg[7] & ~secondArg[7] & result[7]) begin
    //             overflow = 1'b1;
    //         end
    //     end else begin
    //         if(firstArg[7] & ~secondArg[7] & ~result[7]) begin
    //             overflow = 1'b1;
    //         end else if(~firstArg[7] & secondArg[7] & result[7]) begin
    //             overflow = 1'b1;
    //         end
    //     end
    // end

    add8 adder(.a(firstArg), .b(updatedSecond), .cin(~isAdding), .cout(unsignedOverflow), .sum(result));
endmodule