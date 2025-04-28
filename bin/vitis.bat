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

if not defined XILINX_VIVADO if exist "%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%" (
  set XILINX_VIVADO=%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%
)

set XILINX_VITIS=%RDI_APPROOT%

set XILINX_VITIS_VERSION=UnknownVersion
if exist "%RDI_BINROOT%/unwrapped/win64.o/prodversion.exe" (
    for /F "delims=" %%i in ('%RDI_BINROOT%/loader.bat -exec prodversion Vitis') do set XILINX_VITIS_VERSION=%%i
)
if exist "%RDI_APPROOT%/data/version.bat" (
  call "%RDI_APPROOT%/data/version.bat"
)

if exist "%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%" (
  set XILINX_VITIS=%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%
)

if exist "%RDI_INSTALLROOT%/Vivado/%RDI_INSTALLVER%" (
  set PATH=%XILINX_VIVADO%/bin;!PATH!
)

if not defined XILINX_HLS (
  if exist "%XILINX_VITIS%/data/hls" (    
    set XILINX_HLS=%XILINX_VITIS%
  ) else if exist "%RDI_INSTALLROOT%/Vitis_HLS/%RDI_INSTALLVER%/data/hls" (  
    set XILINX_HLS=%RDI_INSTALLROOT%\Vitis_HLS\%RDI_INSTALLVER%
  )
)

if not defined XILINX_VITIS_AIETOOLS (
  if exist "%XILINX_VITIS%/aietools" (
    set XILINX_VITIS_AIETOOLS=%XILINX_VITIS%/aietools
  )
)

rem Find all tool/tps location (check Vivado then Vitis)
set tooldir=win64\tools\clang
set TOOLS_CLANG=%XILINX_VIVADO%\%tooldir%
if not exist "%TOOLS_CLANG%" set TOOLS_CLANG=%XILINX_VITIS%\%tooldir%

set tooldir=tps\win64\jre11.0.16_1
set JAVA_HOME=%XILINX_VIVADO%\%tooldir%
if not exist "%JAVA_HOME%" set JAVA_HOME=%XILINX_VITIS%\%tooldir%

set tooldir=tps\win64\libxslt
set TPS_LIBXSLT=%XILINX_VIVADO%\%tooldir%
if not exist "%TPS_LIBXSLT%" set TPS_LIBXSLT=%XILINX_VITIS%\%tooldir%

set tooldir=tps\win64\python-3.8.3
set TPS_PYTHON=%XILINX_VIVADO%\%tooldir%
if not exist "%TPS_PYTHON%" set TPS_PYTHON=%XILINX_VITIS%\%tooldir%

set tooldir=tps\win64\cmake-3.24.2
set TPS_CMAKE=%XILINX_VIVADO%\%tooldir%
if not exist "%TPS_CMAKE%" set TPS_CMAKE=%XILINX_VITIS%\%tooldir%

set tooldir=tps\win64\git-2.41.0
set TPS_GIT=%XILINX_VIVADO%\tps\win64\git-2.45.0
if not exist "%TPS_GIT%" set TPS_GIT=%XILINX_VITIS%\%tooldir%

if defined XILINX_HLS if not [%XILINX_HLS%] == [%XILINX_VITIS%] (
  set PATH=%XILINX_HLS%\bin;!PATH!
  set PATH=%XILINX_HLS%\lib\win64.o;!PATH!
)

set PATH=%XILINX_VITIS%/bin;!PATH!
if exist "%TPS_LIBXSLT%" set PATH=%TPS_LIBXSLT%/bin;!PATH!
set PATH=%XILINX_VITIS%/lib/win64.o;!PATH!


set NOSPLASH=false
set VITISNEW=true

set args=%*
set arr.length=0

for %%I in (%args%) do (
  set val=%%I
  set arr[!arr.length!]=!val:"=!
  if not %%I == -classic (
    if not %%I == --classic (
      set args_for_classic=!args_for_classic! !val:"=!
    )
  )
  
  if not %%I == -s (
    if not %%I == --source (
      set args_for_source=!args_for_source! !val:"=!
    )
  )
  
  set /a arr.length=!arr.length! + 1
)

