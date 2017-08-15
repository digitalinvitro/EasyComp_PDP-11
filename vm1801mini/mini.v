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
wire A_FFCx = wb_adr[15:4] == (16'o177700 >> 4);
wire A_FF7x = wb_adr[15:3] == (16'o177560 >> 3);
assign mx_stb[0]	= wb_stb & wb_cyc & A_FFCx; // FFCx
assign mx_stb[2]	= wb_stb & wb_cyc & A_FF7x; // FF7x

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 VP7 BFFF..B800  - b23 - 48K  (10|11.1)
 VP0 C7FF..C000  - b24 - 50K  (11|00.0)
 VP1 CFFF..C800  - b25 - 52K  (11|00.1)
 VP2 D7FF..D000  - b26 - 54K  (11|01.0)
 VP3 DFFF..D800  - b27 - 56K  (11|01.1)                   VIDEO RAM
 VP4 E7FF..E000  - b28 - 58K  (11|10.0)
 VP5 EFFF..E800  - b29 - 60K  (11|10.1)
 VP6 F7FF..F000  - b30 - 62K  (11|11.0)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
wire A_VP = (wb_adr[15:14] == 2'b10) | (wb_adr[15:14] == 5'b11);
 
assign mx_stb[3]	= wb_stb & wb_cyc & A_VP; // F7FF - b800 
assign mx_stb[1]	= wb_stb & wb_cyc & (!(A_FFCx | A_FF7x | A_VP)); // B7FF - 0000

/*
 10..0 - low bit address (in BRAM) 3FF..0 - 2048 (2K)
                    15   11 
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
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 BFFF..B800  - b23 - 48K  (1011.1)
 C7FF..C000  - b24 - 50K  (1100.0)
 CFFF..C800  - b25 - 52K  (1100.1)
 D7FF..D000  - b26 - 54K  (1101.0)
 DFFF..D800  - b27 - 56K  (1101.1)                   VIDEO RAM
 E7FF..E000  - b28 - 58K  (1110.0)
 EFFF..E800  - b29 - 60K  (1110.1)
 F7FF..F000  - b30 - 62K  (1111.0)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 FF70        - terminal 
 FFFF..F800  - b31 - 64K  (1111.1)
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
wire [7:0]WRV = {6'd0, (mx_stb[3] & wb_we)} << wb_adr[13:11];
VIDEORAM VRAM0( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[0]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[7]), .q_b(BUSV[0])
);
VIDEORAM VRAM1( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[1]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[0]), .q_b(BUSV[1])
);
VIDEORAM VRAM2( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[2]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[1]), .q_b(BUSV[2])
);
VIDEORAM VRAM3( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[3]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[2]), .q_b(BUSV[3])
);
VIDEORAM VRAM4( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[4]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[3]), .q_b(BUSV[4])
);
VIDEORAM VRAM5( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[5]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[4]), .q_b(BUSV[5])
);
VIDEORAM VRAM6( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[6]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[5]), .q_b(BUSV[6])
);
VIDEORAM VRAM7( 
 .clka(vclk), .data_a(8'd0), .addr_a(VADDR[10:0]), .we_a(1'b0), .q_a(vdata[7]),
 .clkb(mclkp), .data_b(wb_out), .addr_b(wb_adr[10:1]), .sel(wb_sel), .we_b(WRV[6]), .q_b(BUSV[7])
);

RAM RAMALL(.di(wb_out),.addr(wb_adr),.Q(ram_data),.we(mx_stb[1] & wb_we),.sel(wb_sel),.clk(mclkp));

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

