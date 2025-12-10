/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_angledecoder module tests the angledecoder module 
// It checks the expected angle at each capacitive touch state

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_angledecoder(); 
	logic clk, reset, clk_enable;
	logic captouch, irblock, estop; //input
    logic [7:0]  angle; //output
	logic [2:0]  led;


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	angledecoder dut(clk, reset, clk_enable, captouch, irblock, estop, angle, led); 

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
		clk_enable = 1;
		
		//// TEST STATE 0: CLOSED
		// Check pressed_row and pressed_col get the current row when moving into S1
		#10
		
		@(negedge clk);
		#1
		assert (angle == 8'd30) else $display(" angle = %d (%d expected)", angle, 8'd30);
		
		//// TEST STATE 1: OPEN

		@(posedge clk);
		
		$display("OPEN STATE TESTBENCH RUNNING");
		
		#1
		captouch = 1;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd150) else $display(" angle = %d (%d expected)", angle, 8'd150);
		captouch = 0;
			
		//// TEST STATE 1: OPEN to CLOSE

		@(posedge clk);
		
		$display("OPEN to CLOSE TESTBENCH RUNNING");
		
		#1
		estop = 1; #22
		estop = 0;
		clk_enable = 1;
		
		#10
		
		@(posedge clk);
		#1
		assert (angle == 8'd30) else $display(" angle = %d (%d expected)", angle, 8'd150);
		
		//// TEST STATE 2: SLIGHT and stays in SLIGHT

		@(posedge clk);
		#1 
		captouch = 1;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd150) else $display(" angle = %d (%d expected)", angle, 8'd150);
		captouch = 0;
		
		$display("SLIGHT STATE TESTBENCH RUNNING");
		
		@(posedge clk);
		#1
		irblock = 1;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd90) else $display(" angle = %d (%d expected)", angle, 8'd90);
			
		@(posedge clk);
		
		$display("STAY IN SLIGHT STATE TESTBENCH RUNNING");
		
		#1
		assert (angle == 8'd90) else $display(" angle = %d (%d expected)", angle, 8'd90);
			
		//// TEST STATE 2: SLIGHT to OPEN

		@(posedge clk);
		
		$display("SLIGHT TO OPEN STATE TESTBENCH RUNNING");
		
		#1
		irblock = 0;
		
		#1
		
		@(posedge clk);
		#1
		assert (angle == 8'd150) else $display(" angle = %d (%d expected)", angle, 8'd90);
			
		//// TEST STATE 2: SLIGHT to CLOSE
		
		@(posedge clk);
		
		$display("OPEN TO SLIGHT RUNNING");
		
		#1
		irblock = 1;
		
		#10
			
		@(posedge clk);
		assert (angle == 8'd90) else $display(" angle = %d (%d expected)", angle, 8'd90);
		irblock = 0;
		
		@(posedge clk);
		
		$display("SLIGHT TO CLOSE STATE TESTBENCH RUNNING");
		
		#1
		estop = 1; #22
		estop = 0;
		clk_enable = 1;
		
		#10
		
		@(posedge clk);
		#1
		
		#1
		assert (angle == 8'd30) else $display(" angle = %d (%d expected)", angle, 8'd90);
		
		
		
		$finish;
	end 

endmodule