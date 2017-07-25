/*
// последовательный приемник
// 38400бит/сек
// 8бит, без четности
module serial_rx(
    input wire reset,
    input wire clk,
    input wire rx,
    output reg [7:0]rxbyte,
    output ready
    );

//скорость приема и передачи определяется этой константой
//она рассчитана из исх. тактовой частоты 185,142857 Mhz и желаемой скорости 38400
//как (162000000)/38400 ~ 4219
//как (152000000)/38400 ~ 3958 
//как (153600000)/38400 = 4000 
//как (156000000)/38400 ~ 4063
//как (157714286)/38400 ~ 4107
//как (185142857)/38400 ~ 4821
//как (192000000)/38400 = 5000
// 920000000/38400 ~ 2396 
parameter RCONST = 2395; 

reg [3:0]num_bits = 9; //счетчик принятых бит
reg [7:0]shift_reg; //сдвиговый регистр приемника
reg [11:0]cnt;
reg bit9 = 1'b0;
reg rxrd = 1'b0;

//assign rx_byte = shift_reg;

//счетчик длительности принимаемого бита
always @(posedge clk or negedge reset)
begin
    if(!reset)
        cnt <= 0;
    else
    begin
        if(cnt == RCONST || num_bits==9)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
end

assign ready = rxrd & !bit9;

//приемник
always @(posedge clk or negedge reset)
begin
    if(!reset) begin
        num_bits <= 9;
        shift_reg <= 0;
                  bit9 <= 1'b0;
                  rxrd <= 1'b0;
    end
    else begin
        //прием начинается когда RX падает в ноль
        if(num_bits==9 && rx==1'b0) begin
            num_bits <= 0;
        end    
        else if(cnt == RCONST) begin
            num_bits <= num_bits + 1'b1;
                  end
        
        //фиксация принятого бита где-то посередине
        if(cnt == RCONST/2) shift_reg <= {rx,shift_reg[7:1]};

        bit9 <= (bit9)? !(num_bits==9) : (num_bits == 8);
        rxrd <= bit9;
    end
end

//сигнал готовности принятого байта        
always@(posedge clk) begin
      rxbyte <= shift_reg;
end    
endmodule
*/

// последовательный приемник
// 38400бит/сек
// 8бит, без четности
module serial_rx(
    input wire reset,
    input wire clk,
    input wire rx,
    input wire rxread,
    output [7:0]rxbyte,
    output reg ready = 0
);

//скорость приема и передачи определяется этой константой
//она рассчитана из исх. тактовой частоты 185,142857 Mhz и желаемой скорости 38400
//как (162000000)/38400 ~ 4219
//как (152000000)/38400 ~ 3958 
//как (153600000)/38400 = 4000 
//как (156000000)/38400 ~ 4063
//как (157714286)/38400 ~ 4107
//как (185142857)/38400 ~ 4821
//как (192000000)/38400 = 5000
// 920000000/38400 ~ 2396 
parameter RCONST = 2396; 

reg [3:0]num_bits = 10;     //счетчик принятых бит
reg [7:0]shift_reg = 0;    //сдвиговый регистр приемника
reg [11:0]cnt = 0;         //счетчик предделитель битрейта

assign rxbyte = shift_reg;

//приемник
always @(posedge clk or negedge reset)
begin
    if(!reset) begin
        num_bits <= 4'd10;
        shift_reg <= 0;
        cnt <= 0;
        ready <= 0;
    end
    else begin
        //прием начинается когда RX падает в ноль
        if(num_bits == 4'd10 && rx == 1'b0)
            num_bits <= 4'd0;
        else if(cnt == RCONST)
		      num_bits <= num_bits + 1'b1;

        //фиксация принятого бита где-то посередине, если это не стоп-биты (9 бит, и т.д)
        if(cnt == RCONST/2 && num_bits < 4'd9) shift_reg <= {rx,shift_reg[7:1]};

        //счетчик длительности принимаемого бита
        cnt <= (cnt == RCONST || num_bits == 4'd10)? 12'd0 : cnt + 1'b1;

        // фиксация готовности по приему стоп-бита
        ready <= (ready)? !rxread : (cnt == RCONST/2 && num_bits == 4'd9);
    end
end

endmodule


// последовательный передатчик UART
// 38400бит/сек
// 8бит, без четности
module serial_tx(
    input reset,
    input clk,
    input [7:0]sbyte,
    input send,
    output tx,
    output reg busy = 1'b0
    );

parameter RCONST = 2396; 

//передатчик
reg [8:0]send_reg = 9'b1_1111_1111;
reg [3:0]send_num = 10;
reg [11:0]send_cnt;

wire send_time;
assign send_time = (send_cnt == RCONST);
assign tx = send_reg[0];

always @(posedge clk or negedge reset)
begin
        if(!reset)
        begin
//                send_reg <= 0; 
                send_num <= 10;
                send_cnt <= 0;
        end
        else
        begin
                //передача начинается по сигналу send
                if(send) begin
                        //загружаем передаваемый байт в сдвиговый регистр по сигналу send
                        send_reg <= {sbyte,1'b0};
                        send_num <= 0;
                end
                else if(send_time && send_num != 10) begin
                        //выдвигаем передаваемый байт
                        send_reg <= {1'b1,send_reg[8:1]};
                        send_num <= send_num + 1'b1;
                end
                send_cnt <= (send | send_time)? 12'd0 : send_cnt + 1'b1; 
        end
end

always@(posedge clk)
begin
        busy <= (send_num != 10);
end
        
endmodule
