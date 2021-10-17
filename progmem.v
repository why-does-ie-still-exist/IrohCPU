module internal_mem( input clk,
  input [7:0] addr,
  input enable,
  input wEnable,
  input [15:0] newWord,
  output [15:0] wordOut
   );

 reg [15:0] internal_memory[255:0] ;

initial begin
 $readmemb("program.dat", internal_memory);
 end

 always @ (posedge clk) begin
     if(wEnable) begin
         internal_memory[addr] <= newWord;
     end
 end
 assign wordOut =  enable ?  internal_memory[addr]: '0 ;
endmodule