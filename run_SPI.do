vlib work
vlog ram.v slave.v top.v top_tb.v
vsim -voptargs=+acc work.tb
add wave -position insertpoint  \
sim:/tb/clk \
sim:/tb/rst_n \
sim:/tb/MOSI \
sim:/tb/SS_n \
sim:/tb/MISO \
sim:/tb/SPI_Slave_RAM/rx_data \
sim:/tb/SPI_Slave_RAM/rx_valid \
sim:/tb/SPI_Slave_RAM/tx_data \
sim:/tb/SPI_Slave_RAM/tx_valid 
run -all
#quit -sim

