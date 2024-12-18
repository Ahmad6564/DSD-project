# DSD-project
 The project is fast matrix multiplication on FPGA. Data must be transferred from PC to FPGA via UART or Ethernet cable and result be sent back and stored in a file. 
## UART One-Way Communication
This repository demonstrates the implementation of a UART (Universal Asynchronous Receiver/Transmitter) one-way communication system on FPGA using Verilog. It includes a UART transmitter module [uart_tx.v](#uart-tx.v) and its corresponding testbench  [uart_tx_tb.v](#uart-tx-tb.v)
### Overview
UART is a widely used communication protocol that transmits data serially, one bit at a time. This implementation focuses on the one-way communication aspect of UART, where data is transmitted from the FPGA to an external receiver.
###uart_tx One Way communication
![image](https://github.com/user-attachments/assets/1df4b1d0-1395-465f-889e-8208c6ce1ebc)
 
## UART two-way communication

Implementing a UARt two-way communication system, enabling data transmission and reception between devices.

### Key Features:
* Transmission (TX): Sends 8-bit parallel data as serial data through the UART protocol.
* Reception (RX): Receives serial data and converts it back to 8-bit parallel data.
* Transmission Control: The transmission process is controlled via a tx_start signal, which triggers the start of data transmission.
* Receiver Control: The receiver detects the start bit, reads each data bit serially, and outputs the received byte when ready.
* Busy/Ready Flags: Provides feedback on whether the transmitter is busy (tx_busy) and whether the receiver has successfully received a byte (rx_ready).

#### Components:
* Transmitter Module: Implements the logic to send data bit by bit, starting with a start bit and ending with a stop bit.
* Receiver Module: Captures serial data, stores it in a buffer, and outputs the received data when the transmission is complete.
* Top-Level Module [uart_two_way_comm](#uart_two_way_comm): Combines both the transmitter and receiver modules to enable full two-way communication.

![image](https://github.com/user-attachments/assets/ba8b69ce-c5fa-4afb-9e4b-d1dce3bbf091)


## Serial Matrix Multiplication on FPGA
This project demonstrates the implementation of a serial matrix multiplication algorithm on an FPGA. The design is synthesized for a 3x3 matrix multiplication and is implemented on a Nexys 3 board with a Spartan-6 FPGA. This implementation does not involve UART communication.

### Table of Contents
* Introduction
* Project Structure
* Verilog Modules
* Serial Matrix Multiplication
* Test Bench
* Constraints File
* Simulation and Synthesis

### Introduction
This project aims to implement a serial matrix multiplication algorithm on an FPGA. The matrix multiplication is carried out in a sequential manner, and the result is stored in a third matrix. This project is designed to be run on a Nexys 3 FPGA board using a Spartan-6 FPGA.

#### Project Structure ####
The repository contains the following files:
* [serial_matrix_multiplication.v](#serial_matrix_multiplication.v): Verilog module for serial matrix multiplication.

* [tb_serial_matrix_multiplication.v](#tb_serial_matrix_multiplication.v): Test bench for the serial matrix multiplication module.

* [tb_serial_matrix_multiplication.v](#Nexys3_Constraints.ucf): Constraints file for the Nexys 3 board.


### Verilog Modules
### Serial Matrix Multiplication
The main Verilog module [serial_matrix_multiplication.v](#serial_matrix_multiplication.v) performs 3x3 matrix multiplication in a sequential manner. The design includes an FSM (Finite State Machine) that controls the multiplication process, iterating through each element of the matrices.

### Test Bench
The test bench [tb_serial_matrix_multiplication.v](#tb_serial_matrix_multiplication.v) simulates the serial matrix multiplication module. It initializes two 3x3 matrices, triggers the multiplication process, and verifies the result.

### Usage
* Initialize Inputs: Initialize the matrices A and B.

* Start Multiplication: Trigger the start signal to begin the multiplication process.

* Verify Output: Once the done signal is asserted, verify the output matrix C and also I show the result of matrix multiplication on console.

