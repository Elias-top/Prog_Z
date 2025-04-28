@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
rem # 

set _RDI_CWD=%cd%
pushd "%~dp0"
set _RDI_BINROOT=%cd%
cd /d "%_RDI_CWD%"

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
call "%_RDI_BINROOT%/setupEnv.bat"

set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=messagepp


rem # Set XILINX_VIVADO
set RDI_SETUP_ENV_FUNCTION=DIRNAME
rem call "%RDI_BINROOT%/setupEnv.bat" "%RDI_BINROOT%" XILINX_VIVADO  

rem set RDI_DEPENDENCY=XILINX_VIVADO_HLS

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##

call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %*
popd
exit /b %errorlevel%
