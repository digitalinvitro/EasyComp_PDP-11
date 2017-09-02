`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:49 05/23/2015 
// Design Name: 
// Module Name:    svga 
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
module video(
        output [8:0]RGB,
        output reg HSync = 1,
        output reg VSync = 1,
        output [13:0]PIXADDR,
        input  [7:0]PIXDATA,
        input  PixClock
);

//reg [15:0]COLOR;
reg [7:0]SHIFT;
assign RGB = {
 wCOLOR[8:6],         // RED:5
 wCOLOR[5:3],          // GREEN:6          
 wCOLOR[2:0]            // BLUE:5
}; 
 /*
      растр 1328 х 806
      экран 640x480 =>   pix = 4x4   => 256x192
   
       horizontal line [ 0 ] [ 1024 ] [  0 ]  => [0][512x2][0]
       vertical line   [ 0 ] [ 768 ] [ 0 ]  =>   [128][256x2][128]
*/
/* --- Настройки кадровой и строчной синхронизации под режим 1024x768 --- */
    wire [10:0]HFrontPorch    = 24;
    wire [10:0]HBackPorch     = 144;
    wire [10:0]LeftBorder     = 0;
    wire [10:0]HAddrVideo     = LeftBorder + 1024;
    wire [10:0]RightBorder    = HAddrVideo  + 0;
	 
    wire [10:0]HTotalTime     = 1328;
    wire [10:0]HSyncStartTime = 1048;  
    
    wire [9:0]VBackPorch     = 28;
    wire [9:0]TopBorder      = VBackPorch + 128;
    wire [9:0]VAddrVideo     = TopBorder  + 512;
    wire [9:0]BottomBorder   = VAddrVideo + 128; 
    
    wire [9:0]VTotalTime     = 806; 
    wire [9:0]VSyncStartTime = 771;

/* --- Счетчики горизонтальной 11bit (0...1328) и вертикальной разверток 10bit (0...806) --- */
    reg [10:0]hcnt = 0; 
    reg [9:0]vcnt = 0;
/* -- 
  Счетчики пикселей по горизонтали и по вертикали 
    1024 x 768 при отбрасывании последних 2 разрядов (так как точка 4х4 бита) - 256x192
-- */    
    reg [9:0]colcnt = 0;  // 0..1023 - 10 bit
    reg [8:0]rowcnt = 0;  // 0..511  - 9 bit

    wire H_SYNC = (hcnt==HSyncStartTime);
         
    wire   wVBackPorch = (vcnt < VBackPorch)? 1'b0 : 1'b1;

	 reg SelHSh = 1'b0;
/* Растр экрана */
    wire [1:0]SelVSh = 
     (vcnt < VBackPorch)?   2'b00  :
     (vcnt < TopBorder)?    2'b01  :
     (vcnt < VAddrVideo)?   2'b11  : 
     (vcnt < BottomBorder)? 2'b01  :  2'b00;
    
/*	 
    wire [1:0]SelHSh =
     (hcnt < HBackPorch)?  2'b00 :
     (hcnt < LeftBorder)?  2'b01 :
     (hcnt < HAddrVideo)?  2'b11 : 
     (hcnt < RightBorder)? 2'b01 :  2'b00;
*/
/*
  Адрес пикселя из блока памяти RAM4K - адресация 24Kb - 15 бит
  colcnt/2 = по 4 бита на пиксель
*/
`define Border 9'h1
`define BLANK  9'h0
//                      (0..511 row)/2   (0..1023 byte)/2
assign PIXADDR = {rowcnt[8:1],colcnt[9:4]};

wire pixreq = (colcnt[3:0] == 4'b0000);

wire [8:0]PIXCOLOR = (SHIFT[7])? 16'h03E0 : 16'd0;
wire [8:0]wCOLOR = 
({SelVSh,SelHSh} == 4'b001)?  `BLANK  :
({SelVSh,SelHSh} == 4'b011)?  `BLANK  :
({SelVSh,SelHSh} == 4'b111)?  `BLANK  :
({SelVSh,SelHSh} == 4'b110)?   PIXCOLOR : `BLANK;

/* --- управляем счетчиками развертки экрана --- */
//reg VPorchSYNC = 1'b0;
//assign  VPorch = VPorchSYNC;
reg [1:0]Req = 2'b00;

always@(posedge PixClock) begin

//     COLOR <= wCOLOR;
     Req <= {Req[0], pixreq};
	  if(!colcnt[0]) SHIFT[7:0] <= (Req)? PIXDATA[7:0] : {SHIFT[6:0], 1'b0};
      
     if(vcnt==VTotalTime) begin
        VSync <= 1'b1;
        vcnt  <= 0;
        rowcnt <= 0;
     end         
     else begin
        if(vcnt==VSyncStartTime) VSync <= 1'b0; 
        vcnt <= vcnt + H_SYNC;
     end         

// Front edge Sync
     if((hcnt == HSyncStartTime) | (hcnt==(HTotalTime - HBackPorch))) HSync <= !HSync;
     
	  if((hcnt == HAddrVideo)|(hcnt == HTotalTime)) SelHSh <= !SelHSh;
  
  
     if(hcnt == HTotalTime) begin
        hcnt  <= 0;
        colcnt <= 0;
             if(vcnt > TopBorder) begin
               rowcnt <= rowcnt + 1'b1;
             end
     end         
     else begin 
        hcnt <= hcnt + 1'b1;
     end         

     if({SelVSh,SelHSh} == 3'b110)  colcnt <= colcnt + 1'b1;
end
endmodule

