# Verilog_UART
This file consists of the Verilog code for UART.
UART Transmitter and UART Receiver modules build separately and then connected in the UART Top Module.
There is separate testbench written to cross-check the waveform and functionality of UART Transmitter and
UART Receiver separately.
Along with this testbench, this file also includes testbench which checks the functionality of the Top UART module as one.

NOTE: 
	Right now there is a minor code problem in the testbench which checks UART Receiver functionality. 
	When corrected the new testbench will be added to this file.
	Along with the testbench, the Verification code for UART Top module will be added written in SystemVerilog when completed
