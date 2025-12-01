/// Author: Erin Wang and Caiya Coggshall
/// Email: erinwang@g.hmc.edu, ccoggshall@g.hmc.edu
/// Date: 11/17/2025

// ledtop module takes an input from the GPIO pin of the MCU to
// control a servo motor based on whether the capactive sensor
// has been touched or not. It also displays the angle of the servo

module led_top(input	logic reset,
               input logic playpattern,
               output logic [9:0] leds,
               output logic led_strip);
  logic int_osc;
  
  // Internal high-speed oscillator
  HSOSC #(.CLKHF_DIV(2'b01))
  		  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  
  clkdiv clk_div(int_osc, reset, slow_clk);
  ledpat led_pattern(slow_clk, reset, playpattern, leds, led_strip);
endmodule

module led_pattern(
    input  logic clk,
    input  logic reset,
    input  logic playpattern,  // Signal to play pattern
    output logic [9:0] leds,
    output logic led_strip
);

    // Pattern memory - 15 patterns
  logic [10:0] pattern_mem [0:11];
    
    typedef enum logic [2:0]  {OFF, PLAYING, ON} statetype;
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
    end
    
    // Pattern index counter
  logic [3:0] pattern_index, nextpattern_index;  // 0-11
    
    // Cycle through patterns
    always_ff @(posedge clk or posedge reset) begin
      if (reset)     begin
        state <= OFF;
        pattern_index <= 4'd0;
      end
      else           begin 
        state <= nextstate;
        pattern_index <= nextpattern_index;
      end
    end

    // Next state logic
    always_comb begin
      case (state)
        OFF:     if (playpattern)          nextstate = PLAYING;
                 else                      nextstate = OFF;
        PLAYING: if (pattern_index < 4'd11)   nextstate = PLAYING;
                 else                      nextstate = ON;
        ON:                                nextstate = ON; 
        default:                           nextstate = OFF;
      endcase
    end

    // Next pattern index logic
    always_comb begin
      case (state)
        OFF:         nextpattern_index = 4'd0;
        PLAYING:     nextpattern_index = (pattern_index < 4'd11) ? pattern_index + 1 : 4'd11;
        ON:          nextpattern_index = 4'd11; 
      endcase
    end
    
    // Output current LED pattern
    assign leds      = pattern_mem[pattern_index][10:1]; // 10 LED bits
    assign led_strip = pattern_mem[pattern_index][0];  // 1 strip bit

endmodule

module clk_div(
    input  logic clk,
    input  logic reset,
    output logic slow_clk);
  
  logic [23:0] clk_div;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      clk_div <= 24'd0;
    else
      clk_div <= clk_div + 1;
  end
  
  assign slow_clk = clk_div[20]; // Use MSB as slow clock
  
endmodule
