`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:30:51 07/23/2017
// Design Name:   mini
// Module Name:   C:/Projects/hdl/vm1801mini/testbench.v
// Project Name:  vm1801mini
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mini
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench;

	// Inputs
	reg clk;
	reg reset;
//	reg uart_rx; 

	// Outputs
//	wire uart_tx;
//	wire EXTM;
	wire [4:0] Ro;
	wire [4:0] Bo;
	wire [5:0] Go;
	wire HS;
	wire VS;
	wire [2:0] led;

	// Instantiate the Unit Under Test (UUT)
	mini uut (
		.clk(clk), 
		.reset(reset), 
//		.uart_rx(uart_rx), 
//		.uart_tx(uart_tx), 
//		.EXTM(EXTM), 
		.Ro(Ro), 
		.Bo(Bo), 
		.Go(Go), 
		.HS(HS), 
		.VS(VS), 
		.led(led)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
//		uart_rx = 0;

		// Wait 100 ns for global reset to finish
		forever #10 clk = !clk;
        
		// Add stimulus here

	end
      
	initial begin
		// Initialize Inputs
		reset = 1;

		// Wait 100 ns for global reset to finish
		#1000 reset <= 0;
		#1020 reset <= 1;
        
		// Add stimulus here

	end

endmodule

