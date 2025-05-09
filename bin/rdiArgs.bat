rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
rem #

if not defined RDI_ARGS_FUNCTION (
  goto SETUP
) else (
  goto %RDI_ARGS_FUNCTION%
)

:SETUP
  rem #
  rem # Platform options
  rem #
  set RDI_PLATFORM=win64
  set RDI_ARGS=
  if defined RDI_BYPASS_ARGS (
      set RDI_ARGS=%*
      set RDI_PROG=%RDI_BYPASS_ARGS%
      set RDI_BYPASS_ARGS=
      goto argsParsed
  )
  :parseArgs
    if [%1] == [] (
      goto argsParsed
    ) else (
    if [%1] == [-m32] (
      echo WARNING: Unsupported option: -m32.
    ) else (
    if [%1] == [-m64] (
      echo.
    ) else (
    if [%1] == [-exec] (
      set RDI_PROG=%2
      shift
    ) else (
    if [%1] == [-mode] (
      set RDI_ARGS=%RDI_ARGS% %1
      if [%2] == [batch] (
        set RDI_BATCH_MODE=True
        set RDI_ARGS=!RDI_ARGS! %2
        shift
      )
    ) else (
    if [%1] == [-version] (
      if [%_RDI_NEEDS_VERSION%] == [True] (
        set RDI_ARGS_FUNCTION=RDI_EXEC_PRODVERSION
      ) else (
        if [%RDI_PROG%] == [vivado] (
          set RDI_INVOKE_VERSION_ONLY=1
        ) else (
        set RDI_ARGS=%RDI_ARGS% %1
        )
      )
    ) else (
      set RDI_ARGS=%RDI_ARGS% %1
    ))))))
    shift
    goto parseArgs
  :argsParsed

  if [%RDI_VERBOSE%] == [] (
    set RDI_VERBOSE=False
  )

  rem # Default don't check TclDebug
  if [%XIL_CHECK_TCL_DEBUG%] == [] (
    set XIL_CHECK_TCL_DEBUG=False
  )

  set TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD=4294967296

  set RDI_DATADIR=%RDI_APPROOT%/data
  set RDI_SHARED_DATA=%RDI_INSTALLROOT%/SharedData

  if "!RDI_INSTALLVER!" == "aietools" (
    set RDI_SHARED_DATA=!RDI_INSTALLROOT!/../SharedData/!RDI_INSTALLVER!/data
    if not exist "!RDI_SHARED_DATA!" (
      echo
      rem #echo "ERROR: Sharedata path not found for !RDI_INSTALLVER!"
      rem #echo "ERROR: Path Searched: !RDI_SHARED_DATA!"
      echo
    )
  ) else (
    set RDI_SHARED_DATA=!RDI_INSTALLROOT!/SharedData/!RDI_INSTALLVER!/data
    if exist "!RDI_SHARED_DATA!" (
      set RDI_SHARED_DATA=!RDI_SHARED_DATA!
    ) else (
      if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVER!/SharedData/data" (
        set RDI_SHARED_DATA=!RDI_INSTALLROOT!/!RDI_INSTALLVER!/SharedData/data
      ) else (
      if exist "!RDI_INSTALLROOT!/../SharedData/data" (
        set RDI_SHARED_DATA=!RDI_INSTALLROOT!/../SharedData/data
      ) else (
        rem new install-tree structure.
        if exist "!RDI_DATADIR!/../../SharedData/data" (
          set RDI_SHARED_DATA=!RDI_DATADIR!/../../SharedData/data
        )
      )
    )
  )
  )

  if exist "!RDI_SHARED_DATA!" (
    set RDI_DATADIR=!RDI_SHARED_DATA!;!RDI_DATADIR!
  )
  
  set TEMP_PATCHROOT=!RDI_PATCHROOT!
  :TOKEN_LOOP_DATADIR
  for /F "delims=;" %%d in ("!TEMP_PATCHROOT!") do (
    if exist "%%d/data" (
      set RDI_DATADIR=%%d/data;!RDI_DATADIR!
    )
  )
  :CHARPOP_DATADIR
  set CHARPOP=!TEMP_PATCHROOT:~0,1!
  set TEMP_PATCHROOT=!TEMP_PATCHROOT:~1!
  if "!TEMP_PATCHROOT!" EQU "" goto END_TOKEN_LOOP_DATADIR
  if "!CHARPOP!" NEQ ";" goto CHARPOP_DATADIR
  goto TOKEN_LOOP_DATADIR
  :END_TOKEN_LOOP_DATADIR

  set RDI_JAVA_VERSION=21.0.1_12
  if defined RDI_USE_JDK21 (
    set RDI_JAVAFXROOT=%RDI_APPROOT%/tps/%RDI_PLATFORM%/javafx-sdk-21.0.1
  )
  if defined RDI_USE_JDK11 (
    set RDI_JAVA_VERSION=11.0.16_1
    set RDI_JAVAFXROOT=%RDI_APPROOT%/tps/%RDI_PLATFORM%/javafx-sdk-11.0.2
  )
  set RDI_JAVACEFROOT=%RDI_APPROOT%/tps/%RDI_PLATFORM%/java-cef-95.0.4638.69
  if defined RDI_NEED_OLD_JRE (
    set RDI_JAVA_VERSION=
    set RDI_NEED_OLD_JRE=
  )
  set RDI_JAVAROOT=%RDI_APPROOT%/tps/%RDI_PLATFORM%/jre%RDI_JAVA_VERSION%
  
  rem #Locate RDI_JAVAROOT in patch areas.
  set TEMP_PATCHROOT=!RDI_PATCHROOT!
  :TOKEN_LOOP_PROG
  for /F "delims=;" %%d in ("!TEMP_PATCHROOT!") do (
    if exist "%%d/tps/%RDI_PLATFORM%/jre%RDI_JAVA_VERSION%" (
      set RDI_JAVAROOT=%%d/tps/%RDI_PLATFORM%/jre%RDI_JAVA_VERSION%
    )
  )
  :CHARPOP_PROG
  set CHARPOP=!TEMP_PATCHROOT:~0,1!
  set TEMP_PATCHROOT=!TEMP_PATCHROOT:~1!
  if "!TEMP_PATCHROOT!" EQU "" goto END_TOKEN_LOOP_PROG
  if "!CHARPOP!" NEQ ";" goto CHARPOP_PROG
  goto TOKEN_LOOP_PROG
  :END_TOKEN_LOOP_PROG
  rem # Silly syntax requires something after a label

  rem #
  rem # Strip /planAhead off %RDI_APPROOT% to discovery the
  rem # common ISE installation.
  rem #
  rem # For separated vivado installs ISE is located under %RDI_APPROOT%/ids_lite
  rem #
  if not [%XIL_PA_NO_XILINX_OVERRIDE%] == [1] (
    if not [%XIL_PA_NO_DEFAULT_OVERRIDE%] == [1] (
      set XILINX=
    )
    if exist "%RDI_APPROOT%/ids_lite/ISE" (
      set XILINX=%RDI_APPROOT%/ids_lite/ISE
    ) else (
      if exist "%RDI_BASEROOT%/ISE" (
        set XILINX=%RDI_BASEROOT%/ISE
      )
    )
  )


  set RDI_SETUP_ENV_FUNCTION=BASENAME
  call "%RDI_BINROOT%/setupEnv.bat" "%RDI_APPROOT%" RDI_INSTALLVERSION
  set RDI_SETUP_ENV_FUNCTION=DIRNAME
  call "%RDI_BINROOT%/setupEnv.bat" "%RDI_APPROOT%" RDI_INSTALLROOT
  set RDI_SETUP_ENV_FUNCTION=DIRNAME
  call "%RDI_BINROOT%/setupEnv.bat" "!RDI_INSTALLROOT!" RDI_INSTALLROOT

  if not [%XIL_PA_NO_XILINX_SDK_OVERRIDE%] == [1] (
    if exist "!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVER!" (
      set XILINX_SDK=!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVER!
    ) else (
        if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis" (
          set XILINX_SDK=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis
        ) else (
            if exist "!RDI_INSTALLROOT!/SDK/!RDI_INSTALLVERSION!" (
              set XILINX_SDK=!RDI_INSTALLROOT!/SDK/!RDI_INSTALLVERSION!
            ) else (
                if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/SDK" (
                  set XILINX_SDK=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/SDK
                ) else (
                  if exist "!RDI_BASEROOT!/SDK" (
                    set XILINX_SDK=!RDI_BASEROOT!/SDK
          )
        )
      )
    )
  )
    if "!XILINX_SDK!" NEQ "" (
      if not defined XILINX_VITIS (
        set XILINX_VITIS=!XILINX_SDK!
      )
    )
  )


  set TEMP_DEPENDENCY=!RDI_DEPENDENCY!
  :TOKEN_LOOP_DEPENDENCY
  for /F "delims=;" %%a in ("!TEMP_DEPENDENCY!") do (
    if [%%a] == [VITIS_HLS_SETUP] if not [!RDI_PROG!] == [hls_tee] (
      if not defined XILINX_VITIS (
        if exist "!HDI_APPROOT!/bin/vitis-run" (
          set XILINX_VITIS=!HDI_APPROOT!
        ) else if exist "!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVERSION!/bin" (
          set XILINX_VITIS=!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVERSION!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis/bin" (
          set XILINX_VITIS=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis
        ) else if exist "!RDI_BASEROOT!/Vitis/bin" (
          set XILINX_VITIS=!RDI_BASEROOT!/Vitis
        ) else if exist "!RDI_APPPARENT!/Vitis/bin" (
          set XILINX_VITIS=!RDI_APPPARENT!/Vitis
        ) else (
          echo WARNING: Default location for XILINX_VITIS not found
        )
      )
      if not defined XILINX_VCXX (
        if exist "!HDI_APPROOT!/vcxx/bin" (
          set XILINX_VCXX=!HDI_APPROOT!/vcxx
        ) else if exist "!XILINX_VITIS!/vcxx/bin" (
          set XILINX_VCXX=!XILINX_VITIS!/vcxx
        )
      )
      if not defined XILINX_VIVADO (
        if exist "!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!" (
          set XILINX_VIVADO=!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado" (
          set XILINX_VIVADO=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado
        ) else if exist "!RDI_BASEROOT!/Vivado/bin/vivado.bat" (
          set XILINX_VIVADO=!RDI_BASEROOT!/Vivado
        ) else (
          echo WARNING: Default location for XILINX_VIVADO not found
        )
      )
      if defined XILINX_VIVADO (
        if not exist "!XILINX_VIVADO!" (
          echo WARNING: XILINX_VIVADO location does not exist: !XILINX_VIVADO!
        ) else if [%RDI_VERBOSE%] == [True] ( 
          echo INFO: using XILINX_VIVADO !XILINX_VIVADO! 
        )
        rem Put XILINX_VIVADO at end of path
        set PATH=!PATH!;!XILINX_VIVADO!/bin
        set RDI_DATADIR=!XILINX_VIVADO!/data;!RDI_DATADIR!
      )
    )
    if [%%a] == [XILINX_VIVADO] (
      if not defined XILINX_VIVADO (
        if exist "!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!" (
          set XILINX_VIVADO=!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!
          set PATH=!XILINX_VIVADO!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado" (
          set XILINX_VIVADO=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado
          set PATH=!XILINX_VIVADO!/bin;!PATH!
        ) else if exist "!RDI_BASEROOT!/Vivado/bin/vivado.bat" (
          set XILINX_VIVADO=!RDI_BASEROOT!/Vivado
          set PATH=!XILINX_VIVADO!/bin;!PATH!
        ) else (
          echo WARNING: Default location for XILINX_VIVADO not found
        )
      )
    )
    if [%%a] == [XILINX_HLS] (
      if not defined XILINX_HLS (
        if exist "!XILINX_VITIS!/data/hls" (
          set XILINX_HLS=!XILINX_VITIS!
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVERSION!/data/hls" (
          set XILINX_HLS=!RDI_INSTALLROOT!/Vitis/!RDI_INSTALLVERSION!
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis/data/hls" (
          set XILINX_HLS=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_BASEROOT!/Vitis/data/hls" (
          set XILINX_HLS=!RDI_BASEROOT!/Vitis
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/Vitis_HLS/!RDI_INSTALLVERSION!/data/hls" (
          set XILINX_HLS=!RDI_INSTALLROOT!/Vitis_HLS/!RDI_INSTALLVERSION!
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis_HLS/data/hls" (
          set XILINX_HLS=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis_HLS
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else if exist "!RDI_BASEROOT!/Vitis_HLS/data/hls" (
          set XILINX_HLS=!RDI_BASEROOT!/Vitis_HLS
          set PATH=!XILINX_HLS!/bin;!PATH!
        ) else (
          echo WARNING: Default location for XILINX_HLS not found
        )
        rem Add vitis_hls location to the PATH
        if exist "!RDI_INSTALLROOT!/Vitis_HLS/!RDI_INSTALLVERSION!/bin/vitis_hls" (
          set PATH=!RDI_INSTALLROOT!/Vitis_HLS/!RDI_INSTALLVERSION!/bin;!PATH!
        ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis_HLS/bin/vitis_hls" (
          set PATH=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vitis_HLS/bin;!PATH!
        ) else if exist "!RDI_BASEROOT!/Vitis_HLS/bin/vitis_hls" (
          set PATH=!RDI_BASEROOT!/Vitis_HLS/bin;!PATH!
        )
      )
    )
  )
  :CHARPOP_DEPENDENCY
  set CHARPOP=!TEMP_DEPENDENCY:~0,1!
  set TEMP_DEPENDENCY=!TEMP_DEPENDENCY:~1!
  if "!TEMP_DEPENDENCY!" EQU "" goto END_TOKEN_LOOP_DEPENDENCY
  if "!CHARPOP!" NEQ ";" goto CHARPOP_DEPENDENCY
  goto TOKEN_LOOP_DEPENDENCY
  :END_TOKEN_LOOP_DEPENDENCY
  rem # Silly syntax requires something after a label
  set RDI_DEPENDENCY=


  if not defined XIL_TPS_ROOT (
    if exist "!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!/tps/%RDI_PLATFORM%" (
      set RDI_TPS_ROOT=!RDI_INSTALLROOT!/Vivado/!RDI_INSTALLVERSION!/tps/%RDI_PLATFORM%
    ) else if exist "!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado/tps/%RDI_PLATFORM%" (
        set RDI_TPS_ROOT=!RDI_INSTALLROOT!/!RDI_INSTALLVERSION!/Vivado/tps/%RDI_PLATFORM%
    )
  ) else (
    set RDI_TPS_ROOT=%XIL_TPS_ROOT%
  )


  if exist "%RDI_BASEROOT%/common" (
      set XILINX_COMMON_TOOLS=%RDI_BASEROOT%/common
  )
  if not defined RDI_ARGS_FUNCTION (
    set RDI_ARGS_FUNCTION=RDI_EXEC_DEFAULT
  )

  goto :EOF

:RDI_EXEC_DEFAULT
  "%RDI_PROG%" %RDI_ARGS%
  goto :EOF

:RDI_EXEC_JAVA
  set TEMP_APPROOT=!RDI_APPROOT!
  if not defined RDI_EXECCLASS (
    set RDI_EXECCLASS="ui/PlanAhead"
  )
  if not defined RDI_JAVAARGS (
    set RDI_JAVAARGS=-Dsun.java2d.pmoffscreen=false -Xms128m -Xmx3072m -Xss5m
  )
  :TOKEN_LOOP_CLASSPATH
  for /F "delims=;" %%d in ("!TEMP_APPROOT!") do (
    if exist "%%d/lib/classes" (
      if not defined RDI_CLASSPATH (
        set RDI_CLASSPATH=%%d/lib/classes/*
      ) else (
        set RDI_CLASSPATH=!RDI_CLASSPATH!;%%d/lib/classes/*
      )
      set WINDOWS_JAR_DIR=%%d/lib/classes/windows
      if exist !WINDOWS_JAR_DIR! (
        set RDI_CLASSPATH=!RDI_CLASSPATH!;!WINDOWS_JAR_DIR!/*
      )
    )
  )
  :CHARPOP_CLASSPATH
  set CHARPOP=!TEMP_APPROOT:~0,1!
  set TEMP_APPROOT=!TEMP_APPROOT:~1!
  if "!TEMP_APPROOT!" EQU "" goto END_TOKEN_LOOP_CLASSPATH
  if "!CHARPOP!" NEQ ";" goto CHARPOP_CLASSPATH
  goto TOKEN_LOOP_CLASSPATH
  :END_TOKEN_LOOP_CLASSPATH
  rem # Silly syntax requires something after a label

  set RDI_JAVAPROG="%RDI_JAVAROOT%/bin/java" %RDI_JAVAARGS% -classpath "%RDI_CLASSPATH%;" %RDI_EXECCLASS% %RDI_ARGS%
  if [%RDI_VERBOSE%] == [True] (
    echo %RDI_JAVAPROG%
  )
  set RDI_START_FROM_JAVA=True
  %RDI_JAVAPROG%
  goto :EOF

:RDI_EXEC_VBS
  wscript.exe %RDI_VBSLAUNCH% %RDI_PROG% %RDI_ARGS%
  goto :EOF
