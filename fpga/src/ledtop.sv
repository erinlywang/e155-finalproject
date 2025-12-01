/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 11/17/2025

// ledtop module takes an input from MCU
// control a servo motor based on whether the capactive sensor
// has been touched or not. It also displays the angle of the servo

module ledtop(input	logic reset,
               input logic playpattern,
			   input logic roar,
               output logic [9:0] leds,
               output logic led_strip,
			   output logic roarstart);
  logic int_osc;
  logic clk_enable;
  
  // Internal high-speed oscillator
  HSOSC #(.CLKHF_DIV(2'b01))
  		  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  
  clk_div clk_div(int_osc, reset, clk_enable);
  led_pattern led_pattern(int_osc, reset, clk_enable, playpattern, roar, leds, led_strip);
  
  assign roarstart = roar;
  
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
        OFF:     if (~play)            		  nextstate = PLAYING;
                 else                      	  nextstate = OFF;
        PLAYING: if (pattern_index < 5'd11)   nextstate = PLAYING;
                 else                      	  nextstate = ON;
		ROARING: if (pattern_index < 5'd18)	  nextstate = ROARING;
				 else						  nextstate = ON;
        ON:		 if (~roar)					  nextstate = ROARING;
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
