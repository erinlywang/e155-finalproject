/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 11/17/2025

// top module takes an input from the GPIO pin of the MCU to
// control a servo motor based on whether the capactive sensor
// has been touched or not. It also displays the angle of the servo

module top( input	logic reset,
			output	logic pwm);
			
	logic int_osc;
		
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b01))
		  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    
    logic [31:0] counter;
    // Module implementation goes here
    
    always_ff @(posedge int_osc) begin
		if (reset==0)		 begin
			counter <= 32'd0;
		end
        else if (counter >= 32'd480000) begin
            counter <= 32'd0;
        end
		else				begin
			counter <= counter + 32'd1;
		end
	end

    assign pwm = (counter < 32'd36000) ? 1'b1 : 1'b0; // 1ms pulse for 90 degrees
			
	
endmodule