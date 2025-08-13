module top (
    input clk, rst_n, MOSI, SS_n,
    output MISO
    );

// SPI receive interface
wire [9:0] rx_data; 
wire rx_valid;

// SPI transmit interface
wire [7:0] tx_data; 
wire tx_valid;

slave dut (
    .MOSI(MOSI), 
    .SS_n(SS_n), 
    .clk(clk), 
    .rst_n(rst_n), 
    .tx_valid(tx_valid), 
    .tx_data(tx_data), 
    .MISO(MISO), 
    .rx_valid(rx_valid), 
    .rx_data(rx_data)
    );
                
async_ram_sp my_ram (
    .din(rx_data),
    .dout(tx_data),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid),
    .clk(clk),
    .rst_n(rst_n)
    );

endmodule