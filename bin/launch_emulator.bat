@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
rem #

set _RDI_CWD=%cd%
pushd "%~dp0"
set _RDI_BINROOT=%cd%
cd /d "%_RDI_CWD%"

set RDI_PROG=%~n0
call "%_RDI_BINROOT%\setupEnv.bat"

set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=launch_emulator

set XILINX_VIVADO=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%

set XILINX_VERSION_VITIS=UnknownVersion
if exist "%RDI_APPROOT%/data/version.bat" (
    call "%RDI_APPROOT%/data/version.bat"
)
set _VITIS_VERSION=%XILINX_VERSION_VITIS%

:: ****************************************************************
:: In the below lines, we need to shorten paths set by RDI. RDI uses paths in this form
:: VITIS_VIVADO=r:/xbuilds/2019.2_daily_latest/installs/nt64/Vitis/2019.2
:: So we shorten them to m:/Vitis/2019.2
:: ****************************************************************
if exist m:\ subst /d m:
subst m: \\ppdeng\gdrive\xbuilds\%_VITIS_VERSION%_daily_latest\installs\nt64
set VITIS_DAILY_LATEST=m:\Vitis\%_VITIS_VERSION%
set VITIS_DAILY_LATEST_ROOT=m:
set XILINX_VITIS=%RDI_APPROOT%

if not defined XILINX_QEMU (
    set XILINX_QEMU=%VITIS_DAILY_LATEST_ROOT%\Vitis\%_VITIS_VERSION%\data\emulation
)

set ZYNQ_QEMU_PATH=%XILINX_QEMU%/qemu_win/zynq
set VERSAL_QEMU_PATH= %XILINX_QEMU%/qemu_win/versal

 
set PATH=%XILINX_VIVADO%\bin;%PATH%
set PATH=%XILINX_VITIS%\bin;%PATH%

set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_PROG=tclsh86t.exe
set RDI_BYPASS_ARGS=%RDI_PROG%
call "%RDI_BINROOT%\loader.bat" %RDI_APPROOT%\data\emulation\scripts\launch_emulator.tcl %*
popd

if exist exit_shell.txt (
  exit
) else (
  exit /b %errorlevel%
)
