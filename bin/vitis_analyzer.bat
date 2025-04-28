@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-1999, 2001-2021 Xilinx, Inc. All Rights Reserved.
rem # 

set _RDI_NEEDS_PYTHON=True
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

rem # Set XILINX_VITIS
set RDI_SETUP_ENV_FUNCTION=DIRNAME
call "%RDI_BINROOT%/setupEnv.bat" "%RDI_BINROOT%" XILINX_VITIS

rem # Set XILINX_VIVADO
set XILINX_VIVADO=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##
set RDI_EXECCLASS="ui/Frank"
set RDI_USE_JDK21=1

rem ##
rem # Windows cmd does not support wildcard expansion. It is up to the app
rem # to roll their own solution. The following adds support for "*" expansion.
rem # e.g. *.txt => foo.txt bar.txt 
rem ##
set ARGS=%*

rem # Set ARGS to "_EMPTY_" if none were supplied. The find and replace logic
rem # below requires that the ARGS string is not empty.
if [%ARGS%] == [] (
  set ARGS="_EMPTY_"
)

@echo off
setlocal enabledelayedexpansion
rem #
rem # Replace all "*" occurances in the arguments with "_ASTERIX_".
rem #
set "replace=_ASTERIX_"
set "var=%ARGS%"
rem # Add dummy char to also accept a "*" in the front.
set "var=#!var!"
:replaceLoop
for /F "tokens=1 delims=*" %%A in ("!var!") do (
  set "prefix=%%A"
  set "rest=!var:*%%A=!"
  if defined rest (
    set "rest=!REPLACE!!rest:~1!"
    set Again=1
  ) else set "Again="
  set "var=%%A!rest!"
)
if defined again goto :replaceLoop
set "var=!var:~1!"

rem # Use the dir command to expand the "*" if it has been supplied.
if not x%var:_ASTERIX_=%==x%var% (
  @echo off
  setlocal enabledelayedexpansion
  set FILES=
  for /F "delims=" %%f in ('dir /b /a-d %ARGS%') do set FILES=!FILES! "%%f"
  set ARGS=!FILES!
)

rem # Reset arguments if none were supplied originally.
if [!ARGS!] == ["_EMPTY_"] (
  set ARGS=%*
)

call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %ARGS%
popd
exit /b %errorlevel%

