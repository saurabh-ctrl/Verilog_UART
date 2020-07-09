`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////////////
// This is the testbench for the checking the UART Receiver indiviually (Functionality Check)
// We will feed the required input signals manually to check wheather the UART Receiver 
// design able to capture the Serial Line input bit successfully
// The sole purpose of the testbench is to see WaveFrom Simulation for the UART Receiver.
///////////////////////////////////////////////////////////////////////////////////////////////

module test_uart_rx;
	
	//Define the variables same as the ports of DUT (UART Receiver)
	reg		i_clk;
	reg		i_Rx_Serial;
	wire		o_Rx_Dv;
	wire [7:0]	o_Rx_Byte;
	
	// To Cross checke wheather the data is received is correct or not:
	reg		r_parity_check;
	reg [7:0]	r_in_Byte;
	reg [10:0] 	r_in_serial;
	reg [3:0]	r_bit_idx;
	reg		r_parity;
	
	// Define Parameter : Purpose : To get the clock of 10MHz and the Baud Rate of 115200.
	// So the CLK_CY_PER_BIT = 87 (Approx.)
	parameter IN_CLK_PER 		= 100;		// For input clk of 10MHz (`timescale 1ns/1ps)
	parameter CLK_CY_PER_BIT	= 87;
	parameter BIT_PERIOD		= 8600; 
	
	// Instantiate the DUT:
	uart_rx #(.CLK_CY_PER_BIT(CLK_CY_PER_BIT)) UART_RX_INST
	(
		.i_clk(i_clk),
		.i_Rx_Serial(i_Rx_Serial),
		.o_Rx_Byte(o_Rx_Byte),
		.o_Rx_Dv(o_Rx_Dv)
		
	);

	// Clock Buliding Block:
	initial 
	begin
		i_clk 		<= 0;
		r_bit_idx	<= 0;
		r_in_Byte	<= 8'h8B;
		forever #(IN_CLK_PER/2)	i_clk <= ~(i_clk);
	end
	
	// In this initial block we manually Send the Serial line bit input to the UART Receiver.
	// 1. Wait for single clock period initially.
	// 2. For two clock period keep the Serial Input Line High.
	// 3. Create a Data Frame With the sequence {START bit, 8-bit DATA(8'h8B), Parity bit, STOP bit }
	// 4. Feed to the Serial Line with the Wait of single bit period.
	initial
	begin
		@(posedge i_clk);
		r_parity	<= ^(r_in_Byte);
		@(negedge i_clk);
		r_in_serial	<= {1'b1,r_parity,r_in_Byte,1'b0};
		repeat(2)
		begin
			i_Rx_Serial <= 1;
			@(posedge i_clk);
		end
		for(r_bit_idx = 0;r_bit_idx <= 10; r_bit_idx = r_bit_idx + 1)
		begin
			i_Rx_Serial	<= r_in_serial[r_bit_idx];
			#(BIT_PERIOD);
		end
		
		r_parity_check <= ^(o_Rx_Byte);
		if(r_in_Byte == o_Rx_Byte)
			$display("Correct Byte Received Test PASSED");
		else
			$display("Correct Byte Received Test FAILED");
		if(r_parity == r_parity_check)
			$display("Parity Check Test PASSED");
		else
			$display("Parity Check Test FAILED");
		if(r_in_Byte == o_Rx_Byte && r_parity == r_parity_check)
			$display("UART Receiver Test PASSED");
		else
			$display("UART Receiver Test FAILED");
	end
	
	initial
	begin
		
		@(posedge o_Rx_Dv);
		$finish;
	end
	
endmodule
