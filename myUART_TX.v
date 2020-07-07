/////////////////////////////////////////////////////////////
// This is the Verilog code for UART Transmitter using the FSM.
// The Transmitter transmitted the start bit, 8-bit data frame, one parity bit and lastly one stop bit.
// The input clk is of the frequency 10MHz.
// This is UART with Baud RAte equal to 112500.
// So the number of input clk cycles perr bit transmitted will be:
//			clk_cy_per_bit 	= (Input clk Frequency)/(Baud Rate)
//							= [10*(10^6)]/115200
//							= 87 (Apporx.)
//			clk_cy_per_bit	= 87.
////////////////////////////////////////////////////////////

module uart_tx #(parameter CLK_CY_PER_BIT = 87)
		(
			input 		i_clk,
			input 		i_Tx_Dv,
			input [7:0] i_Tx_Byte,
			output 		o_Tx_Active,
			output 		o_Tx_Done,
			output reg	o_Tx_Serial
		);
		
		// We are implementing this module using the state machine:
		// Defining states of FSM as localparam:
		localparam STATE_IDLE		= 3'b000;
		localparam STATE_START		= 3'b001;
		localparam STATE_DATA		= 3'b010;
		localparam STATE_PARITY		= 3'b011
		localparam STATE_STOP		= 3'b100;
		localparam STATE_CLEANUP	= 3'b101;
		
		//Defining the internal variables:
		reg [7:0] 	r_Tx_Data;
		reg			r_Tx_Done;
		reg			r_Tx_Active;
		reg	[7:0]	r_clk_count;	// This will be UP-COUNTER to for wait till we count input clk cycle upto clk_cy_per_bit.
		reg	[2:0]	r_state;		// Keep track of states in the FSM.
		reg [2:0]	r_bit_idx;		// Keep the track of bit index of input Data Byte of transmitter.
		reg 		r_parity_out	// Check the parity of the Input Data by the transmitter(Default set to "0")
		
		// The FSM functionality Descripation Begins here:
		// We are using always block to do so:
		always @(posedge i_clk)
		begin
			//Define the case for the FSM:
			case (r_state)
				
				// Going through the states:
				STATE_IDLE:
				begin
					//Set all the internal register varible to default value:
					r_clk_count		<= 0;
					r_bit_idx		<= 0;
					r_Tx_Active		<= 1'b0;
					r_Tx_Data		<= 0;
					r_Tx_Done		<= 1'b0;
					r_parity_out	<= 1'b0;
					
					o_Tx_Serial	<= 1'b1;	//Drive HIGH the TX Serial Output.
					
					// "if Block"	:	To check get (i_Tx_Dv) input High:
					if(i_Tx_Dv == 1)
					begin
						r_Tx_Active		<= 1'b1;
						r_Tx_Data		<= i_Tx_Byte;
						r_state 		<= STATE_START;
						r_parity_out	<= ^(i_Tx_Byte);
					end
					
					else
					begin
						r_state		<= STATE_IDLE;
					end
					
				end	// case : STATE_IDLE
				
				// To start transmittion LOWER the Serial Transmitter line.
				STATE_START:
				begin
					o_Tx_Serial	<= 1'b0;
					
					// Keep the Serial line LOWER till the one bit period:
					if(r_clk_count < CLK_CY_PER_BIT-1)
					begin
						r_clk_count <= (r_clk_count + 1)%87;
						r_state		<= STATE_START;
					end
					
					//After that move to the STATE_DATA state:
					else
					begin
						r_clk_count	<= 0;
						r_state		<= STATE_DATA;
					end
				end	// case :STATE_START
				
				// Send the Input 8-bit Data through Serial line, one bit per bit period:
				STATE_DATA :
				begin
					
					o_Tx_Serial	<= r_Tx_Data[r_bit_idx];
					
					if(r_clk_count < CLK_CY_PER_BIT-1)
					begin
						r_clk_count	<= (r_clk_count + 1)%87;
						r_state		<= STATE_DATA;
					
					end
					
					// Else increment the bit_idx(BIT INDEX) to send next bit in the Data Frame:
					else
					begin
						r_clk_count	<= 0;
						if(r_bit_idx < 8)
						begin
							r_bit_idx	<= (r_bit_idx + 1);
							r_state		<= STATE_DATA;
						end
						
						else	// Move to next " state" with setting default values for "r_bit_idx".
						begin
							r_bit_idx	<= 0;
							r_state		<= STATE_PARITY;
						end
					end
				end	// case : STATE_DATA
				
				//Send the parity of the Input Data to the Serial Line.
				STATE_PARITY :
				begin
					
					o_Tx_Serial	<=	r_parity_out;
					
					//Wait for one BIT PERIOD:
					if(r_clk_count < CLK_CY_PER_BIT-1)
					begin
						r_clk_count	<= (r_clk_count + 1)%87;
						r_state		<= STATE_PARITY; 
					end
					
					//After that move to the next state:
					else
					begin
						r_clk_count	<= 0;
						r_state		<= STATE_STOP;
					end
				end
				
				// Send the STOP bit(HIGH) to Serial line 
				STATE_STOP :
				begin
					o_Tx_Serial	<= 1'b1;
					if(r_clk_count	< CLK_CY_PER_BIT-1)
					begin
						r_clk_count	<= (r_clk_count + 1)%87;
						r_state		<= STATE_STOP;
					end	
					
					//After Send STOP bit : Tx_Done Keep High and Lower the Tx_Active.
					else
					begin
						r_clk_count	<= 0;
						r_state		<= STATE_CLEANUP;
						r_Tx_Done	<= 1'b1;
						r_Tx_Active	<= 1'b0;
					end
				end // case : STATE_STOP
				
				//Stay Here for one Input Clk Period
				STATE_CLEANUP :
				begin
					r_Tx_Done	<= 1'b0;
					r_state		<= STATE_IDLE;
				end	// case : STATE_CLEANUP
				
				default : 
				begin
					r_state		<= STATE_IDLE;
				end	// case : default
			endcase
		end
		
		assign o_Tx_Active	= r_Tx_Active;
		assign o_Tx_Done	= r_Tx_Done;
endmodule