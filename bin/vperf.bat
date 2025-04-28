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

set XILINX_VITIS=%RDI_APPROOT%
if exist "%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%" (
    set XILINX_VITIS=%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%
)

set script_path=%XILINX_VITIS%/scripts/noc_perfmon
echo vperf has moved to %script_path%
echo please install Python and libraries listed in %script_path%/requirements.txt
echo read %script_path%/README.md for more info
echo Calling: python %script_path%/noc_perfmon.py %*
python %script_path%/noc_perfmon.py %*

exit /b %ERRORLEVEL%

endlocal
