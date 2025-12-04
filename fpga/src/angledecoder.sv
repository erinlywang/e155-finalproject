module angledecoder(  input  logic        clk,
                      input  logic        reset,
                      input  logic        captouch,
                      input  logic        irblock,
                      input  logic        estop,
                      output logic [7:0]  angle,
					  output logic [1:0]  led2);
    
    typedef enum logic [1:0]  {CLOSED, OPENED, SLIGHT} statetype;
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
                if (captouch)    	nextstate = OPENED;
                else                nextstate = CLOSED;
            OPENED: 
                if (estop)          nextstate = CLOSED;
                else if (irblock)   nextstate = SLIGHT;
                else 				nextstate = OPENED;
            SLIGHT:
                if (estop)          nextstate = CLOSED;
                else                nextstate = OPENED;
            default: nextstate = CLOSED;
        endcase
    end
	
	always_comb begin
        // Output logic based on state
        case (state)
            CLOSED:    angle = 8'd30;      // 30 degrees
            OPENED:      angle = 8'd150;    // 150 degrees
            SLIGHT:    angle = 8'd90;     // 90 degrees
            default:   angle = 8'd0;
        endcase
    end
	
	assign led2[0] = (state == CLOSED);
	assign led2[1] = (state == OPENED);
	/*
	assign led[2] = (state == OPENED);
	*/

    
endmodule