# EasyComp_PDP-11
FPGA реализация простого PDP-11 компьютера 
* Проект для ISE WebPACK FPGA design solution
* HDL - Verilog
* Основан на реверс-инжиниринг коде 1801ВМ1 процессора: 
http://zx-pk.ru/threads/23978-tsifrovaya-arkheologiya-1801-i-vse-vse-vse.html
* В качестве монитора системы исопльзуется Форт:
   `addr go            - запуск кода с адреса addr
   addr len dump      - дамп памяти с адреса addr длинной len
   addr @             - считать слово (16-бит) из памяти по адресу addr
   value addr !       - записать слово value (16-бит) по адресу (16-бит) addr в память
   addr С@            - считать байт (8-бит) из памяти по адресу addr
   value addr С!      - записать байт value (8-бит) по адресу (16-бит) addr в память
   +                  - сложение top и subtop
   -                  - вычитание top и subtop
   .hex               - вывести вершину стека top в шестнадцатеричном виде
   value              - внести в стек значение (16-бит) в шестнадцатеричном виде`