set /a arr.Ubound=%arr.length% - 1
for /L %%I in (0, 1, %arr.Ubound%) do (
  if !arr[%%I]! == -nosplash (
    set NOSPLASH=true
    @REM GOTO:doneProcessing
  ) else if !arr[%%I]! == -classic (
    set VITISNEW=false
    goto doneProcessing
  ) else if !arr[%%I]! == --classic (
    set VITISNEW=false
    goto doneProcessing
  ) else if !arr[%%I]! == -i (
    set INTERACTIVE=true
    goto doneProcessing
  ) else if !arr[%%I]! == --interactive (
    set INTERACTIVE=true
    goto doneProcessing
  ) else if !arr[%%I]! == -s (
    set SOURCE=true
    call set /a n=%%I+1
    goto SOURCEFILE
  ) else if !arr[%%I]! == --source (
    set SOURCE=true
    call set /a n=%%I+1
    goto SOURCEFILE     
  ) else if !arr[%%I]! == -w (
    set WORKSPACE=true
    call set /a dirIndex=%%I+1
    goto WORKSPACEDIR
  ) else if !arr[%%I]! == --workspace (
    set WORKSPACE=true
    call set /a dirIndex=%%I+1
    goto WORKSPACEDIR
  ) else if !arr[%%I]! == -h (
    goto HELP
  ) else if !arr[%%I]! == --help (
    goto HELP
  ) else if !arr[%%I]! == -new (
    echo "Error: -new option is not supported by vitis."
    echo "The default IDE is the new Unified Vitis IDE."
    exit /b 1
  ) else (
    echo.
    echo Error: Unsupported option !arr[%%I]!
    echo Please provide a valid option to continue.
    echo.
    goto HELP
  )
)

:SOURCEFILE
set sourceFile=!arr[%n%]!
for %%A in ("!sourceFile!") do (
  set "sourceWithoutExtension=%%~nA"
)

:WORKSPACEDIR
set workspaceDir=!arr[%dirIndex%]!

:doneProcessing
if [!NOSPLASH!] == [true] (
  GOTO:launch
)

echo.
echo ****** Xilinx Vitis Development Environment
echo ****** %XILINX_VITIS_VERSION%
echo|set /p="****** " || cmd /c "exit /b 0"
rem # Need to pass args, in particular -dbg, otherwise the executable might not be found
rem # sdsbuildinfo itself ignores all arguments, so extra arguments should be safe.
call %RDI_BINROOT%/buildinfo.bat %*
echo     ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
echo     ** Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
echo.
rem # echo Loading Vitis plugins ...

set supports_classic_ide=true
if exist "%XILINX_VITIS%/.vitis_embedded" (
  set VITIS_EMBEDDED_INSTALL=true
  set supports_classic_ide=false
) 
if exist "%XILINX_VITIS%/.vitis_for_hls" (
  set VITIS_HLS_INSTALL=true
  set supports_classic_ide=false
)

:launch
if [!VITISNEW!] == [false] (
  if not [!supports_classic_ide!] == [true] (
    echo Error: -classic option is only supported by full Vitis installation.
    echo If you wish to run the classic Vitis IDE, please download the AMD Unified Installer and perform a full Vitis installation.
    exit /b 1
  )
  set RDI_PROG=%~n0
  call "%RDI_BINROOT%/loader.bat" -exec rdi_vitis %args_for_classic%
  goto :EOF
)

@REM Unified Vitis Env settings
if exist "%JAVA_HOME%\bin" set PATH=%JAVA_HOME%\bin;!PATH!
if exist "%TOOLS_CLANG%\bin" set PATH=%TOOLS_CLANG%\bin;!PATH!
if exist "%TPS_CMAKE%\bin" set PATH=%TPS_CMAKE%\bin;%PATH%
if exist "%TPS_GIT%\bin" set PATH=%TPS_GIT%\bin;%PATH%

set XILINX_VITIS_GIT=%TPS_GIT%\bin

