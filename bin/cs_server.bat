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

rem # Set XILINX_VIVADO
set RDI_SETUP_ENV_FUNCTION=DIRNAME
call "%RDI_BINROOT%/setupEnv.bat" "%RDI_BINROOT%" XILINX_VIVADO  

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##

if defined CS_SERVER_NO_PYTCF (
if [%CS_SERVER_NO_PYTCF%] == [False] (
        set RDI_PROG="%~n0_pytcf"
    ) else (
        set RDI_PROG=%~n0
    )
) else (
    set RDI_PROG=%~n0
)
set RDI_NO_JRE=yes
call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %* 
endlocal
