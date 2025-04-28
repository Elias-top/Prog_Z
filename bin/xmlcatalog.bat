@echo off
setlocal ENABLEDELAYEDEXPANSION

set BASENAME=%~n0
set BIN_DIR=%~dp0
set BIN_DIR=%BIN_DIR:~0,-1%

pushd %BIN_DIR%
pushd ..
set SDI_INSTALL_DIR=%cd%
popd
popd

set PATH=%BIN_DIR%\unwrapped\win64.o;%PATH%
set PATH=%SDI_INSTALL_DIR%\lib\win64.o;%PATH%

%BIN_DIR%\unwrapped\win64.o\xmlcatalog %*
exit /b %ERRORLEVEL%

endlocal