@REM unset RDI_DEPENDENCY variable
set RDI_DEPENDENCY=

@REM Lopper Evnironment
if exist "%TPS_PYTHON%" set PATH=%TPS_PYTHON%;%PATH%

if defined XILINX_PATH (
  echo Got variable XILINX_PATH at !XILINX_PATH!
  if not exist %XILINX_PATH%\patch.properties (
    echo Warning: patch.properties file not found! A valid patch.properties file is required and 
    echo needs to be placed in the top level directory of the patch - Patch has not been applied.
    echo Launching Vitis server from the installs...
  ) else (
    rem Read the properties file
    for /f "tokens=1,2 delims==" %%a in (%XILINX_PATH%\patch.properties) do (
      set "key=%%a"
      set "value=%%b"
      if "%%a"=="patch.number" set patch_number=!value!
      if "%%a"=="patch.release" set patch_release=!value!
    )

    echo !XILINX_VITIS_VERSION! | findstr /C:"!patch_release!" >nul
    if !errorlevel! equ 0 (
      echo Patch !patch_number! found at !XILINX_PATH!, activated successfully.
      set PYTHONPATH=%PYTHONPATH%;%XILINX_PATH%\cli;%XILINX_PATH%\cli\python-packages\win64;%XILINX_PATH%\cli\python-packages\site-packages;%XILINX_PATH%\cli\proto;%XILINX_PATH%\scripts\python_pkg;
      set PATCH_INFO=Patch !XILINX_PATH! ^(!patch_number!, !patch_release!^) Details - !patch_desc!
      if exist "!XILINX_PATH!\ide\electron-app\win64\resources\app\" (
        if exist "!XILINX_PATH!\ide\electron-app\win64\resources\app\src-gen\backend\main.js" (
          if exist "!XILINX_PATH!\ide\electron-app\win64\resources\app\lib\index.html" (
            set "CUSTOM_THEIA_PROJECT_APP_PATH=!XILINX_PATH!\ide\electron-app\win64\resources\app\"
            set "CUSTOM_THEIA_BACKEND_MAIN_PATH=!XILINX_PATH!\ide\electron-app\win64\resources\app\src-gen\backend\main.js"
            set "CUSTOM_THEIA_FRONTEND_PATH=!XILINX_PATH!\ide\electron-app\win64\resources\app\lib\index.html"
          )
        )
      )
    ) else (
      echo Warning: Patch !patch_number! ^(!patch_release!^) is not compatible with the current install ^(!XILINX_VITIS_VERSION!^)
      echo Launching Vitis server from the installs.
    )
  )
)

if not defined PATCH_INFO (
  if exist %XILINX_VITIS%\patch.properties (
    for /f "tokens=1,2 delims==" %%a in (%XILINX_VITIS%\patch.properties) do (
      set "key=%%a"
      set "value=%%b"
      if "%%a"=="patch.number" set patch_number=!value!
      if "%%a"=="patch.release" set patch_release=!value!
    )
    set PATCH_INFO=Patch !XILINX_PATH! ^(!patch_number!, !patch_release!^) Details - !patch_desc!
    echo Patch !patch_number! found at %XILINX_VITIS%, activated successfully.
  ) else (
    set PATCH_INFO=
  )
)

set PYTHONPATH=%PYTHONPATH%;%XILINX_VITIS%\cli;%XILINX_VITIS%\cli\python-packages\win64;%XILINX_VITIS%\cli\python-packages\site-packages;%XILINX_VITIS%\cli\proto;%XILINX_VITIS%\scripts\python_pkg;

@REM Env variable support to disable license check
set IDE_SKIP_SERVER_LICENSE=1
set CMAKE_OBJECT_PATH_MAX=4096

set RDI_DATADIR=%RDI_APPROOT%/data

