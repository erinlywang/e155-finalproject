/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_clkdiv module tests the clkdiv module 
// It checks that the clock divider is running as expected

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_clkdiv(); 
	logic clk, reset;
	logic clk_enable; 


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	clk_div dut(clk, reset, clk_enable); 

	//// Generate clock at 24 MHz
	always begin 
		clk=1; #5;  
		clk=0; #5; 
	end 

	//// Start of test.  
	initial begin 
		//// Pulse reset for 22 time units(2.2 cycles) so the reset signal falls after a clk edge. 
		reset=0; #22;  
		reset=1; 
		
		@(posedge clk);
		#1
		
		//// TEST clk_enable HIGH at 2000000
		
		$display("TEST clk_enable RUNNING");
		
		#20000000 // 2000000 cycles

		@(posedge clk);
		#1
		assert (clk_enable == 1'b1) else $display("clk_enable = %b (%b expected)", clk_enable, 1'b1);
			
		@(posedge clk);
		#1
		assert (clk_enable == 1'b0) else $display("clk_enable = %b (%b expected)", clk_enable, 1'b0);
		
		$finish;
	end 

endmodule