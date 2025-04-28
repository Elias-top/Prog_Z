@echo off
setlocal
::
:: COPYRIGHT NOTICE
:: Copyright 2016 Xilinx, Inc. All Rights Reserved.
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
set _RDI_VERSION_PROG=mkfatimg

set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_PROG=%~n0
:: The loader has trouble with '=' signs in the arguments, so bypass them
set RDI_BYPASS_ARGS=%RDI_PROG%
call "%RDI_BINROOT%\loader.bat" %*
exit /b %errorlevel%