if "!RDI_INSTALLVER!" == "aietools" (
  set RDI_SHARED_DATA=!RDI_INSTALLROOT!/../SharedData/!RDI_INSTALLVER!/data
) else (
  set RDI_SHARED_DATA=!RDI_INSTALLROOT!/SharedData/!RDI_INSTALLVER!/data
  if not exist "!RDI_SHARED_DATA!" if exist "!RDI_INSTALLROOT!/../SharedData/data" (
    set RDI_SHARED_DATA=!RDI_INSTALLROOT!/../SharedData/data
  )
)

if exist "!RDI_SHARED_DATA!" (
  set RDI_DATADIR=!RDI_SHARED_DATA!;!RDI_DATADIR!
)

if exist "!RDI_APPROOT!/data/vits" (
  set RDI_DATADIR=!RDI_APPROOT!/data/vits;!RDI_DATADIR!
)
set PATH=%RDI_APPROOT%\bin;%RDI_APPROOT%\gnu\microblaze\nt\bin;%RDI_APPROOT%\gnu\arm\nt\bin;%RDI_APPROOT%\gnu\microblaze\linux_toolchain\nt64_be\bin;%RDI_APPROOT%\gnu\microblaze\linux_toolchain\nt64_le\bin;%RDI_APPROOT%\gnu\aarch32\nt\gcc-arm-linux-gnueabi\bin;%RDI_APPROOT%\gnu\aarch32\nt\gcc-arm-none-eabi\bin;%RDI_APPROOT%\gnu\aarch64\nt\aarch64-linux\bin;%RDI_APPROOT%\gnu\aarch64\nt\aarch64-none\bin;%RDI_APPROOT%\gnu\armr5\nt\gcc-arm-none-eabi\bin;%RDI_APPROOT%\gnu\riscv\nt\riscv64-unknown-elf\bin;!PATH!
if [!INTERACTIVE!] == [true] (
   python.exe %XILINX_VITIS%/cli/vitis/_vitisshell.py
) else (
    if [!SOURCE!] == [true] (
      FOR /F "tokens=* delims=, " %%x in (%XILINX_VITIS%/cli/vitis/_predefined_classes.txt) DO (
        set list=%%x
        for %%a in (!list!) do (
          if ^'!sourceWithoutExtension!^' == %%a (
            echo Error: The file name ^'!sourceWithoutExtension!^.py^' conflicts with Vitis pre-defined module names. 
            echo Using this file name may cause unexpected behavior. Please change the file name.
            echo For full list of pre-defined module name please refer %XILINX_VITIS%/cli/vitis/_predefined_classes.txt
            exit /b 1
          )
        )
      )
      python.exe %args_for_source%
    ) else (
      if defined VITIS_IDE_USER_TOOLCHAIN ( 
        set PATH=%VITIS_IDE_USER_TOOLCHAIN%;!PATH!
      )
      if [!WORKSPACE!] == [true] (
        if "%workspaceDir%" == "" (
          echo Error: The required argument for option --workspace is missing.
          echo Please provide a valid path or refer to vitis --help for more information.
          exit /b 1
        )
        if not exist %workspaceDir%\NUL (
        mkdir %workspaceDir%
        )
        start %XILINX_VITIS%/ide/electron-app/win64/vitis-ide.exe --no-sandbox --log-level=debug !workspaceDir!    
      ) else (
        @REM Invoke Unified Vitis IDE
        start %XILINX_VITIS%/ide/electron-app/win64/vitis-ide.exe --no-sandbox --log-level=debug
      )
   )
)
goto :EOF
:HELP
   echo.
   echo Syntax: vitis [-classic ^|-w ^| -i ^| -s ^| -h ]
   echo.
   echo Options:
   echo   Launches New Vitis IDE (default option).
   echo   -classic/--classic (not supported for Vitis embedded installer)
   echo          Launches classic Vitis IDE.
   echo   -w/--workspace ^<workspace_location^>
   echo          Launches Vitis IDE with the given workspace location.
   echo              Usage: $ vitis -w ^<workspace_location^>
   echo   -i/--interactive
   echo          Launches Vitis python interactive shell.
   echo   -s/--source ^<python_script^>
   echo          Runs the given python script.
   echo              Usage: $ vitis -s ^<python_script^>
   echo   -h/--help
   echo          Display help message.


