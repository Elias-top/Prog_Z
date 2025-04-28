@echo off

if exist "_sdk/bsp/system.mss" (
	echo make: Nothing to be done for 'build-bsp'.
) else (
	xsct %XILINX_VITIS%/scripts/vitis/util/genbsp.tcl %2 %3
	cd _sdk\bsp
	call make
)
