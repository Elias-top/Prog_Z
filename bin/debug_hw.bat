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
set _RDI_VERSION_PROG=debug_hw

set RDI_NO_JRE=1

set XILINX_VIVADO=%RDI_INSTALLROOT%\Vivado\%RDI_INSTALLVER%
set XILINX_VIVADO_HLS=%RDI_INSTALLROOT%\Vivado\%RDI_INSTALLVER%

if not defined VITIS_SDK (
  set XILINX_VITIS=%RDI_APPROOT%\SDK
) else (
  set XILINX_VITIS=%VITIS_SDK%
)

set XILINX_VITIS=%RDI_APPROOT%

set PATH=%XILINX_VIVADO%\bin;%PATH%
set PATH=%XILINX_VIVADO_HLS%\bin;%PATH%
set PATH=%XILINX_VITIS%\bin;%XILINX_VITIS%\gnuwin\bin;%XILINX_VITIS%\gnu\arm\nt\bin;%PATH%
set PATH=%RDI_APPROOT%\tps\win64\libxslt\bin;%PATH%

if [%RDI_VERBOSE%] == [True] (
  echo        XILINX_VIVADO: "%XILINX_VIVADO%"
  echo    XILINX_VIVADO_HLS: "%XILINX_VIVADO_HLS%"
  echo         XILINX_VITIS: "%XILINX_VITIS%"
)

set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_PROG=%RDI_APPROOT%\tps\win64\python-3.8.3\python
call %RDI_PROG% %RDI_APPROOT%\scripts\_debug_hw.py %*
popd
exit /b %errorlevel%
