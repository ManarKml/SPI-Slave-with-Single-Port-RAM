# SPI-Slave-with-Single-Port-RAM
This project implements a complete SPI slave interface connected to a single-port asynchronous RAM in Verilog. The system allows writing data to RAM and reading it back via SPI commands.

•  SPI Slave Module: Handles serial to parallel MOSI and parallel to serial MISO data transfers, supports 10-bit command frames with address and data fields.
•  Asynchronous RAM: Stores and retrieves 8-bit data using address commands from the SPI slave.
•  Top-Level Integration: Connects the SPI slave to RAM for memory read/write operations.
•  Testbench: Simulates SPI transactions for write, read, and reset scenarios, with both fixed and randomized inputs.

<img width="892" height="494" alt="Blank diagram" src="https://github.com/user-attachments/assets/320de3f6-cbda-46a2-b1da-ef1760feab27" />
