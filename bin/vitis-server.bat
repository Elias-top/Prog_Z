@echo off
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
rem #
set RDI_EXIT=

setlocal enableextensions enabledelayedexpansion

rem # RDI_ARGS_FUNCTION must be cleared here, otherwise child
rem # planAhead processes will inherit the parent's args.
set RDI_ARGS_FUNCTION=

if not defined _RDI_SETENV_RUN (
  call "%~dp0/setupEnv.bat"
)
if defined _RDI_SETENV_RUN (
  set _RDI_SETENV_RUN=
)

set _RDI_DONT_SET_XILINX_AS_PATH=True
set XIL_NO_OVERRIDE=0
set XIL_SUPPRESS_OVERRIDE_WARNINGS=1
set RDI_NO_JRE=1
set RDI_USE_JDK11=1

if defined RDI_EXIT (
  goto :EOF
)

set RDI_OS_ARCH=64
set RDI_OPT_EXT=.o

rem #
rem # If True check for the existence of RDI_PROG prior to calling into
rem # rdiArgs.bat
rem #
set RDI_CHECK_PROG=True

if exist "%RDI_INSTALLROOT%/SharedData/%RDI_INSTALLVER%" (
  set SHARED_DATA_HOME="%RDI_INSTALLROOT%/SharedData/%RDI_INSTALLVER%"
)

if exist "%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%" (
  set XILINX_VIVADO=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%
  set XILINX_VIVADO_HLS=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%
  set RDI_DEPENDENCY=XILINX_VIVADO_HLS;XILINX_HLS;VITIS_HLS_SETUP
) else (
  @REM unset RDI_DEPENDENCY variable
  set RDI_DEPENDENCY=
)

set XILINX_VITIS=%RDI_APPROOT%


if exist "%RDI_INSTALLROOT%\Vitis\%RDI_INSTALLVER%" (
	SET XILINX_VITIS=%RDI_INSTALLROOT%\Vitis\%RDI_INSTALLVER%
)

if exist "%RDI_INSTALLROOT%\Vivado\%RDI_INSTALLVER%" (
  set PATH=%XILINX_VIVADO_HLS%\bin;!PATH!
  set PATH=%XILINX_VIVADO%\bin;!PATH!
)
set PATH=%XILINX_VITIS%\bin;!PATH!
set PATH=%XILINX_VITIS%\tps\win64\libxslt\bin;!PATH!
set PATH=%XILINX_VITIS%\lib\win64.o;!PATH!

@REM Unified Vitis Env settings
set JAVA_HOME=%XILINX_VITIS%\tps\win64\jre11.0.16_1
set JAVA_EXE=%JAVA_HOME%\bin\java.exe
set PATH=%JAVA_HOME%\bin;!PATH!

@REM Lopper Evnironment
set PATH=%XILINX_VITIS%\tps\win64\python-3.8.3;%PATH%
set LOPPER_DTC_FLAGS=-b 0 -@
SET PATH=%XILINX_VITIS%\bin;%XILINX_VITIS%\gnu\microblaze\nt\bin;%XILINX_VITIS%\gnu\microblaze\linux_toolchain\nt64_le\bin;%XILINX_VITIS%\gnu\aarch32\nt\gcc-arm-linux-gnueabi\bin;%XILINX_VITIS%\gnu\aarch32\nt\gcc-arm-none-eabi\bin;%XILINX_VITIS%\gnu\aarch64\nt\aarch64-linux\bin;%XILINX_VITIS%\gnu\aarch64\nt\aarch64-none\bin;%XILINX_VITIS%\gnu\armr5\nt\gcc-arm-none-eabi\bin;%XILINX_VITIS%\gnuwin\bin;%PATH%
set PATH=%XILINX_VITIS%\tps\win64\cmake-3.24.2\bin;%PATH%

if defined VITIS_IDE_USER_TOOLCHAIN ( 
   set PATH=%VITIS_IDE_USER_TOOLCHAIN%;!PATH!
)

@REM Env variable support to disable license check
set IDE_SKIP_SERVER_LICENSE=1
call "%XILINX_VITIS%\tps\win64\lopper-1.1.0-packages\min_sdk\environment-setup.bat"

call "%~dp0/rdiArgs.bat"

if defined XILINX_PATH (
  set "IS_PATCH_AVAILABLE_BUT_INVALID=false"
  if not exist %XILINX_PATH%\patch.properties (
  echo Error: patch.properties file not found!
  set "IS_PATCH_AVAILABLE_BUT_INVALID=true"
  ) else (
    set XILINX_VITIS_VERSION=UnknownVersion
    if exist "%RDI_BINROOT%/unwrapped/win64.o/prodversion.exe" (
      for /F "delims=" %%i in ('%RDI_BINROOT%/loader.bat -exec prodversion Vitis') do set XILINX_VITIS_VERSION=%%i
    )
	echo XILINX_VITIS_VERSION = !XILINX_VITIS_VERSION!
    rem Read the properties file
    for /f "tokens=1,2 delims==" %%a in (%XILINX_PATH%\patch.properties) do (
    set "key=%%a"
    set "value=%%b"
    if "%%a"=="patch.number" set patch_number=!value!
    if "%%a"=="patch.release" set patch_release=!value!
    )

	echo !XILINX_VITIS_VERSION! | findstr /C:"!patch_release!" >nul
	if !errorlevel! equ 0 (
		set "IS_PATCH_AVAILABLE_BUT_INVALID=false"
	) else (
		set "IS_PATCH_AVAILABLE_BUT_INVALID=true"
		echo Error: Patch !patch_number! is not compatible with the current install (!XILINX_VITIS_VERSION!)
	)
  )
)

if defined XILINX_PATH (
  if not "!IS_PATCH_AVAILABLE_BUT_INVALID!"=="true" (
    @REM Invoke Unified Vitis New Server from patch
	echo Compatible patch !patch_number! found at !XILINX_PATH!. Launching Vitis server from the patch.
    "%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %VITISNG_SERVER_OPTS%  -classpath "%XILINX_PATH%/vitis-server/lib/*;%XILINX_VITIS%/vitis-server/lib/*" com.xilinx.rigel.app.RigelApp %*
  ) else (
    "%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %VITISNG_SERVER_OPTS%  -classpath "%XILINX_VITIS%/vitis-server/lib/*" com.xilinx.rigel.app.RigelApp %*
  )
) else (
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %VITISNG_SERVER_OPTS%  -classpath "%XILINX_VITIS%/vitis-server/lib/*" com.xilinx.rigel.app.RigelApp %*
)
