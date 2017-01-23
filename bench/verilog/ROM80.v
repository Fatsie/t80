module ROM80
  (input CE_n,
   input OE_n,
   input [14:0] A,
   output reg [7:0] D
  );
  
   reg [7:0]     ROM[0:7];

   initial
     $readmemh("/home/eda/Chips4Makers/run2017/playground/cpucores/t80/build/freecores.github.io_t80_T80_verilogROM_0/src/freecores.github.io_t80_T80_verilogROM_0/bench/verilog/ROM80.vh");
   
   always @(*)
     begin
	if (!OE_n & !CE_n)
	  begin
	     if (A[14:3] == 'b0)
	       D <= ROM[A];
	     else
	       D <= 'b00000000;
	  end
	else
	  D <= 'bzzzzzzzz;
     end // always @ (*)
endmodule // ROM80

	      
