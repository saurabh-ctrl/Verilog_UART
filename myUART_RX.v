`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is the UART Receiver Verilog code :
// The Receiver able to receive the 8-bit data frame along with
// one start bit, one parity bit and one stop bit.
// From the Serial line income data to the Receiver, the Receiver able to extract
// the serial 8-bit datat and given output as 8-bit vector.
// When the complete Receving done or when receiver detect the stop bit, Reciever will 
// drive the output o_rx_dv (Receiver Drive Done) as HIGH in order to tell the completion of the operation.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter CLK_CY_PER_BIT = 87)
	(
		input 			i_clk,
		input 			i_Rx_Serial,
		output [7:0] 	o_Rx_Byte,
		output 			o_Rx_Dv
	);
	
	// We are implementing this module using the state machine:
	// Defining states of FSM as localparam:
	localparam STATE_IDLE			= 3'b000;
	localparam STATE_START_GET		= 3'b001;
	localparam STATE_DATA_GET		= 3'b010;
	localparam STATE_PARITY_GET	= 3'b011;
	localparam STATE_STOP_GET		= 3'b100;
	localparam STATE_CLEANUP		= 3'b101;
	
	// Internal variable:
	reg [2:0] 	r_state;		// Keep track of states in the FSM.
	reg [7:0] 	r_clk_count;	// This will be UP-COUNTER to for wait till we count input clk cycle upto clk_cy_per_bit.
	reg [2:0] 	r_bit_idx;		// Keep the track of bit index of input Data Byte From transmitter.
	reg [7:0] 	r_Rx_Byte;
	reg 			r_Rx_Dv;
	
	// The Received Serial line input to the Receiver will be go through buffer:
	// We will extract the input Serial Line to the input at the middle of the say BIT_PERIOD
	// So this buffer register will reduced any occurance of uncertain change in the Data and not go in the METASTABLE State.
	reg r_Rx_Data_R, r_Rx_Data;
	
	// Below will store the incoming data from the Serial Line every "posedge of the i_clk (Input CLK)"
	always @(posedge i_clk)
	begin
		r_Rx_Data_R	<= i_Rx_Serial;
		r_Rx_Data	<= r_Rx_Data_R;
	end
	
	// The FSM functionality Descripation Begins here:
	// We are using always block to do so:
	always @(posedge i_clk)
	begin
		//Define the case for the FSM:
		case (r_state)
			
			// Going through the states:
			
			STATE_IDLE:		//Wait in the IDLE Set till the START bit detected.
			begin
				r_clk_count	<= 0;
				r_bit_idx	<= 0;
				r_Rx_Dv		<= 1'b0;
				
				if(r_Rx_Data == 1'b0)
				begin
					r_state <= STATE_START_GET;
				end
				
				else
					r_state <= STATE_IDLE;
			end	// case : STATE_IDLE
			
			//Check the START Condition in the middle of the bit received from Serial Line:
			STATE_START_GET :
			begin
				if(r_clk_count == (CLK_CY_PER_BIT - 1)/2)
				begin
					if(r_Rx_Data == 1'b0)
					begin
						r_clk_count	<= 0;
						r_state		<= STATE_DATA_GET;
					end
				end
				
				else
				begin
					r_clk_count	<= (r_clk_count + 1);
					r_state 	<=  STATE_START_GET;
				end
			end	// case : STATE_START_GET
			
			// For every bit received from the Serial Line sample the data at the middle of bit period.
			STATE_DATA_GET :
			begin
				if(r_clk_count < CLK_CY_PER_BIT - 1)
				begin
					r_clk_count <= r_clk_count + 1;
					r_state 	<= STATE_DATA_GET;
				end
				
				else
				begin
					r_clk_count <= 0;
					r_Rx_Byte[r_bit_idx] <= r_Rx_Data;
					if(r_bit_idx < 7)
					begin
						r_bit_idx	<= r_bit_idx + 1;
						r_state 	<= STATE_DATA_GET;
					end
					else
					begin
						r_bit_idx	<= 0;
						r_state		<= STATE_PARITY_GET;
					end
				end
			end	// case : STATE_DATA_GET
			
			// After getting the Data frame get the Parity Bit from the Serial Line.
			STATE_PARITY_GET :
			begin
				if(r_clk_count < CLK_CY_PER_BIT - 1)
				begin
					r_clk_count <= r_clk_count + 1;
					r_state 	<= STATE_PARITY_GET;
				end
				
				else
				begin
					r_clk_count <= 0;
					r_state		<= STATE_STOP_GET;
				end
			end	// case : STATE_PARITY_GET
			
			STATE_STOP_GET :
			begin
				if(r_clk_count < CLK_CY_PER_BIT - 1)
				begin
					r_clk_count	<= r_clk_count + 1;
					r_state 	<= STATE_STOP_GET;
				end
				
				else
				begin
					r_Rx_Dv		<= 1'b1;
					r_clk_count	<= 0;
					r_state		<= STATE_CLEANUP;
				end
			end	// case : STATE_STOP_GET
			
			STATE_CLEANUP :
			begin
				r_Rx_Dv		<= 0;
				r_clk_count	<= 0;
				r_bit_idx	<= 0;
				r_state		<= STATE_IDLE;
			end	// case : STATE_CLEANUP
			
			default :
			begin
				r_state	<=	STATE_IDLE;
			end	// case : default
			
		endcase
	end
	
	assign o_Rx_Dv		= r_Rx_Dv;
	assign o_Rx_Byte	= r_Rx_Byte;

endmodule

