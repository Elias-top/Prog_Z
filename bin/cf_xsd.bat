@echo off
setlocal ENABLEDELAYEDEXPANSION

set BIN_DIR=%~dp0
xtclsh %BIN_DIR%cf_xsd.tcl %*
exit /b %ERRORLEVEL%

endlocal
