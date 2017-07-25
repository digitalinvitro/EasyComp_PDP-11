//
//Copyright (C) 1991-2012 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.
//
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on


module vm1_aram(
	input	[5:0]address_a,
	input	[5:0]address_b,
	input	[1:0]byteena_a,
	input clock,
	input	[15:0]data_a,
	input	[15:0]data_b,
	input wren_a,
	input wren_b,
	output	[15:0]q_a,
	output	[15:0]q_b
);

wire [8:0]addr_a = {3'b000, address_a};
wire [8:0]addr_b = {3'b000, address_b};
wire [1:0]WEA = {2{wren_a}} & byteena_a;
wire [1:0]WEB = {2{wren_b}};
// BRAM_TDP_MACRO : In order to incorporate this function into the design,
//   Verilog   : the forllowing instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (BRAM_TDP_MACRO_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // BRAM_TDP_MACRO: True Dual Port RAM
   //                 Spartan-6
   // Xilinx HDL Language Template, version 14.1
   
   //////////////////////////////////////////////////////////////////////////
   // DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width //
   // ===============|===========|===========|===============|=============//
   //     19-36      |  "18Kb"   |     512   |     9-bit     |    4-bit    //
   //     10-18      |  "18Kb"   |    1024   |    10-bit     |    2-bit    //
   //     10-18      |   "9Kb"   |     512   |     9-bit     |    2-bit    //
   //      5-9       |  "18Kb"   |    2048   |    11-bit     |    1-bit    //
   //      5-9       |   "9Kb"   |    1024   |    10-bit     |    1-bit    //
   //      3-4       |  "18Kb"   |    4096   |    12-bit     |    1-bit    //
   //      3-4       |   "9Kb"   |    2048   |    11-bit     |    1-bit    //
   //        2       |  "18Kb"   |    8192   |    13-bit     |    1-bit    //
   //        2       |   "9Kb"   |    4096   |    12-bit     |    1-bit    //
   //        1       |  "18Kb"   |   16384   |    14-bit     |    1-bit    //
   //        1       |   "9Kb"   |    8192   |    12-bit     |    1-bit    //
   //////////////////////////////////////////////////////////////////////////

   BRAM_TDP_MACRO #(
      .BRAM_SIZE("9Kb"), // Target BRAM: "9Kb" or "18Kb" 
      .DEVICE("SPARTAN6"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(36'h0000000),  // Initial values on port A output port
      .INIT_B(36'h00000000), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (16),   // Valid values are 1-36
      .READ_WIDTH_B (16),   // Valid values are 1-36
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(36'h00000000), // Set/Reset value forr port A output
      .SRVAL_B(36'h00000000), // Set/Reset value forr port B output
      .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(16), // Valid values are 1-36
      .WRITE_WIDTH_B(16), // Valid values are 1-36
      .INIT_00(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
      .INIT_01(256'h0000_0000_0000_001C_E002_0040_0014_00B8_E00A_0018_FFCE_0004_000C_0008_0010_E006),
      .INIT_02(256'h0000_0008_FF00_0000_0010_FFBE_8000_0000_0001_FFFF_FFCE_0000_0002_0000_00E0_0000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
            
      // The next set of INITP_xx are forr the parity bits
      .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) BRAM_TDP_MACRO_inst (
      .DOA(q_a),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(q_b),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(addr_a),  // Input port-A address, width defined by Port A depth
      .ADDRB(addr_b),  // Input port-B address, width defined by Port B depth
      .CLKA(clock),    // 1-bit input port-A clock
      .CLKB(clock),    // 1-bit input port-B clock
      .DIA(data_a),    // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(data_b),    // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(1'b1),      // 1-bit input port-A enable
      .ENB(1'b1),      // 1-bit input port-B enable
      .REGCEA(1'b0),   // 1-bit input port-A output register enable
      .REGCEB(1'b0),   // 1-bit input port-B output register enable
      .RSTA(1'b0),     // 1-bit input port-A reset
      .RSTB(1'b0),     // 1-bit input port-B reset
      .WEA(WEA),       // Input port-A write enable, width defined by Port A depth
      .WEB(WEB)        // Input port-B write enable, width defined by Port B depth
   );

   // End of BRAM_TDP_MACRO_inst instantiation
endmodule

/*
WIDTH=16;
DEPTH=64;

ADDRESS_RADIX=OCT;
DATA_RADIX=OCT;

CONTENT BEGIN
	[000..017]  :   000000;
	0x10 020  :   E006 160006;
	0x11 021  :   0010 000020;
	0x12 022  :   0008 000010;
	0x13 023  :   000C 000014;
	0x14 024  :   0004 000004;
	0x15 025  :   FFCE 177716;
	0x16 026  :   0018 000030;
	0x17 027  :   E00A 160012;
	0x18 030  :   00B8 000270;
	0x19 031  :   0014 000024;
	0x1A 032  :   0040 000100;
	0x1B 033  :   E002 160002;
	0x1C 034  :   001C 000034;
	[035..040]  :   000000;
	0x21 041  :   00E0 000340;
	0x22 042  :   000000;
	0x23 043  :   0002 000002;
	0x24 044  :   000000;
	0x25 045  :   FFCE 177716;
	0x26 046  :   FFFF 177777;
	0x27 047  :   0001 000001;
	0x28 050  :   0000 000000;
	0x29 051  :   8000 100000;
	0x2A 052  :   FFBE 177676;
	0x2B 053  :   0010 000020;
	0x2C 054  :   0000 000000;
	0x2D 055  :   FF00 177400;
	0x2E 056  :   0008 000010;
	[057..077]  :   000000;
END;
*/