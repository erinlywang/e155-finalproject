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