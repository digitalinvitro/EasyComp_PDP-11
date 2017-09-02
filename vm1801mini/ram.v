`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:28:33 07/24/2017 
// Design Name: 
// Module Name:    ram 
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
module RAM(
  input [15:0]di,
  input [15:0]addr,
  input we, clk,
  input [1:0]sel,
  output[15:0]Q
);
/*
 10..0 - low bit address (in BRAM) 3FF..0 - 2048 (2K)
 
 BFFF - LAST ADDR - [1011.1][111.1111.1111]
 07FF..0000  - b00 - 2K 
 0FFF..0800  - b01 - 4K
 -----------------------
 17FF..1000  - b02 - 6K
 1FFF..1800  - b03 - 8K
 -----------------------
 27FF..2000  - b04 - 10K
 2FFF..2800  - b05 - 12K
 -----------------------
 37FF..3000  - b06 - 14K
 3FFF..3800  - b07 - 16K
 -----------------------
 47FF..4000  - b08 - 18K
 4FFF..4800  - b09 - 20K
 -----------------------
 57FF..5000  - b10 - 22K
 5FFF..5800  - b11 - 24K
 -----------------------
 67FF..6000  - b12 - 26K
 6FFF..6800  - b13 - 28K
 -----------------------
 77FF..7000  - b14 - 30K
 7FFF..7800  - b15 - 32K
 -----------------------
 87FF..8000  - b16 - 34K
 8FFF..8800  - b17 - 36K
 -----------------------
 97FF..9000  - b18 - 38K
 9FFF..9800  - b19 - 40K
 -----------------------
 A7FF..A000  - b20 - 42K
 AFFF..A800  - b21 - 44K
 -----------------------
 B7FF..B000  - b22 - 46K
*/

wire [4:0]CS = addr[15:11];
wire [15:0]data[22:0];
wire [22:0]wr = {21'd0, we} << CS;

assign Q = data[CS];

RAM16 RAM_00(.data_a(di),.addr_a(addr[10:1]),.q_a(data[0]),.we_a(wr[0]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16_1 RAM_01(.data_a(di),.addr_a(addr[10:1]),.q_a(data[1]),.we_a(wr[1]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_02(.data_a(di),.addr_a(addr[10:1]),.q_a(data[2]),.we_a(wr[2]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_03(.data_a(di),.addr_a(addr[10:1]),.q_a(data[3]),.we_a(wr[3]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_04(.data_a(di),.addr_a(addr[10:1]),.q_a(data[4]),.we_a(wr[4]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_05(.data_a(di),.addr_a(addr[10:1]),.q_a(data[5]),.we_a(wr[5]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_06(.data_a(di),.addr_a(addr[10:1]),.q_a(data[6]),.we_a(wr[6]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_07(.data_a(di),.addr_a(addr[10:1]),.q_a(data[7]),.we_a(wr[7]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_08(.data_a(di),.addr_a(addr[10:1]),.q_a(data[8]),.we_a(wr[8]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_09(.data_a(di),.addr_a(addr[10:1]),.q_a(data[9]),.we_a(wr[9]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_10(.data_a(di),.addr_a(addr[10:1]),.q_a(data[10]),.we_a(wr[10]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_11(.data_a(di),.addr_a(addr[10:1]),.q_a(data[11]),.we_a(wr[11]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_12(.data_a(di),.addr_a(addr[10:1]),.q_a(data[12]),.we_a(wr[12]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_13(.data_a(di),.addr_a(addr[10:1]),.q_a(data[13]),.we_a(wr[13]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_14(.data_a(di),.addr_a(addr[10:1]),.q_a(data[14]),.we_a(wr[14]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_15(.data_a(di),.addr_a(addr[10:1]),.q_a(data[15]),.we_a(wr[15]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_16(.data_a(di),.addr_a(addr[10:1]),.q_a(data[16]),.we_a(wr[16]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_17(.data_a(di),.addr_a(addr[10:1]),.q_a(data[17]),.we_a(wr[17]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_18(.data_a(di),.addr_a(addr[10:1]),.q_a(data[18]),.we_a(wr[18]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_19(.data_a(di),.addr_a(addr[10:1]),.q_a(data[19]),.we_a(wr[19]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_20(.data_a(di),.addr_a(addr[10:1]),.q_a(data[20]),.we_a(wr[20]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_21(.data_a(di),.addr_a(addr[10:1]),.q_a(data[21]),.we_a(wr[21]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));
RAM16 RAM_22(.data_a(di),.addr_a(addr[10:1]),.q_a(data[22]),.we_a(wr[22]),.sel_a(sel),.data_b(16'hFFFF),.addr_b(10'h3FF),.we_b(1'b0),.clk(clk));

endmodule


module RAM16(
        input [15:0] data_a, data_b,
        input [9:0] addr_a, addr_b,
        input we_a, we_b, clk,
		  input [1:0] sel_a,
        output[15:0] q_a, q_b
);

wire [1:0] WEA = we_a? sel_a : 2'b00;

// RAMB16BWER  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (RAMB16BWER_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // RAMB16BWER: 16k-bit Data and 2k-bit Parity Configurable Synchronous Dual Port Block RAM with Optional Output Registers
   //             Spartan-6
   // Xilinx HDL Language Template, version 14.2

   RAMB16BWER #(
      // DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      .DATA_WIDTH_A(18),
      .DATA_WIDTH_B(18),
      // DOA_REG/DOB_REG: Optional output register (0 or 1)
      .DOA_REG(0),
      .DOB_REG(0),
      // EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
      .EN_RSTRAM_A("TRUE"),
      .EN_RSTRAM_B("TRUE"),
      // INITP_00 to INITP_07: Initial memory contents.
      .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // INIT_00 to INIT_3F: Initial memory contents.
.INIT_00(256'h0356_FF70_0286_0054_0286_01EE_01E0_0428_0286_1547_000E_15C5_049E_15C4_0484_15C6),
.INIT_01(256'h036E_028E_BFFF_0286_FF70_0286_0356_039C_0396_01EE_01E0_043A_0286_0212_01D4_0386),
.INIT_02(256'h033C_0318_0008_0286_0294_03A2_0294_02BE_FF00_0286_036E_028E_003C_033C_02BE_028E),
.INIT_03(256'h028E_036E_039C_003C_0328_0356_039C_0362_028E_0020_0286_0300_036E_039C_02A6_007A),
.INIT_04(256'h036E_0390_0356_0390_0396_02AC_003C_033C_0318_000D_0286_0356_039C_02F4_0362_028E),
.INIT_05(256'h034C_0318_028A_0374_028E_0374_028E_029C_02F4_029C_0300_02AC_00B2_0328_0300_0380),
.INIT_06(256'h0286_0294_011E_033C_02B2_0318_0020_0286_029C_0318_000D_0286_0294_0112_034C_00A8),
.INIT_07(256'h0390_027A_0356_0390_01B0_029C_0020_0286_029C_036E_02BA_0002_0286_02BA_02BE_FFFE),
.INIT_08(256'h0298_0114_034C_0374_0294_0300_02A6_009C_0328_0020_034C_0318_000D_0286_0374_036E),
.INIT_09(256'h02A6_00B2_034C_036E_0294_029C_036E_0390_02BA_0003_0286_02BA_02BE_FFFE_0286_0294),
.INIT_0A(256'h0172_0334_02BA_003A_0286_0294_01AC_0334_0294_02BA_0030_0286_0374_028E_0000_0286),
.INIT_0B(256'h028E_029C_02F4_029C_02B2_02E6_029C_01AC_032C_02BA_0010_0286_0294_02B6_00EF_0286),
.INIT_0C(256'h0020_0286_029C_02A6_0148_033C_02B2_0318_000D_0286_028E_0318_0020_0286_0294_0374),
.INIT_0D(256'h02F4_01C4_033C_0318_0374_028A_00CA_0977_01AC_0328_00FE_0328_0356_0390_01B0_029C),
.INIT_0E(256'h0282_03A2_000D_0286_00A6_0977_0282_03A2_0020_0286_00B2_0977_0282_0298_01B4_0328),
.INIT_0F(256'h0294_02F4_0300_029C_0300_02B6_028E_008C_0977_0282_0374_029C_02F4_0294_009A_0977),
.INIT_10(256'h0FFF_0286_028E_0004_0286_0068_0977_0282_02AC_01FC_033C_0318_028E_028E_03A2_0374),
.INIT_11(256'h02AC_021A_033C_0306_0294_029C_02E6_029C_0300_03A2_0374_02B6_0418_0286_02C2_02BE),
.INIT_12(256'h01C8_0212_0294_01D4_0264_034C_02BE_FFF0_0286_0294_029C_02B6_028E_0038_0977_0282),
.INIT_13(256'h15A4_1587_1164_0282_02AC_024C_033C_0318_028A_02FA_01C8_0212_036E_0294_01C8_01C8),
.INIT_14(256'h13A6_1580_1547_158E_1547_13A6_1547_0002_1DA6_0002_1DA6_1547_1566_1547_1505_1547),
.INIT_15(256'h458E_1547_E58E_1547_658E_1547_558E_1547_0004_65C6_1547_0002_65C6_1547_0002_1036),
.INIT_16(256'h0C80_0C80_0C80_1380_1547_100E_0B40_6000_0B40_6000_0B40_6000_0B40_6000_1380_1547),
.INIT_17(256'h1547_0002_65CE_1547_0001_65CE_1547_100E_6000_6000_6000_6000_1380_1547_100E_0C80),
.INIT_18(256'h0000_15CE_0303_258E_1547_FFFF_15CE_1547_0000_15CE_030B_0000_25CE_1547_0001_E5CE),
.INIT_19(256'h0000_25D6_1547_1545_8007_1580_1547_1545_810B_1580_1547_1545_1547_FFFF_15CE_1547),
.INIT_1A(256'h0004_65C6_0000_0002_1DBE_1547_1545_03FA_0000_25D6_1547_0002_65C5_1547_1545_0202),
.INIT_1B(256'h1547_100E_FF00_45C0_0000_9F80_1547_0000_1F8E_1547_0004_65C6_0000_0002_9DBE_1547),
.INIT_1C(256'h0456_15E6_1547_049E_15E6_1547_0454_15E6_1547_1026_E180_0484_15C0_1547_0418_15E6),
.INIT_1D(256'h0206_0008_25C0_031E_000D_25C0_1580_0200_0000_95F2_00AC_0001_65F7_00B2_1DC2_1547),
.INIT_1E(256'h0008_65C1_1001_0800_65C0_6000_6000_6000_0020_E5C0_0020_15C0_0090_10B7_0001_E5C2),
.INIT_1F(256'h10B7_01FF_45C2_0200_65C2_1547_0200_00FF_95F0_006A_1DC0_02FB_2040_0040_65C2_940A),
.INIT_20(256'h3736_3534_3332_3130_6475_6D70_0000_0242_2E68_6578_0000_0212_0000_FFE4_0077_0056),
.INIT_21(256'h0D07_3E46_3A04_0D35_3030_2E30_2045_524F_4320_3131_2F34_4611_4645_4443_4241_3938),
.INIT_22(256'h0000_0000_0000_B800_049E_049E_0D21_6675_2005_2120_646E_6966_0D07_2120_6470_6F74),
.INIT_23(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
.INIT_24(256'h3130_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
.INIT_25(256'h3332_3130_3938_3736_3534_3332_3130_3938_3736_3534_3332_3130_3938_3736_3534_3332),
.INIT_26(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_3938_3736_3534),
//      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // INIT_A/INIT_B: Initial values on output port
      .INIT_A(36'h000000000),
      .INIT_B(36'h000000000),
      // INIT_FILE: Optional file used to specify initial RAM contents
      .INIT_FILE("NONE"),
      // RSTTYPE: "SYNC" or "ASYNC" 
      .RSTTYPE("SYNC"),
      // RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
      .RST_PRIORITY_A("CE"),
      .RST_PRIORITY_B("CE"),
      // SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
      .SIM_COLLISION_CHECK("ALL"),
      // SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
      .SIM_DEVICE("SPARTAN6"),
      // SRVAL_A/SRVAL_B: Set/Reset value for RAM output
      .SRVAL_A(36'h000000000),
      .SRVAL_B(36'h000000000),
      // WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_A("WRITE_FIRST"),
      .WRITE_MODE_B("WRITE_FIRST") 
   )
   RAMB16BWER_inst (
      // Port A Data: 32-bit (each) output: Port A data
      .DOA(q_a),       // 32-bit output: A port data output
      .DOPA(),         // 4-bit output: A port parity output
      // Port B Data: 32-bit (each) output: Port B data
      .DOB(q_b),       // 32-bit output: B port data output
      .DOPB(),         // 4-bit output: B port parity output
      // Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
      .ADDRA({addr_a,4'd0}),  // 14-bit input: A port address input
      .CLKA(clk),      // 1-bit input: A port clock input
      .ENA(1'b1),      // 1-bit input: A port enable input
      .REGCEA(1'b0),   // 1-bit input: A port register clock enable input
      .RSTA(1'b0),     // 1-bit input: A port register set/reset input
      .WEA({2'b00,WEA}), // 4-bit input: Port A byte-wide write enable input
      // Port A Data: 32-bit (each) input: Port A data
      .DIA({16'hFFFF,data_a}),    // 32-bit input: A port data input
      .DIPA(4'hF),     // 4-bit input: A port parity input
      // Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      .ADDRB({addr_b,4'd0}),  // 14-bit input: B port address input
      .CLKB(clk),      // 1-bit input: B port clock input
      .ENB(1'b1),      // 1-bit input: B port enable input
      .REGCEB(1'b0),   // 1-bit input: B port register clock enable input
      .RSTB(1'b0),     // 1-bit input: B port register set/reset input
      .WEB({4{we_b}}), // 4-bit input: Port B byte-wide write enable input
      // Port B Data: 32-bit (each) input: Port B data
      .DIB({16'hFFFF,data_b}),    // 32-bit input: B port data input
      .DIPB(4'hF)      // 4-bit input: B port parity input
   );

   // End of RAMB16BWER_inst instantiation
endmodule                               

module RAM16_1(
        input [15:0] data_a, data_b,
        input [9:0] addr_a, addr_b,
        input we_a, we_b, clk,
		  input [1:0] sel_a,
        output[15:0] q_a, q_b
);

wire [1:0] WEA = we_a? sel_a : 2'b00;

// RAMB16BWER  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (RAMB16BWER_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // RAMB16BWER: 16k-bit Data and 2k-bit Parity Configurable Synchronous Dual Port Block RAM with Optional Output Registers
   //             Spartan-6
   // Xilinx HDL Language Template, version 14.2

   RAMB16BWER #(
      // DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      .DATA_WIDTH_A(18),
      .DATA_WIDTH_B(18),
      // DOA_REG/DOB_REG: Optional output register (0 or 1)
      .DOA_REG(0),
      .DOB_REG(0),
      // EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
      .EN_RSTRAM_A("TRUE"),
      .EN_RSTRAM_B("TRUE"),
      // INITP_00 to INITP_07: Initial memory contents.
      .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // INIT_00 to INIT_3F: Initial memory contents.

.INIT_00(256'h00_6C_6C_FE_6C_FE_6C_6C_00_00_00_00_00_6C_6C_6C_00_30_00_30_30_78_78_30_00_00_00_00_00_00_00_00),
.INIT_01(256'h00_00_00_00_00_C0_60_60_00_76_CC_DC_76_38_6C_38_00_C6_66_30_18_CC_C6_00_00_30_F8_0C_78_C0_7C_30),
.INIT_02(256'h00_00_30_30_FC_30_30_00_00_00_66_3C_FF_3C_66_00_00_60_30_18_18_18_30_60_00_18_30_60_60_60_30_18),
.INIT_03(256'h00_80_C0_60_30_18_0C_06_00_30_30_00_00_00_00_00_00_00_00_00_FC_00_00_00_60_30_30_00_00_00_00_00),
.INIT_04(256'h00_78_CC_0C_38_0C_CC_78_00_FC_CC_60_38_0C_CC_78_00_FC_30_30_30_30_70_30_00_7C_E6_F6_DE_CE_C6_7C),
.INIT_05(256'h00_30_30_30_18_0C_CC_FC_00_78_CC_CC_F8_C0_60_38_00_78_CC_0C_0C_F8_C0_FC_00_1E_0C_FE_CC_6C_3C_1C),
.INIT_06(256'h60_30_30_00_00_30_30_00_00_30_30_00_00_30_30_00_00_70_18_0C_7C_CC_CC_78_00_78_CC_CC_78_CC_CC_78),
.INIT_07(256'h00_30_00_30_18_0C_CC_78_00_60_30_18_0C_18_30_60_00_00_FC_00_00_FC_00_00_00_18_30_60_C0_60_30_18),
.INIT_08(256'h00_3C_66_C0_C0_C0_66_3C_00_FC_66_66_7C_66_66_FC_00_CC_CC_FC_CC_CC_78_30_00_78_C0_DE_DE_DE_C6_7C),
.INIT_09(256'h00_3E_66_CE_C0_C0_66_3C_00_F0_60_68_78_68_62_FE_00_FE_62_68_78_68_62_FE_00_F8_6C_66_66_66_6C_F8),
.INIT_0A(256'h00_E6_66_6C_78_6C_66_E6_00_78_CC_CC_0C_0C_0C_1E_00_78_30_30_30_30_30_78_00_CC_CC_CC_FC_CC_CC_CC),
.INIT_0B(256'h00_38_6C_C6_C6_C6_6C_38_00_C6_C6_CE_DE_F6_E6_C6_00_C6_C6_D6_FE_FE_EE_C6_00_FE_66_62_60_60_60_F0),
.INIT_0C(256'h00_78_CC_1C_70_E0_CC_78_00_E6_66_6C_7C_66_66_FC_00_1C_78_DC_CC_CC_CC_78_00_F0_60_60_7C_66_66_FC),
.INIT_0D(256'h00_C6_EE_FE_D6_C6_C6_C6_00_30_78_CC_CC_CC_CC_CC_00_FC_CC_CC_CC_CC_CC_CC_00_78_30_30_30_30_B4_FC),
.INIT_0E(256'h00_78_60_60_60_60_60_78_00_FE_66_32_18_8C_C6_FE_00_78_30_30_78_CC_CC_CC_00_C6_6C_38_38_6C_C6_C6),
.INIT_0F(256'hFF_00_00_00_00_00_00_00_00_00_00_00_C6_6C_38_10_00_78_18_18_18_18_18_78_00_02_06_0C_18_30_60_C0),
.INIT_10(256'h00_78_CC_C0_CC_78_00_00_00_DC_66_66_7C_60_60_E0_00_76_CC_7C_0C_78_00_00_00_00_00_00_00_18_30_30),
.INIT_11(256'hF8_0C_7C_CC_CC_76_00_00_00_F0_60_60_F0_60_6C_38_00_78_C0_FC_CC_78_00_00_00_76_CC_CC_7C_0C_0C_1C),
.INIT_12(256'h00_E6_6C_78_6C_66_60_E0_78_CC_CC_0C_0C_0C_00_0C_00_78_30_30_30_70_00_30_00_E6_66_66_76_6C_60_E0),
.INIT_13(256'h00_78_CC_CC_CC_78_00_00_00_CC_CC_CC_CC_F8_00_00_00_C6_D6_FE_FE_CC_00_00_00_78_30_30_30_30_30_70),
.INIT_14(256'h00_F8_0C_78_C0_7C_00_00_00_F0_60_66_76_DC_00_00_1E_0C_7C_CC_CC_76_00_00_F0_60_7C_66_66_DC_00_00),
.INIT_15(256'h00_6C_FE_FE_D6_C6_00_00_00_30_78_CC_CC_CC_00_00_00_76_CC_CC_CC_CC_00_00_00_18_34_30_30_7C_30_10),
.INIT_16(256'h00_1C_30_30_E0_30_30_1C_00_FC_64_30_98_FC_00_00_F8_0C_7C_CC_CC_CC_00_00_00_C6_6C_38_6C_C6_00_00),
.INIT_17(256'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_DC_76_00_E0_30_30_1C_30_30_E0_00_18_18_18_00_18_18_18),
.INIT_18(256'h00_60_60_60_7E_10_00_00_30_30_60_00_00_00_00_00_00_60_60_60_60_60_7E_10_00_36_33_36_3C_30_FC_FC),
.INIT_19(256'h00_18_FE_18_18_FE_18_00_00_18_18_18_18_FE_18_00_00_DB_DB_00_00_00_00_00_66_66_CC_00_00_00_00_00),
.INIT_1A(256'h00_30_60_C0_C0_60_30_00_00_DE_DB_DB_DE_D8_78_38_00_CA_6A_30_18_8C_86_00_00_3C_62_F8_C0_F8_62_3C),
.INIT_1B(256'h00_38_38_FE_C6_C6_C6_C6_00_36_36_36_3C_30_FC_FC_00_C6_CC_F8_F8_CC_D6_18_00_DE_D9_D9_FE_D8_D8_D8),
.INIT_1C(256'h00_00_00_00_00_66_CC_CC_00_00_00_00_00_60_60_C0_00_00_00_00_00_60_C0_C0_0C_66_66_7E_7C_60_F8_60),
.INIT_1D(256'h00_00_FF_FF_00_00_00_00_00_00_FE_FE_00_00_00_00_00_00_18_3C_3C_18_00_00_00_00_00_00_00_66_66_CC),
.INIT_1E(256'h00_C0_60_30_30_60_C0_00_00_DE_D9_DE_78_38_00_00_00_00_00_00_51_55_5B_F1_00_00_00_00_00_00_00_00),
.INIT_1F(256'h00_38_38_FE_C6_C6_00_00_00_36_36_3C_30_FC_00_00_00_CC_D8_F0_D8_CC_10_18_00_DE_D9_FE_D8_D8_00_00),
.INIT_20(256'h00_78_CC_CC_0C_0C_0C_1E_F8_0C_7C_CC_CC_CC_10_00_00_3E_63_03_3F_63_63_6B_00_00_00_00_00_00_00_00),
.INIT_21(256'h00_30_08_30_48_30_40_30_00_18_18_00_00_18_18_00_00_60_60_60_60_7E_7E_06_00_5A_3C_66_66_3C_5A_00),
.INIT_22(256'h00_33_66_CC_CC_66_33_00_00_3C_62_C0_F8_C0_62_3C_00_7C_82_9A_A2_9A_82_7C_00_7E_60_7C_60_7E_00_66),
.INIT_23(256'h00_18_18_18_18_18_00_66_00_7C_82_AA_B2_AA_92_7C_00_00_F8_F8_00_00_00_00_00_02_FE_FE_00_00_00_00),
.INIT_24(256'h00_18_18_18_18_18_00_18_00_3C_18_18_18_18_18_3C_00_7E_00_18_7E_18_00_00_00_00_00_10_28_28_10_00),
.INIT_25(256'h00_00_00_18_18_00_00_00_00_28_28_28_68_E8_E8_7C_C0_C0_C6_CC_FC_CC_84_00_00_60_60_60_7E_06_00_00),
.INIT_26(256'h00_CC_66_33_33_66_CC_00_00_3E_60_7C_60_3E_00_00_00_8B_88_9B_B8_EA_CD_8A_00_78_C0_FC_CC_78_00_6C),
.INIT_27(256'h00_18_18_18_18_00_66_00_00_F8_0C_78_C0_7C_00_00_00_78_CC_1C_70_E0_CC_78_78_CC_CC_0C_0C_0C_00_0C),
.INIT_28(256'h00_60_60_60_60_60_60_7E_00_7C_66_66_7C_66_66_7C_00_7C_66_66_7C_60_60_7C_00_66_66_7E_66_66_36_1E),
.INIT_29(256'h00_3C_66_06_1C_06_66_3C_00_DB_DB_7E_3C_7E_DB_DB_00_7E_60_60_7C_60_60_7E_C6_FE_6C_6C_6C_6C_6C_38),
.INIT_2A(256'h00_66_66_66_66_66_36_1E_00_66_6C_78_70_78_6C_66_00_66_66_76_7E_6E_66_3C_00_66_66_76_7E_6E_66_66),
.INIT_2B(256'h00_66_66_66_66_66_66_7E_00_3C_66_66_66_66_66_3C_00_66_66_66_7E_66_66_66_00_C6_C6_D6_FE_FE_EE_C6),
.INIT_2C(256'h00_3C_66_06_3E_66_66_66_00_18_18_18_18_18_18_7E_00_3C_66_60_60_60_66_3C_00_60_60_7C_66_66_66_7C),
.INIT_2D(256'h00_06_06_06_3E_66_66_66_03_7F_66_66_66_66_66_66_00_66_66_3C_18_3C_66_66_00_18_18_7E_DB_DB_DB_7E),
.INIT_2E(256'h00_F6_DE_DE_F6_C6_C6_C6_00_7C_66_66_7C_60_60_E0_03_FF_DB_DB_DB_DB_DB_DB_00_FF_DB_DB_DB_DB_DB_DB),
.INIT_2F(256'h00_66_36_3E_66_66_66_3E_00_CE_DB_DB_FB_DB_DB_CE_00_78_8C_06_3E_06_8C_78_00_7C_66_66_7C_60_60_60),
.INIT_30(256'h00_60_60_60_60_7E_00_00_00_7C_66_7C_66_7C_00_00_00_3C_66_66_3C_60_3C_00_00_76_CC_7C_0C_78_00_00),
.INIT_31(256'h00_3C_66_0C_66_3C_00_00_00_DB_7E_3C_7E_DB_00_00_00_3C_60_7E_66_3C_00_00_C6_FE_6C_6C_6C_3C_00_00),
.INIT_32(256'h00_66_66_66_36_1E_00_00_00_66_6C_78_6C_66_00_00_00_66_76_7E_6E_66_18_00_00_66_76_7E_6E_66_00_00),
.INIT_33(256'h00_66_66_66_66_7E_00_00_00_3C_66_66_66_3C_00_00_00_66_66_7E_66_66_00_00_00_C6_D6_FE_FE_C6_00_00),
.INIT_34(256'h00_3C_06_3E_66_66_00_00_00_18_18_18_18_7E_00_00_00_3C_66_60_66_3C_00_00_00_60_7C_66_66_7C_00_00),
.INIT_35(256'h00_06_06_3E_66_66_00_00_03_7F_66_66_66_66_00_00_00_66_3C_18_3C_66_00_00_00_18_7E_DB_DB_7E_00_00),
.INIT_36(256'h00_F6_DE_F6_C6_C6_00_00_00_7C_66_7C_60_E0_00_00_03_FF_DB_DB_DB_DB_00_00_00_FF_DB_DB_DB_DB_00_00),
.INIT_37(256'h00_66_36_3E_66_3E_00_00_00_CE_DB_FB_DB_CE_00_00_00_7C_06_3E_06_7C_00_00_00_7C_66_7C_60_60_00_00),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // INIT_A/INIT_B: Initial values on output port
      .INIT_A(36'h000000000),
      .INIT_B(36'h000000000),
      // INIT_FILE: Optional file used to specify initial RAM contents
      .INIT_FILE("NONE"),
      // RSTTYPE: "SYNC" or "ASYNC" 
      .RSTTYPE("SYNC"),
      // RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
      .RST_PRIORITY_A("CE"),
      .RST_PRIORITY_B("CE"),
      // SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
      .SIM_COLLISION_CHECK("ALL"),
      // SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
      .SIM_DEVICE("SPARTAN6"),
      // SRVAL_A/SRVAL_B: Set/Reset value for RAM output
      .SRVAL_A(36'h000000000),
      .SRVAL_B(36'h000000000),
      // WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_A("WRITE_FIRST"),
      .WRITE_MODE_B("WRITE_FIRST") 
   )
   RAMB16BWER_inst (
      // Port A Data: 32-bit (each) output: Port A data
      .DOA(q_a),       // 32-bit output: A port data output
      .DOPA(),         // 4-bit output: A port parity output
      // Port B Data: 32-bit (each) output: Port B data
      .DOB(q_b),       // 32-bit output: B port data output
      .DOPB(),         // 4-bit output: B port parity output
      // Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
      .ADDRA({addr_a,4'd0}),  // 14-bit input: A port address input
      .CLKA(clk),      // 1-bit input: A port clock input
      .ENA(1'b1),      // 1-bit input: A port enable input
      .REGCEA(1'b0),   // 1-bit input: A port register clock enable input
      .RSTA(1'b0),     // 1-bit input: A port register set/reset input
      .WEA({2'b00,WEA}), // 4-bit input: Port A byte-wide write enable input
      // Port A Data: 32-bit (each) input: Port A data
      .DIA({16'hFFFF,data_a}),    // 32-bit input: A port data input
      .DIPA(4'hF),     // 4-bit input: A port parity input
      // Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      .ADDRB({addr_b,4'd0}),  // 14-bit input: B port address input
      .CLKB(clk),      // 1-bit input: B port clock input
      .ENB(1'b1),      // 1-bit input: B port enable input
      .REGCEB(1'b0),   // 1-bit input: B port register clock enable input
      .RSTB(1'b0),     // 1-bit input: B port register set/reset input
      .WEB({4{we_b}}), // 4-bit input: Port B byte-wide write enable input
      // Port B Data: 32-bit (each) input: Port B data
      .DIB({16'hFFFF,data_b}),    // 32-bit input: B port data input
      .DIPB(4'hF)      // 4-bit input: B port parity input
   );

   // End of RAMB16BWER_inst instantiation
endmodule                               