@echo off
call "%~dp0setupEnv.bat"

set _RDI_DONT_SET_XILINX_AS_PATH=True
set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_PROG=buildinfo.exe
call "%RDI_BINROOT%/loader.bat" -exec %RDI_PROG% %*
exit /b %errorlevel%
