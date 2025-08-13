module tb();
reg clk, rst_n, MOSI, SS_n;
wire MISO;

reg [9:0] Input;
reg [7:0] Data_out, Data_expected, Address;

/* Initialization */
top SPI_Slave_RAM(
	.clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .MISO(MISO),
    .SS_n(SS_n)
    );

initial begin
	clk = 0;
	forever
	#1 clk = ~clk;
end

integer i=0;

initial begin
	MOSI = 0;
	SS_n = 1;
    Input = 0;
    Data_out = 0;
    Data_expected = 0;
    Address = 0;

	// Test Case 1: Reset Output
	rst_n = 0;
	repeat (4) @(negedge clk);

	if (MISO != 0) begin
		$display("Error in reset operation!");
		$stop;
	end

    repeat (5) @(negedge clk);

	rst_n = 1;
    @(negedge clk);

    repeat (10) begin

		// Test Case 2: Write Address & Data
		SS_n = 0;
	    @(negedge clk);
		
	    Address = $random; // Randomize the address

		Input = {2'b00, Address}; // 00 for write address - 'Address' is the address
		
		MOSI = 0; // write operation

		for (i = 0; i < 10; i = i + 1) begin
			@(negedge clk);
			MOSI = Input[9 - i];
		end

		@(negedge clk); 
		SS_n = 1;

	    @(negedge clk);

		// Write Data
		SS_n = 0;
	    @(negedge clk);

	    Data_expected = $random; // Randomize the data

		Input = {2'b01, Data_expected}; // 01 for write data - 'Data_expected' is the data
		
		MOSI = 0; // write operation

		for (i = 0; i < 10; i = i + 1) begin
			@(negedge clk);
			MOSI = Input[9 - i];
		end

		@(negedge clk); 
		SS_n = 1;

		@(negedge clk);

		// Test Case 3: Read Address & Data
		SS_n = 0;
	    @(negedge clk);

		Input = {2'b10, Address}; // 10 for read address - 'Address' is the address
		
		MOSI = 1; // read operation

		for (i = 0; i < 10; i = i + 1) begin
			@(negedge clk);
			MOSI = Input[9 - i];
		end

		 @(negedge clk); 
		SS_n = 1;

	    @(negedge clk);

		// Read Data
		SS_n = 0;
	    @(negedge clk);

		Input = 10'b11_0000_0110; // 11 for write data - 110 are dummy bits
		
		MOSI = 1; // read operation

		for (i = 0; i < 10; i = i + 1) begin
			@(negedge clk);
			MOSI = Input[9 - i];
		end

		@(negedge clk);
	    
	    for (i = 0; i < 10; i = i + 1) begin
			@(negedge clk);
			Data_out[9 - i] = MISO;
		end

		if (Data_out == Data_expected) begin
			$display("Passed!");
		end else begin
			$display("Error!");
			$stop;
		end

	    SS_n = 1;

	    repeat(2) @(negedge clk);

    end

	$stop;
end
endmodule
