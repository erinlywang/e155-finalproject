/// Author: Erin Wang
/// Email: erinwang@g.hmc.edu
/// Date: 09/23/2025

// tb_debouncer module tests the debouncer module 
// It applies a row and whether the previous input has been debounced
// and outputs the col to send power to as well as which row is pressed

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_angledecoder(); 
	logic clk, reset;
	logic captouch, irblock, estop; //input
    logic [7:0]  angle; //output
	logic [2:0]  led;


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	angledecoder dut(clk, reset, captouch, irblock, estop, angle, led); 
	
	logic [3:0] i;

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
		
		//// TEST STATE 0: CLOSED
		// Check pressed_row and pressed_col get the current row when moving into S1
		#10
		
		@(negedge clk);
		#1
		assert (angle == 8'd30) else $display(" angle = %d (%d expected)", angle, 8'd30);
		
		//// TEST STATE 1: OPEN

		#42
		
		$display("CURRENT TESTBENCH RUNNING");
		
		#1
		captouch = 1;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd150) else $display(" angle = %d (%d expected)", angle, 8'd150);
		
		//// TEST STATE 2: SLIGHTLY

		@(posedge clk);
		#1
		irblock = 1;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd90) else $display(" angle = %d (%d expected)", angle, 8'd90);
		
		
		
		$finish;
	end 

endmodule