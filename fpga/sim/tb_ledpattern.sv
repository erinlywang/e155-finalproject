/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_ledpattern module tests the ledpattern module 
// It checks that the right leds are on in sequence for each of the different FSM states

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_ledpattern(); 
	logic clk, reset, enable;
	logic play, roar, estop;
	logic [9:0] leds;
	logic ledstrip; 


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	led_pattern dut(clk, reset, enable, play, roar, estop, leds, ledstrip); 

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
		enable = 1;
		
		//// TEST STATE 0: OFF
		// Check pressed_row and pressed_col get the current row when moving into S1
		#10
		
		@(negedge clk);
		#1
		assert (leds == 10'b0) else $display("leds = %b (%b expected)", leds, 10'b0);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		//// TEST STATE 1: PLAYING

		@(posedge clk);
		
		$display("PLAYING STATE TESTBENCH RUNNING");
		
		#1
		play = 1;
		
		@(posedge clk);
		#1
		
		@(posedge clk);
		#1
		play = 0;
		assert (leds == 10'b00000_00001) else $display("leds = %b (%b expected)", leds, 10'b00000_00001);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
			
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00011) else $display("leds = %b (%b expected)", leds, 10'b00000_00011);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00111) else $display("leds = %b (%b expected)", leds, 10'b00000_00111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_01111) else $display("leds = %b (%b expected)", leds, 10'b00000_01111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_11111) else $display("leds = %b (%b expected)", leds, 10'b00000_11111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00000) else $display("leds = %b (%b expected)", leds, 10'b00000_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00001_00000) else $display("leds = %b (%b expected)", leds, 10'b00001_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00011_00000) else $display("leds = %b (%b expected)", leds, 10'b00011_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
			
		@(posedge clk);
		#1
		assert (leds == 10'b00111_00000) else $display("leds = %b (%b expected)", leds, 10'b00111_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
		
		@(posedge clk);
		#1
		assert (leds == 10'b01111_00000) else $display("leds = %b (%b expected)", leds, 10'b01111_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
		
		
		//// TEST STATE 4: ON

		@(posedge clk);
		
		$display("ON STATE TESTBENCH RUNNING");
		
		#1
		assert (leds == 10'b11111_00000) else $display("leds = %b (%b expected)", leds, 10'b11111_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);

		
		//// TEST STATE 3: ROARING

		@(posedge clk);
		
		$display("ROARING STATE TESTBENCH RUNNING");
		
		#1 
		roar = 1;
		
		@(posedge clk);
		#1
		
		@(posedge clk);
		#1
		roar = 0;
		assert (leds == 10'b00000_11111) else $display("leds = %b (%b expected)", leds, 10'b00000_11111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00000) else $display("leds = %b (%b expected)", leds, 10'b00000_00000);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
			
		@(posedge clk);
		#1
		assert (leds == 10'b00000_11111) else $display("leds = %b (%b expected)", leds, 10'b00000_11111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00000) else $display("leds = %b (%b expected)", leds, 10'b00000_00000);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
			
		@(posedge clk);
		#1
		assert (leds == 10'b00000_11111) else $display("leds = %b (%b expected)", leds, 10'b00000_11111);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		@(posedge clk);
		#1
		assert (leds == 10'b00000_00000) else $display("leds = %b (%b expected)", leds, 10'b00000_00000);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
			
		// Test goes back to on
		@(posedge clk);
		#1
		
		@(posedge clk);
		#1
		
		@(posedge clk);
		#1
		$display("ROARING TO OPEN STATE TESTBENCH RUNNING");
		assert (leds == 10'b11111_00000) else $display("leds = %b (%b expected)", leds, 10'b11111_00000);
		assert (ledstrip == 1'b1) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b1);
		
		//// TEST ESTOP
		@(posedge clk);
		
		$display("ESTOP STATE TESTBENCH RUNNING");
		
		#1 
		estop = 1; #22
		estop = 0;
		
		#10;
		@(posedge clk);
		#1
		assert (leds == 10'b0) else $display("leds = %b (%b expected)", leds, 10'b0);
		assert (ledstrip == 1'b0) else $display("ledstrip = %b (%b expected)", ledstrip, 1'b0);
		
		
		
		$finish;
	end 

endmodule