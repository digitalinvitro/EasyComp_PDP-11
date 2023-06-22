﻿# EasyComp_PDP-11
FPGA реализация простейшего PDP-11 компьютера 
* Проект для ISE WebPACK FPGA design solution
* HDL - Verilog
* Основан на реверс-инжиниринг коде 1801ВМ1 процессора: 
http://zx-pk.ru/threads/23978-tsifrovaya-arkheologiya-1801-i-vse-vse-vse.html  
## В качестве монитора системы исопльзуется Форт:  
| Команда  | Описание |
| ------------- | ------------- |
| _addr_ `g` | запуск кода с адреса _addr_ |  
| _addr_ _len_ `dump` | дамп памяти с адреса _addr_ длинной _len_  |
| _addr_ `@` | считать слово (16-бит) из памяти по адресу _addr_ |
| _value_ _addr_ `!` | записать слово _value_ (16-бит) по адресу _addr_ (16-бит) в память  
| _addr_ `С@` | считать байт (8-бит) из памяти по адресу _addr_ 
| _value_ _addr_ `С!` | записать байт _value_ (8-бит) по адресу _addr_ (16-бит) в память  
| `+` | сложение top и subtop  
| `-` | вычитание top и subtop  
| `.hex` | вывести вершину стека top в шестнадцатеричном виде  
| _value_ | внести в форт-стек значение _value_ (16-бит) в шестнадцатеричном виде
