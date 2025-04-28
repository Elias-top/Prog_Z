@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-1999, 2001-2011 Xilinx, Inc. All Rights Reserved.
rem # 

rem ##
rem # Setup default environmental variables
rem ##
rem # RDI_BINROOT - Directory *this* script exists in
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_BINROOT=/usr/Test/Install/bin
rem #
rem # RDI_APPROOT - One directory above RDI_BINROOT
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_APPROOT=/usr/Test/Install
rem #
rem # RDI_BASEROOT - One directory above RDI_APPROOT
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_BINROOT=/usr/Test
rem ##
call "%~dp0setupEnv.bat"

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##
set INTERFACE=0
set RDI_ARGS=
  :parseArgs
    if [%1] == [] (
      goto argsParsed
    ) else (
    if [%1] == [-arch] (
      	  set ARCHITECTURE=%2
	  set RDI_ARGS=%RDI_ARGS% %1 %2
	  shift
    ) else (
	  if [%1] == [-interface] (
          set INTERFACE=1
    )
    set RDI_ARGS=%RDI_ARGS% %1
    ))
    shift
    goto parseArgs
  :argsParsed
set RDI_PROG=%~n0
set RDI_NO_JRE=yes
set BOOTGEN_EXEC=bootgen

if [%ARCHITECTURE%] == [fpga] (
	if [%INTERFACE%] == [0] (
		set BOOTGEN_EXEC=bootgen_fpga
	) else (
		set BOOTGEN_EXEC=bootgen
	)		
) else (
        set BOOTGEN_EXEC=bootgen
    )
)
call "%RDI_BINROOT%/loader.bat" -exec %BOOTGEN_EXEC% %RDI_ARGS%

endlocal
