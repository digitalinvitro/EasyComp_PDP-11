`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:19:52 07/23/2017 
// Design Name: 
// Module Name:    mini 
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

`define 	DE0_DCLO_WIDTH_CLK			15
`define	DE0_ACLO_DELAY_CLK			7

module  mini(
 input clk,
 input reset,
 //input uart_rx,
 //output uart_tx, 
 //output EXTM,
 output [4:0]Ro, 
 output [4:0]Bo,
 output [5:0]Go,
 output HS, VS,
 output reg [2:0]led = 3'd0
);
localparam DCLO_COUNTER_WIDTH = 4;
localparam ACLO_COUNTER_WIDTH = 3;

reg [DCLO_COUNTER_WIDTH-1:0] dclo_cnt;
reg [ACLO_COUNTER_WIDTH-1:0] aclo_cnt;
reg [1:0]rreset;
reg aclo_out, dclo_out;


wire vclk, mclkp, mclkn;
SYNC gen(
   .clk75(vclk),
	.clk50p(mclkp),
	.clk50n(mclkn),
	.CLK(clk)
);

wire [15:0]	mx_dat[3:0];					//
wire [15:0]	wb_adr;							//	master address out bus
wire [15:0] wb_out;     					// master data out bus
wire [15:0] wb_mux;							//	master data in bus
wire [1:0]  wb_sel;						   // byte sector
wire [3:1]	vm_irq = 3'b000;							//
wire wb_cyc, wb_stb, wb_acki, wb_ack_cpu, wb_ack_mem;

vm1_wb cpu(
 .vm_clk_p(mclkp),
 .vm_clk_n(mclkn),
 .vm_clk_slow(1'b0),                 // slow clock sim mode
 .vm_clk_ena(1'b1),                  // slow clock strobe
 .vm_clk_tve(1'b1),                  // VE-timer clock enable
 .vm_clk_sp(1'b0),                   // external pin SP clock
 
 .vm_pa(2'b00),
 .vm_init_in(1'b0), 		 		      // peripheral reset
 .vm_dclo(dclo),
 .vm_aclo(aclo),
 
 .wbm_adr_o(wb_adr),						// master wishbone address
 .wbm_dat_o(wb_out),						// master wishbone data output
 .wbm_dat_i(wb_mux),						// master wishbone data input
 .wbm_cyc_o(wb_cyc),						// master wishbone cycle
 .wbm_we_o(wb_we),						// master wishbone direction
 .wbm_sel_o(wb_sel),						// master wishbone byte election
 .wbm_stb_o(wb_stb),						// master wishbone strobe
 .wbm_ack_i(wb_ack_mem|wb_ack_cpu),		// master wishbone acknowledgement
 
 .vm_irq(vm_irq), 				      	// radial interrupt requesst
 .vm_virq(1'b1),			       	// vectored interrupt request
 
 
 .wbs_adr_i(wb_adr[2:0]),				// slave wishbone address
 .wbs_dat_i(wb_out),						// slave wishbone data input
 .wbs_cyc_i(wb_cyc),						// slave wishbone cycle
 .wbs_we_i(wb_we),							// slave wishbone direction
 .wbs_stb_i(mx_stb[0]),					// slave wishbone strobe
 .wbs_ack_o(wb_ack_cpu),					// master wishbone acknowledgement
 .wbs_dat_o(mx_dat[0]),					// slave wishbone data output
 	
 .wbm_gnt_i(1'b1),							// master wishbone granted

 .vm_reg14(16'o000000), 				  // register 177714 data input
 .vm_reg16(16'o000000)	 				  // register 177716 data input
);

// Map mem and IO
wire [3:0]	mx_stb;							
assign mx_stb[0]	= wb_stb & wb_cyc & (wb_adr[15:4] == (16'o177700 >> 4)); // FFCx
assign mx_stb[1]	= wb_stb & wb_cyc & (wb_adr[15:14] == 2'b00);
assign mx_stb[2]	= wb_stb & wb_cyc & (wb_adr[15:3] == (16'o177560 >> 3)); // FF7x
assign mx_stb[3]	= wb_stb & wb_cyc & (wb_adr[15:14] == 2'b11); // C000-FFFF

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
 97FF..9000  - b16 - 38K
 9FFF..9800  - b17 - 40K
 -----------------------
 A7FF..A000  - b18 - 42K
 AFFF..A800  - b19 - 44K
 -----------------------
 B7FF..B000  - b20 - 46K
 BFFF..B800  - b21 - 48K
*/

wire [15:0] ram_data;// = wb_adr[11]? mx_dat[2] : mx_dat[1];

assign wb_mux		= (mx_stb[0] ? mx_dat[0] : 16'd0)
						| (mx_stb[1] ? ram_data  : 16'd0);

assign wb_ack_mem = wb_cyc & wb_stb & (ack[1] | wb_we);
reg [1:0]ack;
always@(posedge mclkp) 
begin
	ack[0] <= wb_cyc & wb_stb;
	ack[1] <= wb_cyc & ack[0];
end

//======================= VIDEO ================
wire [13:0] VADDR;
wire [7:0]  vdata[7:0];
wire [7:0]  video_data = vdata[VADDR[13:11]];
video vga(
        .RGB({Ro, Go, Bo}),
        .HSync(HS),
        .VSync(VS),
        .PIXADDR(VADDR),
        .PIXDATA(video_data),
        .PixClock(vclk)
);

wire [15:0]BUSV[7:0];
wire [7:0]WRV = {4'd0, mx_stb[3] & wb_we} << wb_adr[13:11];
VIDEORAM VRAM0( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[0]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[0]), .q_b(BUSV[0])
);
VIDEORAM VRAM1( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[1]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[1]), .q_b(BUSV[1])
);
VIDEORAM VRAM2( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[2]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[2]), .q_b(BUSV[2])
);
VIDEORAM VRAM3( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[3]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[3]), .q_b(BUSV[3])
);
VIDEORAM VRAM4( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[4]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[4]), .q_b(BUSV[4])
);
VIDEORAM VRAM5( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[5]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[5]), .q_b(BUSV[5])
);
VIDEORAM VRAM6( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[6]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[6]), .q_b(BUSV[6])
);
VIDEORAM VRAM7( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[7]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[7]), .q_b(BUSV[7])
);

RAM RAMALL(.di(wb_out),.addr(wb_adr),.Q(ram_data),.we(mx_stb[1] & wb_we),.sel(wb_sel),.clk(mclkp));

//wire [15:0] bus_do_II [1:0];
//wire [15:0] bus_do;
//wire [15:0] bus_di;
/*
RAM16 RAM_0000(
  .data_a(wb_out), 
  .addr_a(wb_adr[10:1]),
  .q_a(mx_dat[1]),
  .we_a(mx_stb[1] & wb_we & !wb_adr[11]),
  .sel_a(wb_sel),
  .data_b(16'hFFFF),
  .addr_b(10'h3FF),
  .q_b(bus_do_II[0]),
  .we_b(1'b0), 
  .clk(mclkp)
);
RAM16_1 RAM_0800(
  .data_a(wb_out), 
  .addr_a(wb_adr[10:1]),
  .q_a(mx_dat[2]),
  .we_a(mx_stb[1] & wb_we & wb_adr[11]),
  .sel_a(wb_sel),
  .data_b(16'hFFFF),
  .addr_b(10'h3FF),
  .q_b(bus_do_II[1]),
  .we_b(1'b0), 
  .clk(mclkp)
);*/

assign dclo = dclo_out;
assign aclo = aclo_out; 
reg [1:0]RST;
always@(posedge mclkp)
begin
	//
	// Resolve metastability issues
	//
	RST[0] <= !reset;
	RST[1] <= RST[0];
	
	if (RST[1]) // reset up
	begin
		dclo_cnt  	<= 0;
		aclo_cnt  	<= 0;
		aclo_out		<= 1'b1;
		dclo_out		<= 1'b1;
	end
	else
	begin
		//
		// Count the DCLO pulse
		//
		if (dclo_cnt != `DE0_DCLO_WIDTH_CLK)
			dclo_cnt <= dclo_cnt + 1'b1;
		else
			dclo_out <= 1'b0;
			
		//
		// After DCLO completion start count the ACLO pulse
		//
		if (~dclo_out)
			if (aclo_cnt != `DE0_ACLO_DELAY_CLK)
				aclo_cnt <= aclo_cnt + 1'b1;
			else
				aclo_out <= 1'b0;
	end
end

endmodule

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
 97FF..9000  - b16 - 38K
 9FFF..9800  - b17 - 40K
 -----------------------
 A7FF..A000  - b18 - 42K
 AFFF..A800  - b19 - 44K
 -----------------------
 B7FF..B000  - b20 - 46K
 BFFF..B800  - b21 - 48K
*/

wire [4:0]CS = addr[15:11];
wire [15:0]data[21:0];
wire [21:0]wr = {21'd0, we} << CS;

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

endmodule


module RAM16(
        input [15:0] data_a, data_b,
        input [9:0] addr_a, addr_b,
        input we_a, we_b, clk,
		  input [1:0] sel_a,
        output[15:0] q_a, q_b
);

wire [1:0] WEA = we_b? sel_a : 2'b00;

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
/* forth emit
.INIT_00(256'h1547_1566_0018_0028_002C_0046_001C_0024_0020_2355_001C_1547_000A_15C5_006E_15C6),
.INIT_01(256'h65C1_1001_0800_65C0_6000_6000_6000_0020_E5C0_1580_1547_1545_1547_658E_1547_13A6),
.INIT_02(256'h0000_0000_0000_C000_1547_02FB_2040_0040_65C2_940A_000C_0001_65F7_0012_1DC2_0008),
.INIT_03(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
*/

/*
.INIT_00(256'h0042_005C_003C_008A_004C_00BC_0038_005C_004C_2355_0038_1547_000A_15C5_00E4_15C6),
.INIT_01(256'h0002_1DA6_1547_1566_0034_0076_0056_0020_007A_0066_003C_003C_0090_008A_004C_0060),
.INIT_02(256'h1547_658E_1547_0004_65C6_1547_0002_65C6_1547_13A6_1547_0002_1036_13A6_1580_1547),
.INIT_03(256'h0302_FFFF_25D6_1547_1545_1547_FFFF_15CE_1547_0000_15CE_0303_258E_1547_0001_65CE),
.INIT_04(256'h0800_65C0_6000_6000_6000_0020_E5C0_1580_1547_0000_9F8E_1547_0002_65C5_1547_1545),
.INIT_05(256'h2F34_4611_1547_02FB_2040_0040_65C2_940A_001E_0001_65F7_0024_1DC2_0008_65C1_1001),
.INIT_06(256'h0000_0000_0000_0000_0000_0000_0000_0000_C000_3130_302E_3076_2045_524F_4320_3131),
.INIT_07(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
*/
/*
.INIT_00(256'h0072_00F0_0082_0133_006E_0092_0082_2355_006E_1547_000E_15C5_017B_15C4_0161_15C6),
.INIT_01(256'h1547_15A4_0038_00DC_008C_0024_00E0_00CC_0072_0072_00F6_00F0_0082_00AE_0078_0092),
.INIT_02(256'h00F6_00F0_0082_00AE_0078_0092_0072_FFEA_0977_0040_00F0_0082_FFF4_0977_1547_1505),
.INIT_03(256'h0002_1036_13A6_1580_1547_0002_1DA6_1547_1566_0040_008C_0058_00E0_00CC_0072_0072),
.INIT_04(256'h1547_558E_0001_0A76_0A4E_1547_658E_1547_0004_65C6_1547_0002_65C6_1547_13A6_1547),
.INIT_05(256'h030B_0000_25CE_1547_0001_E5CE_1547_0001_65CE_1547_100E_0C80_0C80_0C80_0C80_1380),
.INIT_06(256'h1547_1545_1547_FFFF_15CE_1547_0000_15CE_0303_258E_1547_FFFF_15CE_1547_0000_15CE),
.INIT_07(256'h6000_6000_0020_E5C0_1580_1547_0000_9F8E_1547_0002_65C5_1547_1545_0302_FFFF_25D6),
.INIT_08(256'h02FB_2040_0040_65C2_940A_002F_0001_65F7_0035_1DC2_0008_65C1_1001_0800_65C0_6000),
.INIT_09(256'h7620_4552_4F43_2031_312F_3446_1146_4544_4342_4130_3938_3736_3534_3332_3130_1547),
.INIT_0A(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00C0_0032_3030_2E30),
.INIT_0B(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
*/
/* slugu soviet union
.INIT_00(256'hECEE_EAF1_F2E5_E2EE_D120_F3E6_F3EB_D120_3A31_CCC2_3130_3831_0026_0977_008E_15C6),
.INIT_01(256'h0077_0010_0977_0304_0000_25C4_FF00_45C4_9544_FFFC_0077_0021_20F3_E7FE_EED1_20F3),
.INIT_02(256'h6104_6104_0020_E5C4_0020_0001_65F7_0026_1DC0_0085_0001_65C5_0302_0001_35C5_FFEC),
.INIT_03(256'h0000_0000_0000_C000_0085_02FB_2101_0040_65C0_9448_0008_65C4_1101_0800_65C4_6104),
.INIT_04(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
*/
//.INIT_00(256'h0040_65C0_9448_0008_65C3_1043_01FF_E5C0_0040_15C2_0004_15C4_0800_15C1_C1FF_15C0),
//.INIT_01(256'h0000_0000_0000_0000_FFFC_0077_02EC_0001_E5C4_0200_65C0_02F3_0001_E5C2_02FB_20C1),

//.INIT_00(256'h02fb_2081_0040_65c0_9448_0008_65c2_1042_01FF_e5c0_0040_15c3_0800_15c1_C1FF_15c0),
//.INIT_01(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_fffc_0077_02f3_0001_e5c3),
//      .INIT_00(256'hc002_15c0_000e_0977_0044_15c1_c001_15c0_001a_0977_003c_15c1_c000_15c0_006c_15c6),
//      .INIT_01(256'h7c66_66fc_0085_02Fb_2081_0040_65c0_9448_0008_65c2_1042_01ff_0002_0977_003c_15c1),
//      .INIT_02(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00f8_6c66_6666_6cf8_00f0_6060),
//      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      //.INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      //.INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
.INIT_00(256'h006C_0082_0078_01D8_00DC_0100_00F0_2355_00DC_1547_000E_15C5_0236_15C4_021C_15C6),
.INIT_01(256'h00F0_006C_0048_016C_0146_0104_FFF0_00DC_00F0_00E6_0100_00E0_008C_00DC_0000_00DC),
.INIT_02(256'h005C_0168_002E_016C_0158_00E0_00E0_013A_0060_00A2_017C_00F0_0060_0060_0060_00A2),
.INIT_03(256'h0182_00F0_0058_0977_00D8_0188_000D_00DC_0064_0977_00D8_0188_0020_00DC_0070_0977),
.INIT_04(256'h00FA_008C_016C_0158_00E0_00E0_0188_0182_00F0_0134_00E6_0100_00E0_004E_0977_00D8),
.INIT_05(256'h0140_0188_0182_0100_01C8_00DC_0108_0104_0FFF_00DC_00E0_0004_00DC_002E_0977_00D8),
.INIT_06(256'h1547_1566_1547_1505_1547_15A4_00D8_00F4_00F4_00AA_016C_0146_00F0_00E6_0126_00E6),
.INIT_07(256'h1547_0004_65C6_1547_0002_65C6_1547_13A6_1547_0002_1036_13A6_1580_1547_0002_1DA6),
.INIT_08(256'h0C80_0C80_0C80_1380_1547_100E_0C40_0C40_0C40_0C40_0C40_1380_1547_458E_1547_658E),
.INIT_09(256'h1547_0002_65CE_1547_0001_65CE_1547_100E_6000_6000_6000_6000_1380_1547_100E_0C80),
.INIT_0A(256'h0000_15CE_0303_258E_1547_FFFF_15CE_1547_0000_15CE_030B_0000_25CE_1547_0001_E5CE),
.INIT_0B(256'h0000_1F8E_1547_0002_65C5_1547_1545_0302_FFFF_25D6_1547_1545_1547_FFFF_15CE_1547),
.INIT_0C(256'h1001_0800_65C0_6000_6000_6000_0020_E5C0_0315_000D_25C0_1580_1547_0000_9F8E_1547),
.INIT_0D(256'h0030_0200_65F7_1547_02FB_2040_0040_65C2_940A_0042_0001_65F7_0048_1DC2_0008_65C1),
.INIT_0E(256'h4320_3131_2F34_4611_4645_4443_4241_3938_3736_3534_3332_3130_1547_002A_01FF_45F7),
.INIT_0F(256'h0000_0000_0000_0000_0000_0000_0000_C000_203E_2F34_4605_3230_302E_3076_2045_524F),
.INIT_10(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
.INIT_11(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),

//      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
//      .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
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
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
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
      .WEA({4{we_a}}), // 4-bit input: Port A byte-wide write enable input
      // Port A Data: 32-bit (each) input: Port A data
      .DIA({16'hFFFF,data_a}),    // 32-bit input: A port data input
      .DIPA(4'hF),     // 4-bit input: A port parity input
      // Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      .ADDRB({addr_b,4'd0}),  // 14-bit input: B port address input
      .CLKB(clk),      // 1-bit input: B port clock input
      .ENB(1'b1),      // 1-bit input: B port enable input
      .REGCEB(1'b0),   // 1-bit input: B port register clock enable input
      .RSTB(1'b0),     // 1-bit input: B port register set/reset input
      .WEB({2'b00,WEA}), // 4-bit input: Port B byte-wide write enable input
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

wire [1:0] WEA = we_b? sel_a : 2'b00;

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
      .WEA({4{we_a}}), // 4-bit input: Port A byte-wide write enable input
      // Port A Data: 32-bit (each) input: Port A data
      .DIA({16'hFFFF,data_a}),    // 32-bit input: A port data input
      .DIPA(4'hF),     // 4-bit input: A port parity input
      // Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
      .ADDRB({addr_b,4'd0}),  // 14-bit input: B port address input
      .CLKB(clk),      // 1-bit input: B port clock input
      .ENB(1'b1),      // 1-bit input: B port enable input
      .REGCEB(1'b0),   // 1-bit input: B port register clock enable input
      .RSTB(1'b0),     // 1-bit input: B port register set/reset input
      .WEB({2'b00,WEA}), // 4-bit input: Port B byte-wide write enable input
      // Port B Data: 32-bit (each) input: Port B data
      .DIB({16'hFFFF,data_b}),    // 32-bit input: B port data input
      .DIPB(4'hF)      // 4-bit input: B port parity input
   );

   // End of RAMB16BWER_inst instantiation
endmodule                               
