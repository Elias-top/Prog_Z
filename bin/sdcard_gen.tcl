#!/usr/bin/tclsh
#  File: sdxsd.tcl
###############################################################################
#  (c) Copyright 2017, 2022 Xilinx, Inc. All rights reserved.
# 
#  This file contains confidential and proprietary information 
#  of Xilinx, Inc. and is protected under U.S. and 
#  international copyright and other intellectual property 
#  laws. 
# 
#  DISCLAIMER 
#  This disclaimer is not a license and does not grant any 
#  rights to the materials distributed herewith. Except as 
#  otherwise provided in a valid license issued to you by 
#  Xilinx, and to the maximum extent permitted by applicable 
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND 
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES 
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING 
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON- 
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
#  (2) Xilinx shall not be liable (whether in contract or tort, 
#  including negligence, or under any other theory of 
#  liability) for any loss or damage of any kind or nature 
#  related to, arising under or in connection with these 
#  materials, including for any direct, or any indirect, 
#  special, incidental, or consequential loss or damage 
#  (including loss of data, profits, goodwill, or any type of 
#  loss or damage suffered as a result of any action brought 
#  by a third party) even if such damage or loss was 
#  reasonably foreseeable or Xilinx had been advised of the 
#  possibility of the same. 
# 
#  CRITICAL APPLICATIONS 
#  Xilinx products are not designed or intended to be fail- 
#  safe, or for use in any application requiring fail-safe 
#  performance, such as life-support or safety devices or 
#  systems, Class III medical devices, nuclear facilities, 
#  applications related to the deployment of airbags, or any 
#  other applications that could lead to death, personal 
#  injury, or severe property or environmental damage 
#  (individually and collectively, "Critical 
#  Applications"). Customer assumes the sole risk and 
#  liability of any use of Xilinx products in Critical 
#  Applications, subject only to applicable laws and 
#  regulations governing limitations on product liability. 
# 
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS 
#  PART OF THIS FILE AT ALL TIMES. 
###############################################################################

# add SDSoC packages to auto_path
set script_path [file normalize [info script]]
set xdpath [file normalize [file join [file dirname ${script_path}] ..]]
set vimage_packages [file join $xdpath scripts vimage]
lappend auto_path $vimage_packages

# load the linking package
package require vimage::env
package require vimage::utils
package require vimage::file
package require vimage::pfmx
package require vimage::sdcard
package require vimage::emu

###############################################################################
# globals
###############################################################################

set sdx_keep              0
set sdx_bootgen           0

set sdx_input_dir         ""
set sdx_output_dir        ""

set sdx_platform_path     ""
set sdx_platform          ""
set sdx_sys_config        ""
set sdx_image_name        ""
set sdx_cfg_file          "zynq_ultrascale.cfg"
set sdx_target_os         "linux"
set sdx_processor_type    "cortex-a53"
set sdx_user_sd_data      ""
set sdx_bitstream         ""
set sdx_bif_template      ""
set sdx_elf               ""

set sdx_emu_behav_dir     ""
set sdx_emu_output_dir    ""

###############################################################################
# Process command line options
###############################################################################

