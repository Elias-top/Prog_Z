@echo off
setlocal
::
:: COPYRIGHT NOTICE
:: Copyright 2015 Xilinx, Inc. All Rights Reserved.
::
call "%~dp0setupEnv.bat"

::
:: Launch the loader and specify the executable to launch
::
::
:: Loader arguments:
::   -exec   -- Name of executable to launch
::
set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=build_xd_ip_db


set RDI_NO_JRE=1
set RDI_PROG=tclsh86t.exe
set RDI_BYPASS_ARGS=%RDI_PROG%
call "%RDI_BINROOT%\loader.bat" %RDI_BINROOT%\build_xd_ip_db.tcl %*

exit /b %errorlevel%
