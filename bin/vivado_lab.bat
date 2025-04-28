@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
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
set RDI_PROG=%~n0
call "%~dp0setupEnv.bat"

rem # Set XILINX_VIVADO
set RDI_SETUP_ENV_FUNCTION=DIRNAME
call "%RDI_BINROOT%/setupEnv.bat" "%RDI_BINROOT%" XILINX_VIVADO  
set RDI_SUPPORT_32=1

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##
set RDI_LABTOOLS_STANDALONE_MODE=1
set RDI_USE_JDK21=1
set _RDI_NEEDS_PYTHON=True
call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %* 
