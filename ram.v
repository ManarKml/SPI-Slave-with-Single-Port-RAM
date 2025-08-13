module async_ram_sp #(
	parameter MEM_DEPTH = 256, 
	parameter ADDR_SIZE = 8
	) (
	input [9:0] din,
	input clk, rst_n, rx_valid,
	output reg [7:0] dout,
	output reg tx_valid
	);

// Memory array
reg [7:0] mem [MEM_DEPTH-1:0];

// Read and write address registers
reg [ADDR_SIZE-1:0] R_Addr, W_Addr;

// Main RAM operation block
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		// reset
		dout <= 8'd0;
		tx_valid <= 1'b0;
		R_Addr <= 8'b0;
		W_Addr <= 8'b0;
	end
	else if (rx_valid) begin
		case (din[9:8])
		2'b00: begin 				// WRITE ADDRESS COMMAND
			W_Addr <= din[7:0];
			tx_valid <= 1'b0;
		end 
		2'b01: begin 				// WRITE DATA COMMAND
			mem[W_Addr] <= din[7:0];
			tx_valid <= 1'b0;
		end 
		2'b10: begin  				// READ ADDRESS COMMAND
			R_Addr <= din[7:0];
			tx_valid <= 1'b0;
		end 
		default: begin  			// READ DATA COMMAND
			dout <= mem[R_Addr];
			tx_valid <= 1'b1;		// Indicate data is valid
		end
		endcase
	end
	else begin
		tx_valid <= 1'b0;			// No valid input -> clear tx_valid
	end
end
endmodule