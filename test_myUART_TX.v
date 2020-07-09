`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is the Verilog code for test the UART Transmitter WaveForms:
// In this we will take an expected parity bit value and check it with
// the parity bit send by the UART Transmitter, if both values equals 
// then test is passed for now only.
// This testbench sole purpose is the seen the WaveForms transmitted by the UART Transmitter.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

module test_uart_tx;

	// Definig the variables same as port of DUT(UART TX):
	reg		i_clk;
	reg 		i_Tx_Dv;
	reg [7:0]	i_Tx_Byte;
	wire 		o_Tx_Active;
	wire 		o_Tx_Serial;
	wire 		o_Tx_Done;
	
	//Internal variable to save the expected parity output:
	reg 		r_exp_parity;
	
	// Purpose : Define the parameter to get the clk of 10MHz and Baud Rate of 115200:
	// So the CLK_CY_PER_BIT = 87 (Approx.)
	parameter IN_CLK_PER 		= 100;		// For input clk of 10MHz (`timescale 1ns/1ps)
	parameter CLK_CY_PER_BIT	= 87;
	parameter BIT_PERIOD		= 8600;
	
	// Instantiate the DUT ( uart_tx module):
	uart_tx #(.CLK_CY_PER_BIT(CLK_CY_PER_BIT)) UART_TX_INST
	    (.i_clk(i_clk),
	     .i_Tx_Dv(i_Tx_Dv),
	     .i_Tx_Byte(i_Tx_Byte),
	     .o_Tx_Active(o_Tx_Active),
	     .o_Tx_Serial(o_Tx_Serial),
	     .o_Tx_Done(o_Tx_Done)
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
		i_Tx_Dv		<= 0;
		i_Tx_Byte	<= 0;
		@(posedge i_clk);
		
		i_Tx_Dv		<= 1;
		i_Tx_Byte	<= 8'hAA;
		r_exp_parity	<= ^(i_Tx_Byte);
		
		@(posedge i_clk);
		i_Tx_Dv		<= 0;
		@(o_Tx_Done);
		if(r_exp_parity == UART_TX_INST.r_parity_out)
			$display("Parity Check TEST PASSED");
		else
			$display("Parity Check TEST FAILED");
		$finish;
	end
endmodule
	
	
