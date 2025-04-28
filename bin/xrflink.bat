@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-1999, 2001-2012 Xilinx, Inc. All Rights Reserved.
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

set _RDI_DONT_SET_XILINX_AS_PATH=True
rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##
set RDI_PROG=%~n0
call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %* 
