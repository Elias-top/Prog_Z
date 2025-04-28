@echo off
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
set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_PROG=tclsh86t.exe
::call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %*
:: The loader above has trouble with '=' signs in the arguments
set RDI_BYPASS_ARGS=%RDI_PROG%
call "%RDI_BINROOT%\loader.bat" %*

::set _RDI_BINROOT=%~dp0
::set SDSOC_DIR=%_RDI_BINROOT:~0,-4%
::set PATH=%SDSOC_DIR%lib\win64.o;%PATH%
::set TCL_LIBRARY=%SDSOC_DIR%tps\tcl\tcl8.6
::%_RDI_BINROOT%\unwrapped\win64.o\tclsh86t.exe %*
exit /b %errorlevel%
