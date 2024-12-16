# DSD-project
 The project is fast matrix multiplication on FPGA. Data must be transferred from PC to FPGA via UART or Ethernet cable and result be sent back and stored in a file. 
## UART One-Way Communication
This repository demonstrates the implementation of a UART (Universal Asynchronous Receiver/Transmitter) one-way communication system on FPGA using Verilog. It includes a UART transmitter module - [uart_tx](#uart-tx) and its corresponding testbench - [uart_tx_tb](#uart-tx-tb)
### Overview
UART is a widely used communication protocol that transmits data serially, one bit at a time. This implementation focuses on the one-way communication aspect of UART, where data is transmitted from the FPGA to an external receiver.
###uart_tx One Way communication
![image](https://github.com/user-attachments/assets/1df4b1d0-1395-465f-889e-8208c6ce1ebc)
 
