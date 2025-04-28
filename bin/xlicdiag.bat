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

set RDI_PROG=%~n0
call "%_RDI_BINROOT%/setupEnv.bat"

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##

rem # DO NOT REMOVE THIS NEXT LINE (NEEDED FOR LAUNCH OF NON-GUI TOOLS)
set RDI_JAVALAUNCH=

call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %* 
popd
exit /b %errorlevel%
