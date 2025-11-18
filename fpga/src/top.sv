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
			output	logic pwm);
			
	logic int_osc;
    logic sync_captouch, sync_irblock, sync_estop;
    logic [7:0] angle;
		
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b01))
		  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    
    synchronizer sync_captouch(int_osc, captouch, sync_captouch);
    synchronizer sync_irblock(int_osc, irblock, sync_irblock);
    synchronizer sync_estop(int_osc, estop, sync_estop);
    angledecoder angle_dec(int_osc, reset, sync_captouch, sync_irblock, sync_estop, angle);
    pwmgen pwm_generator(int_osc, reset, angle, pwm);
				
endmodule

module synchronizer( input  logic        clk,
                     input  logic        async_in,
                     output logic        sync_out);
    
    logic sync_reg1;
    
    always_ff @(posedge clk) begin
        // Synchronization logic
        sync_reg1 <= async_in;
        sync_out <= sync_reg1;
    end
endmodule

module angledecoder(  input  logic        clk,
                      input  logic        reset,
                      input  logic        captouch,
                      input  logic        irblock,
                      input  logic        estop,
                      output logic [7:0]  angle);
    
    typedef enum logic [2:0]  {CLOSED, OPEN, SLIGHT} statetype;
	statetype state, nextstate;

    always_ff @(posedge clk) begin
		if (reset==0)		 begin
			state <= CLOSED;
		end
		else				begin
			state <= nextstate;
		end
	end

    always_comb begin
        // State transition logic
        case (state)
            CLOSED: 
                if (captouch)       nextstate = OPEN;
                else                nextstate = CLOSED;
            OPEN: 
                if (estop)          nextstate = CLOSED;
                else if (irblock)   nextstate = SLIGHT;
                else nextstate = OPEN;
            SLIGHT:
                if (estop)          nextstate = CLOSED;
                else                nextstate = OPEN;
            default: nextstate = CLOSED;
        endcase
    end

    always_comb begin
        // Output logic based on state
        case (state)
            CLOSED:    angle = 8'd30;      // 30 degrees
            OPEN:      angle = 8'd150;    // 150 degrees
            SLIGHT:    angle = 8'd90;     // 90 degrees
            default:   angle = 8'd0;
        endcase
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
			8'd30:     pwm = (counter < 32'd25000) ? 1'b1 : 1'b0; // 1ms pulse for 30 degrees
			8'd150:    pwm = (counter < 32'd50000) ? 1'b1 : 1'b0; // 3ms pulse for 150 degrees (seems to be near upper limit)
			8'd90:    pwm = (counter < 32'd38000) ? 1'b1 : 1'b0; // 2ms pulse for 90 degrees
            default:  pwm = 1'b0; // Default case
        endcase
    end    


endmodule
	
