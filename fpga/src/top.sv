/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 11/17/2025

// top module takes an input from the GPIO pin of the MCU to
// control a servo motor based on whether the capactive sensor
// has been touched or not. It also displays the angle of the servo

module top( input	logic reset,
		    input	logic captouch,
            input   logic irblock,
            input   logic estop,
			output	logic pwm,
			output	logic [9:0] leds,
			output	logic led_strip,
			output	logic [2:0] led);
			
	logic int_osc;
    logic sync_captouch, sync_irblock, sync_estop;
	logic clk_enable;
    logic [7:0] angle;
	logic [1:0] led2;
		
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b01))
		  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
		  
	assign led[0] = sync_captouch;
	assign led[1] = led2[0];
	assign led[2] = led2[1];
    
    synchronizer sync_cap(int_osc, reset, captouch, sync_captouch);
    synchronizer sync_ir(int_osc, reset, irblock, sync_irblock);
	synchronizer sync_e(int_osc, reset, estop, sync_estop);
    angledecoder angledecoder(int_osc, reset, sync_captouch, sync_irblock, sync_estop, angle, led2);
    pwmgen pwm_generator(int_osc, reset, angle, pwm);
	
	clk_div clk_div(int_osc, reset, clk_enable);
	led_pattern led_pattern(int_osc, reset, clk_enable, sync_captouch, sync_irblock, leds, led_strip);
				
endmodule

module synchronizer( input  logic        clk,
					 input	logic		 reset,
                     input  logic        async_in,
                     output logic        sync_out);
    
    logic sync_reg1;
    
    always_ff @(posedge clk) begin
		if (reset == 0) begin
			sync_reg1 <= 1'b0;
			sync_out <= 1'b0;
		end
		else			begin
			// Synchronization logic
			//sync_out <= async_in;
			sync_reg1 <= async_in;
			sync_out <= sync_reg1;
		end
    end
endmodule


module pwmgen(  input  logic        clk,
                input  logic        reset,
                input  logic [7:0]  angle,
                output logic        pwm);
    
    logic [31:0] counter;
    // Module implementation goes here
    
    always_ff @(posedge clk) begin
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

    always_comb begin
        // PWM generation logic based on angle
        case (angle)
			8'd30:     pwm = (counter < 32'd36000) ? 1'b1 : 1'b0; // 1ms pulse for CLOSED
			8'd150:    pwm = (counter < 32'd60000) ? 1'b1 : 1'b0; // 3ms pulse for OPEN (seems to be near upper limit)
			8'd90:    pwm = (counter < 32'd45000) ? 1'b1 : 1'b0; // 2ms pulse for SLIGHT
            default:  pwm = 1'b0; // Default case
        endcase
    end    


endmodule

module led_pattern(
    input  logic clk,
    input  logic reset,
	input  logic enable,
    input  logic play,  // Signal to play pattern
	input  logic roar,
    output logic [9:0] leds,
    output logic led_strip
);
	  logic [23:0] counter;
	  logic counter_output;

    // Pattern memory - 15 patterns
  logic [10:0] pattern_mem [0:17];
    
    typedef enum logic [3:0]  {OFF, PLAYING, ROARING, ON} statetype;
	  statetype state, nextstate;
    
    // Initialize patterns using initial block
    // Pattern goes 16'bwwwww_ggggg_strip
    initial begin
      pattern_mem[0]  = 11'b00000_00000_0;  // Strip off, all LEDs off
      pattern_mem[1]  = 11'b00000_00001_0;  // Strip off, first green LED
      pattern_mem[2]  = 11'b00000_00011_0;  
      pattern_mem[3]  = 11'b00000_00111_0;  
      pattern_mem[4]  = 11'b00000_01111_0;  
      pattern_mem[5]  = 11'b00000_11111_0;  // All green on
      pattern_mem[6]  = 11'b00000_00000_1;  // Strip on, all LEDS off
      pattern_mem[7]  = 11'b00001_00000_1;  // Start circling white lights
      pattern_mem[8]  = 11'b00011_00000_1;
      pattern_mem[9]  = 11'b00111_00000_1;
      pattern_mem[10] = 11'b01111_00000_1;
      pattern_mem[11] = 11'b11111_00000_1; // Strip on, all white LEDs on
	  pattern_mem[12] = 11'b00000_11111_0; // Start blinking green leds
	  pattern_mem[13] = 11'b00000_00000_0; 
	  pattern_mem[14] = 11'b00000_11111_0; // Start blinking green leds
	  pattern_mem[15] = 11'b00000_00000_0; 
	  pattern_mem[16] = 11'b00000_11111_0; // Start blinking green leds
	  pattern_mem[17] = 11'b00000_00000_0; 
    end
    
    // Pattern index counter
  logic [4:0] pattern_index, nextpattern_index;  // 0-17
    
    // Cycle through patterns
	
    always_ff @(posedge clk) begin
      if (reset==0)     	begin
        state <= OFF;
        pattern_index <= 4'd0;
      end
      else if (enable)   begin 
        state <= nextstate;
        pattern_index <= nextpattern_index;
      end
	  else				begin
		  state <= state;
		  pattern_index <= pattern_index;
	  end
    end
	
    // Next state logic
    always_comb begin
      case (state)
        OFF:     if (play)            		  nextstate = PLAYING;
                 else                      	  nextstate = OFF;
        PLAYING: if (pattern_index < 5'd11)   nextstate = PLAYING;
                 else                      	  nextstate = ON;
		ROARING: if (pattern_index < 5'd18)	  nextstate = ROARING;
				 else						  nextstate = ON;
        ON:		 if (roar)					  nextstate = ROARING;
				 else						  nextstate = ON; 
        default:                              nextstate = OFF;
      endcase
    end

    // Next pattern index logic
    always_comb begin
      case (state)
        OFF:         nextpattern_index = 5'd0;
        PLAYING:     nextpattern_index = (pattern_index < 5'd11) ? pattern_index + 1 : 5'd11;
		ROARING:     nextpattern_index = pattern_index + 1;
        ON:          nextpattern_index = 5'd11;
		default:	 nextpattern_index = pattern_index;
      endcase
    end
    
    // Output current LED pattern
    assign leds      = pattern_mem[pattern_index][10:1]; // 10 LED bits
    assign led_strip = pattern_mem[pattern_index][0];  // 1 strip bit
	
	/*
	assign leds[0] = (state == ON);
	assign leds[1] = (pattern_index == 5'd14);
	*/
endmodule

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
	
