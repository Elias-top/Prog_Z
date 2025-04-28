@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
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
call "%_RDI_BINROOT%\setupEnv.bat"

set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=sdcard_gen

set RDI_NO_JRE=1

set XILINX_VIVADO=%RDI_APPROOT%\Vivado
set XILINX_VIVADO_HLS=%RDI_APPROOT%\Vivado_HLS

set PATH=%XILINX_VIVADO%\bin;%PATH%
set PATH=%XILINX_VIVADO_HLS%\bin;%PATH%
set PATH=%RDI_APPROOT%\tps\win64\libxslt\bin;%PATH%

if [%RDI_VERBOSE%] == [True] (
  echo        XILINX_VIVADO: "%XILINX_VIVADO%"
  echo    XILINX_VIVADO_HLS: "%XILINX_VIVADO_HLS%"
)

set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_PROG=tclsh86t.exe
set RDI_BYPASS_ARGS=%RDI_PROG%
call "%RDI_BINROOT%\loader.bat" %RDI_BINROOT%\sdcard_gen.tcl %*
popd
exit /b %errorlevel%

