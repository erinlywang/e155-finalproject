/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 12/4/2025

// tb_top module tests the top module for HSOSC since each individual module is tested for both values and timing

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns


module tb_top();

	logic reset;
	logic captouch;
    logic irblock;
    logic estop;
	logic pwm;
	logic [9:0] leds;
	logic led_strip;
	logic [2:0] led;		
		
	//// Instantiating device under test (DUT)
	// inputs: reset, captouch, irblock, estop | outputs: pwm, leds, led_strip, led
	top dut(reset, captouch, irblock, estop, pwm, leds, led_strip, led);
		

	//// Testing HSOSC
	initial begin
		reset = 0; #22;
		reset = 1;

		captouch = 0;
		irblock = 0;
		estop = 0;

		#100;
		captouch = 1;

		#200;
		$stop;
	end
		

endmodule
	
