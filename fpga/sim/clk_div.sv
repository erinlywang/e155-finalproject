module clk_div(
    input  logic clk,
    input  logic reset,
    output logic clk_enable);
  
  logic [23:0] counter;
  //logic counter_output;
	
	// Counter
	always_ff @(posedge clk) begin
		if (reset==0)		begin
			counter <= 24'b0;
		end
		else if (counter == 24'd4000000)	begin
			counter <= 24'b0;
		end
		else				begin
			counter <= counter + 24'b1;
		end
	end
  
  assign clk_enable = (counter==24'd2000000);
  
endmodule