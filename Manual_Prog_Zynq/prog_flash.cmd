echo Запуск hw_server...


echo Прошивка флеш-памяти Zynq...
cmd /C ..\bin\program_flash.bat -f BOOT.mcs -offset 0 -flash_type qspi-x4-single -fsbl fsbl.elf -verify -url tcp:localhost:3121

pause