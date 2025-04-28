@echo off
setlocal ENABLEDELAYEDEXPANSION

set _RDI_CWD=%cd%
pushd "%~dp0"
set _RDI_BINROOT=%cd%
cd /d "%_RDI_CWD%"

set PATH=%BIN_DIR%..\lib\win64.o;%PATH%
set RDI_PROG=%~n0

if not defined _RDI_SETENV_RUN (
  call "%_RDI_BINROOT%/setupEnv.bat"
)
if defined _RDI_SETENV_RUN (
  set _RDI_SETENV_RUN=
)
set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=cf2xd
call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %*

popd
exit /b %errorlevel%