proc printUsage {ec} {
  puts "Usage: sdcard_gen --xpfm xpfm_file --sys_config config_name"
  puts "                  \[--bitstream bit_file\] \[--no_bitstream\]"
  puts "                  \[--bif bif_template\] \[--image image_name\]"
  puts "                  \[--atf elf_file\] \[--bl31 elf_file\]"
  puts "                  \[--dtb dtb_file\] \[--fsbl fsbl_file\]"
  puts "                  \[--pmu pmu_file\] \[--uboot uboot_file\]"
  puts "                  \[--input input_dir\] \[--output output_dir]"
  puts "                  \[--sd_file data_file\]* \[--sd_dir data_dir\]"
  puts "                  \[--verbose\] \[--keep\] \[--help\]"
  puts ""
  puts "where"
  puts "--xpfm xpfm_file         specify the path to a platform .xpfm file"
  puts "--sys_config config_name specify the .spfm system configuration"
  puts "--image image_name       specify the .spfm image if not default"
  puts "--bif bif_template       specify the .bif template file, overriding"
  puts "                         the platform defined file"
  puts "--bitstream bit_file     specify the path to a .bit file,"
  puts "                         otherwise a BOOT.BIN is not created"
  puts "--no_bitstream           run bootgen in the absence of a bitstream"
  puts "--atf elf_file           specify path to atf elf file for .bif template"
  puts "                         substitution by type name"
  puts "--bl31 elf_file          specify path to bl31 elf file for .bif template"
  puts "                         substitution by type name"
  puts "--dtb dtb_file           specify path to .dtb file for .bif template"
  puts "                         substitution by type name"
  puts "--fsbl fsbl_file         specify path to fsbl file for .bif template"
  puts "                         substitution by type name"
  puts "--pmu elf_file           specify path to pmu elf file for .bif template"
  puts "                         substitution by type name"
  puts "--uboot uboot_file       specify path to uboot file for .bif template"
  puts "                         substitution by type name"
  puts "--input input_dir        folder containing .xclbin, .exe and BOOT.BIN"
  puts "                         (if not specified, look in current directory)"
  puts "--output output_dir      folder to generate sd_card image in"
  puts "                         (if not specified, use current directory)"
  puts "--sd_file data_file      copy file to the SD card image"
  puts "                         (optional, multiple sd_file options allowed)"
  puts "--sd_dir  data_dir       copy folder contents to SD card image"
  puts "                         (optional, at most one sd_dir option allowed)"
  puts "--verbose                print additional information to stdout"
  puts "--emu_output emu_dir     folder to generate emulation output files;"
  puts "                         if used, also specify --emu_behav"
  puts "                         (typically /path/to/_sds/emulation)"
  puts "--emu_behav  behav_dir   folder with emulation behavioral simulation files;"
  puts "                         if used, also specify --emu_output"
  puts "                         (typically /path/to/_sds/p0/vpl/behav/xsim)"
  puts "--keep                   keep temporary files, for example boot.bif"
  puts "--help                   print usage information"
  puts ""
  puts "To run the generated SD card for OCL unified platforms, copy the"
  puts "files in the sd_card folder to an SD card, boot the board and run"
  puts "the following commands:"
  puts "  cd /mnt"
  puts "  export XILINX_OPENCL=\$PWD/embedded_root"
  puts "  ./myapp.exe binary_container_1.xclbin"
  exit $ec
}

