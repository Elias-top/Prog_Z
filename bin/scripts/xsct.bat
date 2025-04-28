@echo off
setlocal
rem #
rem # COPYRIGHT NOTICE
rem # Copyright 1986-1999, 2001-2011 Xilinx, Inc. All Rights Reserved.
rem # 

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
call "%~dp0setupEnv.bat"

rem ##
rem # Launch the loader and specify the executable to launch
rem ##
rem #
rem # Loader arguments:
rem #   -exec   -- Name of executable to launch
rem ##
rem set RDI_PROG=%~n0
set RDI_NO_JRE=yes
set RDI_NEED_OLD_JRE=yes

set XILINX_SDX=

set RDI_ARGS=
  :parseArgs
    if [%1] == [] (
      goto argsParsed
    ) else (
    if [%1] == [-sdx] (
      rem # Don't pass -sdx to xsct
    ) else (
      set RDI_ARGS=%RDI_ARGS% %1
    ))
    shift
    goto parseArgs
  :argsParsed

if exist "%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%" (
    SET XILINX_VITIS=%RDI_INSTALLROOT%/Vitis/%RDI_INSTALLVER%
)else if exist "%HDI_APPROOT%" (
    SET XILINX_VITIS=%HDI_APPROOT%
)

rem # Add toolchain location to PATH
SET PATH=%RDI_APPROOT%/bin;%RDI_APPROOT%/gnu/microblaze/nt/bin;%RDI_APPROOT%/gnu/arm/nt/bin;%RDI_APPROOT%/gnu/microblaze/linux_toolchain/nt64_be/bin;%RDI_APPROOT%/gnu/microblaze/linux_toolchain/nt64_le/bin;%RDI_APPROOT%/gnu/aarch32/nt/gcc-arm-linux-gnueabi/bin;%RDI_APPROOT%/gnu/aarch32/nt/gcc-arm-none-eabi/bin;%RDI_APPROOT%/gnu/aarch64/nt/aarch64-linux/bin;%RDI_APPROOT%/gnu/aarch64/nt/aarch64-none/bin;%RDI_APPROOT%/gnu/armr5/nt/gcc-arm-none-eabi/bin;%RDI_APPROOT%/tps/win64/cmake-3.24.2/bin;%RDI_APPROOT%/gnu/riscv/nt/riscv64-unknown-elf/bin;%PATH%
call "%RDI_BINROOT%/loader.bat" -exec rdi_xsct %RDI_ARGS%
endlocal
