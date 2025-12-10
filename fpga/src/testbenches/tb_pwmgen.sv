/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_pwmgen module tests the pwm module for helping set the angles of the servo motors
// It uses asserts to check the values at different angle states

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module tb_pwmgen(); 
	logic clk, reset;
	logic [7:0] angle; 
	logic pwm; //output


	//// Instantiate device under test (DUT). 
	// Inputs: s Outputs: sel, trans0, trans1
	pwmgen dut(clk, reset, angle, pwm); 

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
		
		//// TEST PWM HIGH BEFORE 30000(ANGLE 30)

		@(posedge clk);
		#1
		$display("ANGLE 30 STATE TESTBENCH RUNNING");
		angle = 8'd30;
		
		@(posedge clk);
		#1
		assert (pwm == 1'b1) else $display("pwm = %b (%b expected)", pwm, 1'b1);
		
		#300001 	// counter = 30000 cycles
		
		@(posedge clk);
		#1
		assert (pwm == 1'b0) else $display("pwm = %b (%b expected)", pwm, 1'b0);
		
		// Reset 
		reset = 0;
		angle =  8'd0; #22
		reset = 1;
		
		#10
		
		
		//// TEST PWM HIGH BEFORE 60000 (ANGLE 150)

		@(posedge clk);
		#1
		$display("ANGLE 150 STATE TESTBENCH RUNNING");
		angle = 8'd150;
		
		@(posedge clk);
		#1
		assert (pwm == 1'b1) else $display("pwm = %b (%b expected)", pwm, 1'b1);
		
		#600000 	// counter = 60000 cycles
		
		@(posedge clk);
		#1
		assert (pwm == 1'b0) else $display("pwm = %b (%b expected)", pwm, 1'b0);
			
		// Reset 
		reset = 0;
		angle =  8'd0; #22
		reset = 1;
		
		#10
		
		//// TEST PWM HIGH BEFORE 40000 (ANGLE 90)

		@(posedge clk);
		#1
		$display("ANGLE 90 STATE TESTBENCH RUNNING");
		assert (pwm == 1'b0) else $display("pwm = %b (%b expected)", pwm, 1'b0);
		angle = 8'd90;
		
		@(posedge clk);
		#1
		assert (pwm == 1'b1) else $display("pwm = %b (%b expected)", pwm, 1'b1);
		
		#400000 	// counter = 40000 cycles
		
		@(posedge clk);
		#1
		assert (pwm == 1'b0) else $display("pwm = %b (%b expected)", pwm, 1'b0);
		
		$finish;
	end 

endmodule