proc parseCommandLineOptions {} {
  global argc argv
  global sdx_keep
  global sdx_input_dir
  global sdx_output_dir
  global sdx_sys_config
  global sdx_image_name
  global sdx_bitstream
  global sdx_bif_template
  global sdx_bootgen
  global sdx_platform_path
  global sdx_platform
  global sdx_user_sd_data
  global sdx_elf

  global sdx_emu_behav_dir
  global sdx_emu_output_dir

  set xpfmCount      0
  set sysConfigCount 0
  set invalidOptions 0
  set verboseOption  0

  for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    switch -nocase -- $arg {
      -xpfm  -
      --xpfm {
        incr i
        set xpfmFile [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $xpfmFile]} {
          puts "platform .xfpm does not exist: $xpfmFile"
          exit 1
        }
        set sdx_platform_path [file dirname $xpfmFile]
        set sdx_platform [file rootname [file tail $xpfmFile]]
        incr xpfmCount
      }
      -sys_config  -
      --sys_config {
        incr i
        set sdx_sys_config [lindex $argv $i]
        incr sysConfigCount
      }
      -image  -
      --image {
        incr i
        set sdx_image_name [lindex $argv $i]
      }
      -bif  -
      --bif {
        incr i
        set bifFile [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $bifFile]} {
          puts "bif file template does not exist: $bifFile"
          exit 1
        }
        set sdx_bif_template $bifFile
      }
      -bitstream  -
      --bitstream {
        incr i
        set bitFile [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $bitFile]} {
          puts "bitstream does not exist: $bitFile"
          exit 1
        }
        set sdx_bitstream $bitFile
        ::vimage::sdcard::setUserBifTypeFileDict "bitstream" ${bitFile}
      }
      -no_bitstream  -
      --no_bitstream {
        set sdx_bootgen 1
      }
      -atf   -
      --atf  -
      -bl31  -
      --bl31 -
      -dtb   -
      --dtb  -
      -fsbl  -
      --fsbl -
      -pmu   -
      --pmu  -
      -uboot -
      --uboot {
        set bifTypeName [string trim $arg "-"]
        incr i
        set bifTypeFile [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $bifTypeFile]} {
          puts "BIF type \"${bifTypeName}\" does not exist: $bifTypeFile"
          exit 1
        }
        ::vimage::sdcard::setUserBifTypeFileDict $bifTypeName ${bifTypeFile}
      }
      -elf  -
      --elf {
        incr i
        set tokList [split [lindex $argv $i] ","]
        set elfFile [file normalize [file join [pwd] [lindex $tokList 0]]]
        if {! [file exists $elfFile]} {
          puts "ELF does not exist: $elfFile"
          exit 1
        }
        if {[llength $tokList] > 1} {
          set elfConfig [lindex $tokList 1]
          ::vimage::sdcard::setElfFileDict ${elfConfig} ${elfFile}
        } else {
          set sdx_elf $elfFile
        }
      }
      -emu_behav -
      --emu_behav  {
        incr i
        set sdx_emu_behav_dir [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sdx_emu_behav_dir]} {
          puts "emulation behavioral simulation directory does not exist: $sdx_emu_behav_dir"
          exit 1
        }
      }
      -emu_output -
      --emu_output  {
        incr i
        set sdx_emu_output_dir [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sdx_emu_output_dir]} {
          puts "emulation output directory does not exist: $sdx_emu_output_dir"
          exit 1
        }
      }
      -input -
      --input  {
        incr i
        set sdx_input_dir [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sdx_input_dir]} {
          puts "input directory does not exist: $sdx_input_dir"
          exit 1
        }
      }
      -output -
      --output  {
        incr i
        set sdx_output_dir [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sdx_output_dir]} {
          puts "output directory does not exist: $sdx_output_dir"
          exit 1
        }
      }
      -sd_dir -
      --sd_dir {
        incr i
        set sd_dir [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sd_dir]} {
          puts "SD data directory does not exist: $sd_dir"
          exit 1
        }
        set sdx_user_sd_data ${sd_dir}
      }
      -sd_file -
      --sd_file {
        incr i
        set sd_file [file normalize [file join [pwd] [lindex $argv $i]]]
        if {! [file exists $sd_file]} {
          puts "SD data file does not exist: $sd_file"
          exit 1
        }
        ::vimage::sdcard::setUserImageDataFiles ${sd_file}
      }
      -v        -
      -verbose  -
      --verbose {
        set verboseOption 1
      }
      -keep   -
      --keep  {
        set sdx_keep 1
      }
      -h      -
      -help   -
      --help  {
        printUsage 0
      }
      default {
        puts "Unrecognized command line option $arg"
        exit 1
      }
    }
  }

  if {$xpfmCount < 1} {
    set invalidOptions 1
    puts "No .xpfm file specified"
  }
  if {$sysConfigCount < 1} {
    # try to find the default system configuration
    if {$xpfmCount} {
      set defaultConfigurationName [::vimage::pfmx::get_configuration_default ${sdx_platform_path}]
      if {[string length $defaultConfigurationName] > 0} {
        set sdx_sys_config $defaultConfigurationName
        incr sysConfigCount
        if {$verboseOption} {
          puts "Using default system configuration : $defaultConfigurationName"
        }
      } else {
        set invalidOptions 1
        puts "No software platform system configuration found or specified"
      }
    } else {
      set invalidOptions 1
      puts "No software platform system configuration found, platform not specified"
    }
  }
  if {[string length $sdx_input_dir] < 1} {
    if {$verboseOption} {
      puts "No input directory specified, searching current directory for SD card files"
    }
    set sdx_input_dir [pwd]
  }
  if {[string length $sdx_output_dir] < 1} {
    if {$verboseOption} {
      puts "No output directory specified, creating sd_card folder in current directory"
    }
    set sdx_output_dir [pwd]
  }
  if {[string length $sdx_emu_output_dir] > 0 && [string length $sdx_emu_behav_dir] < 1} {
    set invalidOptions 1
    puts "The -emu_output option was specified, but -emu_behav was not (if used, both are required)"
  }
  if {[string length $sdx_emu_output_dir] < 1 && [string length $sdx_emu_behav_dir] > 0} {
    set invalidOptions 1
    puts "The -emu_behav option was specified, but -emu_output was not (if used, both are required)"
  }
  if {$invalidOptions} {
    puts "Invalid command line"
    exit 1
  }
}

