@echo off

set XILINX_SDX=1
call xsct -sdx %XILINX_VITIS%\scripts\vitis\util\prebuild.tcl %*    
if exist "_ide\bsp" (
	chdir _ide\bsp
	if exist "bsp.do.build" (
		call make        
		del bsp.do.build	
	) else (
		echo  make: Nothing to be done for 'pre-build'.
	)
)
