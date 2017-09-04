`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:06:16 05/23/2015 
// Design Name: 
// Module Name:    sysgen 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SYNC(
   output clk75,
        output clk50p,
        output clk50n,
        input  CLK
);

wire clk_fb0_nb, clk_fb0_buf; 
wire clk_fb2_nb, clk_fb2_buf;
wire clk75_nb, clk50p_nb, clk50n_nb;
wire clkbuf;

        BUFG BUFG_FBCLK (
      .O(clkbuf), // 1-bit output: Clock buffer output
      .I(CLK)  // 1-bit input: Clock buffer input
   );



//   DCM_SP    : In order to incorporate this function into the design,
   DCM_SP #(
      .CLKDV_DIVIDE(2.0),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(2),                     // 24 6(64MHz) 6(40MHZ) Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(3),                   // 25 8(64MHz) 5(40MHZ) Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(20),             // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("NONE"),          // Output phase shift (NONE, FIXED, VARIABLE)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_CPU (
      .CLK0(clk_fb0_nb),      // 1-bit output: 0 degree clock output 
      .CLKDV(),
                .CLK90(),
                .CLK180(),
      .CLK270(),
                .CLK2X(),
      .CLK2X180(),
                .CLKFX180(),
      .CLKFB(clk_fb0_buf),  // 1-bit input: Clock feedback input
      .CLKFX(clk75_nb),     // 1-bit output: Digital Frequency Synthesizer output (DFS)         
      .LOCKED(),
                .PSDONE(),
      .STATUS(),
      .CLKIN(clkbuf),  // 1-bit input: Clock input
                .PSCLK(),
      .PSINCDEC(),         // 1-bit input: Phase shift increment/decrement input
      .PSEN(1'b0),         // 1-bit input: Phase shift enable           
      .DSSEN(1'b0),        // 1-bit input: Unsupported, specify to GND.
      .RST(1'b0)
   ); 

        BUFG BUFG_SMCLKFB (
      .O(clk_fb0_buf),     // 1-bit output: Clock buffer output
      .I(clk_fb0_nb)       // 1-bit input: Clock buffer input
   );

        BUFG BUFG_SMCLK (
      .O(clk75), // 1-bit output: Clock buffer output
      .I(clk75_nb)  // 1-bit input: Clock buffer input
   );
        
   DCM_SP #(
      .CLKDV_DIVIDE(2.0),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(5),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(4),                   // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(20),             // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("NONE"),          // Output phase shift (NONE, FIXED, VARIABLE)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_VIDEO (
      .CLK0(clk_fb2_nb),      // 1-bit output: 0 degree clock output
      .CLKDV(),
                .CLK90(),
                .CLK180(),
      .CLK270(),
                .CLK2X(),
      .CLK2X180(),
                .CLKFX180(clk50n_nb),
      .CLKFB(clk_fb2_buf),  // 1-bit input: Clock feedback input
      .CLKFX(clk50p_nb),    // 1-bit output: Digital Frequency Synthesizer output (DFS)         
      .LOCKED(),
                .PSDONE(),
      .STATUS(),
      .CLKIN(clkbuf),   // 1-bit input: Clock input
                .PSCLK(),
      .PSINCDEC(),         // 1-bit input: Phase shift increment/decrement input
      .PSEN(1'b0),         // 1-bit input: Phase shift enable           
      .DSSEN(1'b0),        // 1-bit input: Unsupported, specify to GND.
      .RST(1'b0)
   ); 

        BUFG BUFG_CLKCPUN (
      .O(clk50n),     // 1-bit output: Clock buffer output
      .I(clk50n_nb)   // 1-bit input: Clock buffer input
   );

        BUFG BUFG_CLKCPUP (
      .O(clk50p),     // 1-bit output: Clock buffer output
      .I(clk50p_nb)   // 1-bit input: Clock buffer input
   );
        
        BUFG BUFG_CLKCPUFB (
      .O(clk_fb2_buf),     // 1-bit output: Clock buffer output
      .I(clk_fb2_nb)       // 1-bit input: Clock buffer input
   );


   // End of clock_forward_inst instantiation
endmodule
