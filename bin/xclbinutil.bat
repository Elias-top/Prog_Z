@echo off
setlocal
call "%~dp0setupEnv.bat"

set _RDI_DONT_SET_XILINX_AS_PATH=True
set _RDI_NEEDS_VERSION=True
set _RDI_VERSION_PROG=xclbinutil

set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_PROG=xclbinutil

if DEFINED XILINX_XRT (
  call "%XILINX_XRT%/bin/%RDI_PROG%" %*
) ELSE (
  call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %*
)  
exit /b %errorlevel%
