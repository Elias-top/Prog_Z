@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 2016, 2019 Xilinx, Inc. All Rights Reserved.
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
if not defined _RDI_SETENV_RUN (
  call "%_RDI_BINROOT%/setupEnv.bat"
)
if defined _RDI_SETENV_RUN (
  set _RDI_SETENV_RUN=
)
set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=vpl

rem # Set XILINX_VIVADO and XILINX_VIVADO_HLS
set XILINX_VIVADO=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%
set XILINX_VIVADO_HLS=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%

set RDI_DEPENDENCY=XILINX_VIVADO_HLS

rem # HDI_PROCESSOR
rem # It is not clear what this should be on Windows. On Linux, HDI_PROCESSOR
rem # is set using `uname -m`, which if run on Windows with Cygwin, will return
rem # something like i686, which is what we will use here. A better approach
rem # might be to use the Windows systeminfo command, which will produce an
rem # entry for processors on the machine. But that command is slow, and it
rem # would require some processing to extract and map the processor to something.
rem # It would probably make more sense to determine this in C++ with Windows
rem # APIs. The end use of this value is to find the runtime libraries in
rem # pre/rdi/sdx/runtime/lib/<processor>, which don't exist for Windows yet.
if not defined HDI_PROCESSOR (
    set HDI_PROCESSOR=i686
)

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
