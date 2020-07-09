/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is the UART Top Module connects both UART Transmitter and Receiver.
// Final testbench is written to this top module
// For the top module following will be the port list:
// 1. Inputs : i_clk, i_Tx_Byte, i_Tx_Dv.
// 2. Output : o_Rx_Byte, o_Rx_Dv
// 3. Internal Connection:
//		i) Wires : o_Tx_Done, o_Tx_Active.
//		ii) Wire : io_Serial ( This the Serial line which is output from the Transmitter and Input to the Receiver.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_top #(parameter CLK_CY_PER_BIT = 87)
	(
		input 			i_clk,
		input 			i_Tx_Dv,
		input [7:0]		i_Tx_Byte,
		output [7:0]	o_Rx_Byte,
		output 			o_Rx_Dv
	);
	
	// Defining the Internal connection:
	wire	o_Tx_Done;
	wire	o_Tx_Active;
	wire	io_Serial;
	
	// Instantiate the UART Transmitter and UART Receiver
	// Do the proper Connection:
	
	// 1. UART Transmitter:
	uart_tx #(.CLK_CY_PER_BIT(CLK_CY_PER_BIT)) UART_TX_INST
    (.i_clk(i_clk),
     .i_Tx_Dv(i_Tx_Dv),
     .i_Tx_Byte(i_Tx_Byte),
     .o_Tx_Active(o_Tx_Active),
     .o_Tx_Serial(io_Serial),
     .o_Tx_Done(o_Tx_Done)
    );
	
	// 2. UART Receiver:
	uart_rx #(.CLK_CY_PER_BIT(CLK_CY_PER_BIT)) UART_RX_INST
	(
		.i_clk(i_clk),
		.i_Rx_Serial(io_Serial),
		.o_Rx_Byte(o_Rx_Byte),
		.o_Rx_Dv(o_Rx_Dv)
	);
	
endmodule