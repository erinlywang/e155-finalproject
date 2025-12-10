/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_synchronizer module tests the synchronizer module 
// It uses different clock cycles to verify the input value is getting displayed the expected amount of clock cycles later on output
// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_synchronizer(); 
	logic clk, reset;
	logic async_in, sync_out; 


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	synchronizer dut(clk, reset, async_in, sync_out); 

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
		
		#10
		
		//// TEST SYNC_OUT GETS ASYNC_IN
		
		$display("TEST SYNC_OUT GETS ASYNC_IN RUNNING");

		@(posedge clk);
		#1
		async_in = 1;
		
		#1
		@(posedge clk);
		#1
		
		@(posedge clk);
		#1
		assert (sync_out == async_in) else $display("sync_out = %b (%b expected)", sync_out, async_in);
		
		$finish;
	end 

endmodule