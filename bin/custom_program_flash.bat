@echo off
setlocal
call "%~dp0setupEnv.bat"
set RDI_PROG=%~n0
set RDI_NO_JRE=yes
echo Starting flash process...
call "%RDI_BINROOT%/loader.bat" -exec rdi_zynq_flash %* 2>&1 | findstr /V "^$"
echo Flash process completed.
endlocal