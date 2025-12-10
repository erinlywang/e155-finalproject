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
			8'd30:     pwm = (counter < 32'd30000) ? 1'b1 : 1'b0; // 1ms pulse for CLOSED
			8'd150:    pwm = (counter < 32'd60000) ? 1'b1 : 1'b0; // 3ms pulse for OPEN (seems to be near upper limit)
			8'd90:     pwm = (counter < 32'd40000) ? 1'b1 : 1'b0; // 2ms pulse for SLIGHT
            default:  pwm = 1'b0; // Default case
        endcase
    end    


endmodule