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

### Constraints File

The [Constraints.ucf](#Constraints.ucf) file specifies the pin assignments for the Nexys 3 board. Ensure that the pins are correctly mapped to the FPGA's I/O pins.

#### Example Pin Assignments
* clk: C9
* reset: A7
* start: B8
* Matrix A Inputs: P11, P12, N12, M12, M13, L14, L13, K14, K13
* Matrix B Inputs: J14, J13, H14, H13, G14, G13, F14, F13, E13
* Matrix C Outputs: E12, D12, C12, B12, A12, C11, B11, A11, A10 
* done: B10
#### Orginal Matrix in testbench is:
![image](https://github.com/user-attachments/assets/ab91c6bd-2a4e-48d3-86c7-2fe09cfabd72)
#### Output of 3x3 matrix  multiplication on EDA playground
  ![image](https://github.com/user-attachments/assets/f9c114be-90aa-44a3-be34-4524f8741b92)



# FPGA Matrix Multiplication with UART Communication

## Overview

This project implements matrix multiplication on an FPGA using UART communication to transfer data between a PC and the FPGA. The project includes Verilog modules for UART transmission and reception, as well as the top module that integrates matrix multiplication logic. A Python script facilitates the transfer of matrices A and B to the FPGA and captures the result matrix C, which is then stored in a file.

## Contents

- **UART Transmitter Module**: Transmits data from the FPGA to the PC via UART.
- **UART Receiver Module**: Receives data from the PC via UART and sends it to the FPGA.
- **Top Module**: Integrates UART communication and matrix multiplication logic.
- **Test Bench**: Verifies the functionality of the top module and displays the result matrix C on the console.
- **Python Script**: Transfers matrices A and B to the FPGA, triggers the computation, and captures the result matrix C.

## Modules

### uart_tx (UART Transmitter)

- **Inputs**:
  - `clk`: Clock signal
  - `reset`: Reset signal
  - `data_in`: Data to be transmitted
  - `tx_start`: Start transmission signal
- **Outputs**:
  - `tx`: UART transmit signal
  - `tx_done`: Transmission done signal

### uart_rx (UART Receiver)

- **Inputs**:
  - `clk`: Clock signal
  - `reset`: Reset signal
  - `rx`: UART receive signal
- **Outputs**:
  - `data_out`: Received data
  - `rx_done`: Reception done signal

### top_module

- **Inputs**:
  - `clk`: Clock signal
  - `reset`: Reset signal
  - `rx`: UART receive signal
- **Outputs**:
  - `tx`: UART transmit signal

The top module integrates UART communication and matrix multiplication logic. It receives matrices A and B via UART, computes the matrix multiplication, and sends the result matrix C back via UART.

## Test Bench

The test bench verifies the functionality of the top module by performing the following steps:

1. Initializes the clock, reset, and UART signals.
2. Sends matrix A to the FPGA via UART.
3. Sends matrix B to the FPGA via UART.
4. Waits for computation and result transmission.
5. Captures the result matrix C from the UART output.
6. Displays the result matrix C on the console.
7. Generates a VCD file for waveform viewing.

### Displaying Results

The result matrix C is displayed on the console using the following code:

```verilog
$display("Matrix C:");
$display("%d %d %d %d", result_matrix_c[0][0], result_matrix_c[0][1], result_matrix_c[0][2], result_matrix_c[0][3]);
$display("%d %d %d %d", result_matrix_c[1][0], result_matrix_c[1][1], result_matrix_c[1][2], result_matrix_c[1][3]);
$display("%d %d %d %d", result_matrix_c[2][0], result_matrix_c[2][1], result_matrix_c[2][2], result_matrix_c[2][3]);
$display("%d %d %d %d", result_matrix_c[3][0], result_matrix_c[3][1], result_matrix_c[3][2], result_matrix_c[3][3]);




