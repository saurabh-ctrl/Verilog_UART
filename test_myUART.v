`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////////////////
// This is the Verilog code for tessting functionality of both UART Transmitter and UART Receiver.
// In this UART Transmitter transmits the 8-bit data (8'h 8B).
// We check the Recieved data by the Receiver.
// If both the Data matches the the Test PASSED.
///////////////////////////////////////////////////////////////////////////////////////////////

module test_uart;

	// Transmitter Ports
	reg 		i_Tx_Dv;
	reg  [7:0]	i_Tx_Byte;	
	reg 		i_clk;
	
	// Receiver Ports:
	wire [7:0]	o_Rx_Byte;
	wire		o_Rx_Dv;
	
	
	// Define Parameter : Purpose : To get the clock of 10MHz and the Baud Rate of 115200.
	// So the CLK_CY_PER_BIT = 87 (Approx.)
	parameter IN_CLK_PER 		= 100;		// For input clk of 10MHz (`timescale 1ns/1ps)
	parameter CLK_CY_PER_BIT	= 87;
	parameter BIT_PERIOD		= 8600; 
	
	//Instantiate the DUT :
	
	uart_top #(.CLK_CY_PER_BIT(CLK_CY_PER_BIT)) uut 
	(
		.i_clk(i_clk), 
		.i_Tx_Dv(i_Tx_Dv), 
		.i_Tx_Byte(i_Tx_Byte), 
		.o_Rx_Byte(o_Rx_Byte), 
		.o_Rx_Dv(o_Rx_Dv)
	);
	
	// Clock Build Block:
	initial
	begin
		i_clk	<= 0;
		forever #(IN_CLK_PER/2) i_clk <= ~(i_clk);
	end
	
	initial
	begin
		@(posedge i_clk);
		i_Tx_Dv		<= 1'b1;
		i_Tx_Byte	<= 8'h8B;
		@(posedge i_clk);
		i_Tx_Dv		<= 1'b0;
		@(posedge uut.UART_TX_INST.o_Tx_Done);
		$display("Transmitter has Done transmitting to the Serial Line");
	end
	
	initial
	begin
		@(posedge o_Rx_Dv);
		$display(" Recieved Data : %h",o_Rx_Byte);		
		$finish;
	end
endmodule
