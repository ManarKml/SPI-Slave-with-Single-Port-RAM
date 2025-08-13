module slave (
	input MOSI, SS_n, clk, rst_n, tx_valid,
	input [7:0] tx_data,
	output reg MISO, rx_valid,
	output reg [9:0] rx_data
	);

// State encoding
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter READ_ADD = 3'b010;
parameter READ_DATA = 3'b011;
parameter WRITE = 3'b100;

reg [2:0] cs, ns;  						// Current state and next state
reg [4:0] counter; 						// Bit counter for shifting operations
reg [10:0] shift_reg; 					// Shift register for incoming MOSI bits
reg [7:0] tx_shift_reg;					// Shift register for outgoing MISO bits
reg flag; 								// Tracks whether READ_ADD has completed

/* Bit counter control */
always @(posedge clk) begin
	if (~rst_n) 
		counter <= 0; 					// Reset counter
	else if (SS_n)
		counter <= 0;					// Reset when SS_n goes high
	else if (cs != IDLE) 
		// Reset counter at the end of each transaction phase
		if (cs != READ_DATA && counter == 11)
			counter <= 0;
		else if (cs == READ_DATA && counter == 20)
			counter <= 0;
		else
			counter <= counter + 1;		// Increment per clock
	else 
		counter <= 0;
end


/* Shift in MOSI bits MSB first (shift_reg[0] is first bit received) */
always @(posedge clk) begin
    if (~rst_n)
        shift_reg <= 11'd0;				// Reset shift register
    else if (~SS_n && cs != IDLE)  		// Active select and not idle
        shift_reg <= {shift_reg[9:0], MOSI}; // Shift left & input new MOSI bit
    else
        shift_reg <= 11'd0;				// Clear shift reg when deselected
end

/* State Memory & flag update */
always @(posedge clk) begin
	if (~rst_n) begin
		cs <= IDLE;						// Reset state
		flag <= 1'b0;					// Reset flag
	end
	else begin
		cs <= ns;						// Move to next state
	end

	// Update flag depending on state
    if (cs == READ_ADD) 
        flag <= 1'b1;
    else if (cs == READ_DATA) 
    	flag <= 1'b0;
end

/* Next State Logic */
always @(*) begin
	case (cs)
		IDLE: 
			if (SS_n) 
				ns = IDLE;				// Wait for SS_n low
			else 
				ns = CHK_CMD;
		CHK_CMD: begin
            if (SS_n)
                ns = IDLE;
            else if (counter) begin
            	if (shift_reg[0]) begin // Command bit = 1 -> read
                	ns = flag ? READ_DATA : READ_ADD;
            	end else begin
                	ns = WRITE; 		// Command bit = 0 -> write
            	end
            end
        end
		READ_ADD: 
			if (SS_n) 
				ns = IDLE;
			else if (counter == 11)
				ns = READ_ADD;			// Stay here until full address received
		READ_DATA: 
			if (SS_n)
				ns = IDLE;
			else if (counter == 11)
				ns = READ_DATA;			// Stay until data read state finishes
		WRITE: 
			if (SS_n)
				ns = IDLE;
			else if (counter == 11)
				ns = WRITE;
		default: ns = IDLE;
	endcase
end

/* Output Logic */
always @(posedge clk) begin
	if (~rst_n) begin
		// reset
		MISO <= 1'd0;
		rx_valid <= 1'd0;
		rx_data <= 10'd0;
		tx_shift_reg <= 8'd0;
	end
	else begin
		case (cs)
		IDLE, CHK_CMD: begin
			MISO <= 1'd0;
			rx_valid <= 1'd0;
			rx_data <= 10'd0;
		end
		READ_ADD: begin
			MISO <= 1'b0;
			rx_valid <= 1'b0;
			if (counter == 11) begin 		// After 10 bits & command
				rx_data <= shift_reg[9:0];	// Save received address
				rx_valid <= 1'b1;			// Mark as valid
			end
			else 
				rx_valid <= 1'b0;
		end
		READ_DATA: begin
			rx_valid <= 1'b0;
            if (counter == 11) begin 		// Capture any MOSI data
            	rx_data <= shift_reg[9:0];
				rx_valid <= 1'b1;
			end
			else if (counter == 13) begin 	// Load data to send
    			tx_shift_reg <= tx_data;  	// Store outgoing data
    			MISO <= tx_data[7];       	// Output MSB immediately
			end 
			else if (counter > 13) begin  	// Continue shifting bits
   				tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};  
    			MISO <= tx_shift_reg[6];  	// Output next MSB bit
			end
			else begin
				MISO <= 1'b0;				// Default low
			end
		end
		WRITE: begin
			rx_valid <= 1'b0;
            MISO <= 1'b0;
            if (counter == 11) begin
                rx_data <= shift_reg[9:0];	// Save received data
                rx_valid <= 1'b1;  			// Mark as valid for RAM write
            end 
		end
		default: begin
			MISO <= 1'b0;
			rx_valid <= 1'b0;
			rx_data <= 10'd0;
		end
		endcase
	end
end
endmodule

