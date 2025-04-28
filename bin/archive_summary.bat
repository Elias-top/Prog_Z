@echo off
setlocal

rem # COPYRIGHT NOTICE
rem # Copyright 1986-1999, 2001-2020 Xilinx, Inc. All Rights Reserved.
rem # 

set _RDI_CWD=%cd%
pushd "%~dp0"
set _RDI_BINROOT=%cd%
cd /d "%_RDI_CWD%"

rem ##
rem # Setup default environmental variables
rem ##
rem # RDI_BINROOT - Directory *this* script exists in
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_BINROOT=/usr/Test/Install/bin
rem #
rem # RDI_APPROOT - One directory above RDI_BINROOT
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_APPROOT=/usr/Test/Install
rem #
rem # RDI_BASEROOT - One directory above RDI_APPROOT
rem #  E.x. 
rem #    /usr/Test/Install/bin/example
rem #    RDI_BINROOT=/usr/Test
rem ##
set RDI_PROG=%~n0
call "%_RDI_BINROOT%/setupEnv.bat"

set RDI_PLATFORM=win64
set RDI_JAVA_VERSION=21.0.1_12
set RDI_JAVAROOT=%RDI_APPROOT%/tps/%RDI_PLATFORM%/jre%RDI_JAVA_VERSION%

set RDI_EXECCLASS=com.xilinx.vitis.archivesummary.ArchiveSummary
set RDI_JAVAARGS=-Xms128m -Xmx512m -Xss5m

set CLASSES_DIR=%RDI_APPROOT%/lib/classes
for %%f in (%CLASSES_DIR%\com.google.gson_*.jar) do (
  set GSON_JAR=%%f
)
set RDI_CLASSPATH=%CLASSES_DIR%/ArchiveSummary.jar;%CLASSES_DIR%/commons-io-2.6.jar;%CLASSES_DIR%/picocli-4.1.2.jar;%CLASSES_DIR%/FrankFrameworks.jar;%CLASSES_DIR%/Dispatch.jar;%CLASSES_DIR%/protobuf-java-3.21.12.jar;%CLASSES_DIR%/protobuf-java-util-3.21.12.jar;%GSON_JAR%

set RDI_JAVAPROG=%RDI_JAVAROOT%/bin/java.exe %RDI_JAVAARGS% -classpath %RDI_CLASSPATH% %RDI_EXECCLASS% %*
call %RDI_JAVAPROG%
rem popd
rem exit /b %errorlevel%

