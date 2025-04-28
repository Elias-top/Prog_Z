@echo off
setlocal ENABLEDELAYEDEXPANSION

set BASENAME=%~n0
set BIN_DIR=%~dp0
set BIN_DIR=%BIN_DIR:~0,-1%

rem # Get the apfcc install folder
pushd %BIN_DIR%
pushd ..
set PROD_INSTALL_DIR=%cd%
popd
popd

rem # Run unzip
%PROD_INSTALL_DIR%\tps\win64\unzip\bin\unzip.exe %*

exit /b %ERRORLEVEL%
endlocal
