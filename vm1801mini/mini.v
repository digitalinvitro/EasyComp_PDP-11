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

wire [15:0]	mx_dat[2:0];					//
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
 
 
 .wbs_adr_i(wb_adr[3:0]),				// slave wishbone address
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
assign mx_stb[0]	= wb_stb & wb_cyc & (wb_adr[15:4] == (16'o177700 >> 4)); // FFC
assign mx_stb[1]	= wb_stb & wb_cyc & (wb_adr[15:14] == 2'o0);
assign mx_stb[2]	= wb_stb & wb_cyc & (wb_adr[15:3] == (16'o177560 >> 3)); // FF7
assign mx_stb[3]	= wb_stb & wb_cyc & (wb_adr[15:14] == 2'b11); // C000-FFFF

assign wb_mux		= (mx_stb[0] ? mx_dat[0] : 16'o000000)
						| (mx_stb[1] ? mx_dat[1] : 16'o000000);

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

wire [15:0] bus_do_II;
wire [15:0] bus_do;
wire [15:0] bus_di;
RAM16 RAM_F(
  .data_a(wb_out), 
  .addr_a(wb_adr[10:1]),
  .q_a(mx_dat[1]),
  .we_a(mx_stb[1] & wb_we),
  .sel_a(wb_sel),
  .data_b(16'hFFFF),
  .addr_b(10'h3FF),
  .q_b(bus_do_II),
  .we_b(1'b0), 
  .clk(mclkp)
);
/*
RAM RAM_F(
  .DI(wb_out), 
  .ADDR(wb_adr[10:1]),
  .DO(mx_dat[1]),
  .WR(wb_we),
  .SEL(wb_sel),
  .CLK(mclkp)
);
*/
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
                                                                          
                   
      .INIT_00(256'h15f7_c0e2_0060_15f7_c0a8_007c_15f7_c06e_0066_15f7_c034_0066_15f7_bffa_00fc_15f7),
      .INIT_01(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_fffc_0077_c156_00f0_15f7_c11c_0060),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
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
      .INIT_10(256'h000000000000000000000000000000000000000000000000_00_F0_60_60_7C_66_66_FC),
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