proc copySdFileByExtension { outputDir inputDir filePattern } {
  set sdFileList [::vimage::file::getDirectoryFilesByPatternLocal ${inputDir} ${filePattern}]
  foreach sdFile $sdFileList {
    ::vimage::file::copyFileForce ${sdFile} ${outputDir}
  }
} 

###############################################################################
# main
###############################################################################

proc runMain {} {
  global sdx_keep
  global sdx_input_dir
  global sdx_output_dir
  global sdx_platform_path
  global sdx_platform
  global sdx_sys_config
  global sdx_image_name
  global sdx_cfg_file
  global sdx_bif_template
  global sdx_bitstream
  global sdx_bootgen
  global sdx_target_os
  global sdx_processor_type
  global sdx_user_sd_data
  global sdx_elf

  global sdx_emu_behav_dir
  global sdx_emu_output_dir

  # temporary work directory
  set run_dir [pwd]
  set temp_dir [file join $run_dir .Xil]
  file mkdir $temp_dir
  ::vimage::pfmx::set_temp_dir $temp_dir

  # disable SD card package functions related to bootgen,
  # if we won't be creating the BOOT.BIN file
  if {[string length ${sdx_bitstream}] < 1} {
    ::vimage::sdcard::setCreateBootBin 0
    set sdcard_bit ""
    if {$sdx_bootgen} {
      # force BOOT.BIN generation in the absence of bitstream
      ::vimage::sdcard::setCreateBootBin 1
      set sdcard_bit [::vimage::sdcard::getDummyBitFile]
    }
  } else {
    ::vimage::sdcard::setCreateBootBin 1
    set sdcard_bit ${sdx_bitstream}
    puts "creating BOOT.BIN using ${sdcard_bit}"
  }

  # override the .bif template, if specified
  if {[string length ${sdx_bif_template}] > 1} {
    ::vimage::sdcard::setUserBifTemplateFile ${sdx_bif_template}
  }

  # set cpu information for the default domain, which could be MicroBlaze and
  # not an ARM processor
  set cputype [::vimage::pfmx::get_configuration_proc_default_cpuType $sdx_platform_path $sdx_sys_config]
  set use_cputype $cputype

  if {[string match -nocase "microblaze*" $cputype]} {
    # if this is SDK creating an SD card for Zynq or MPSoC, where the
    # target CPU is MicroBlaze with the ELF loaded into BRAM, the
    # bootgen -arch flag should be based on the device family, not the
    # CPU. Adjust the -arch option to match the device family.

    # set primary cputype for the device, for example there may be domains for
    # the ARM processor and MicroBlaze, in which case the primary for the
    # for the device might be cortex-a9, for example
    set primary_cputype [::vimage::pfmx::get_configuration_proc_primary_cpuType $sdx_platform_path $sdx_sys_config]
    set use_cputype $primary_cputype
  }

  # set cpu information
  if {[string length $use_cputype] > 0 && [string equal $use_cputype "cortex-a9"]} {
    set sdx_cfg_file          "zynq.cfg"
    set sdx_processor_type    "cortex-a9"
  }
  if {[string length $use_cputype] > 0 && [string equal $use_cputype "cortex-a53"]} {
    set sdx_cfg_file          "zynq_ultrascale.cfg"
    set sdx_processor_type    "cortex-a53"
  }
  if {[string length $use_cputype] > 0 && [string equal $use_cputype "cortex-a72"]} {
    set sdx_cfg_file          "everest.cfg"
    set sdx_processor_type    "cortex-a72"
  }

  # by default don't keep the .bif file and don't create bitstream .bin file
  ::vimage::sdcard::setKeepTempFiles 0
  ::vimage::sdcard::setCreateBitBin 0
  if {$sdx_keep} {
    ::vimage::sdcard::setKeepTempFiles 1
  }

  # initialize SD card writer data
  set cfg_file [file join [::vimage::env::get_install_root] data toolchain $sdx_cfg_file]
  if {[string length $sdx_image_name] > 0} {
      ::vimage::sdcard::setSdCardImageName $sdx_image_name
  }
  if { [catch { \
      ::vimage::sdcard::initializeSdCardImageWriter \
      $sdx_platform_path \
      $sdx_platform \
      $sdx_sys_config \
      $cfg_file \
      $sdx_target_os \
      $sdx_processor_type \
      $sdx_user_sd_data \
      } cmsg] } {
    puts "Error intializing SD boot data : $cmsg"
    exit 1
  }

  # emulation output is mutually exclusive with SD card output
  # - if the -elf option is not used, use -sd_file
  # - the -emu_output and -emu_behav options are required
  if {[string length ${sdx_emu_behav_dir}] > 0} {
    if { [catch { \
            ::vimage::emu::exportSimulationFiles \
              ${sdx_emu_output_dir} \
              ${sdx_elf} \
              ${sdx_emu_behav_dir} \
      } cmsg] } {
      puts "Error writing emulation data : $cmsg"
      exit 1
    }
    return
  }

  # write SD card image (.bit and .elf are dummy args here)
  # copy the following files to the output directory:
  #   - platform image data
  #   - user image data (optional)
  #   - BOOT.BIN created by xocc -l
  #   - *.exe
  #   - *.xclbin
  set sdcard_dir [file join ${sdx_output_dir} sd_card]
  set sdcard_temp_dir [file join ${sdx_output_dir} sd_card_temp]
  set sdcard_elf ""
  if {[string length ${sdx_elf}] > 0} {
    set sdcard_elf ${sdx_elf}
  }
  if { [catch { \
          ::vimage::sdcard::writeSdCardImage \
            ${sdcard_dir} \
            ${sdcard_temp_dir} \
            ${sdcard_bit} \
            ${sdcard_elf} \
    } cmsg] } {
    puts "Error writing SD card data : $cmsg"
    exit 1
  }
  file delete -force ${sdcard_temp_dir}

  if {! [::vimage::sdcard::getCreateBootBin] } {
    copySdFileByExtension ${sdcard_dir} ${sdx_input_dir} "BOOT.BIN"
  }
  copySdFileByExtension ${sdcard_dir} ${sdx_input_dir} "*.exe"
  copySdFileByExtension ${sdcard_dir} ${sdx_input_dir} "*.xclbin"

  # to run the SD card for OCL unified platforms:
  #   cd /mnt
  #   export XILINX_OPENCL=$PWD/embedded_root
  #   ./myapp.exe whatever.xclbin
}

###############################################################################
# generate bd.tcl
###############################################################################

parseCommandLineOptions
runMain
