#!/usr/bin/tclsh
#  File: cf_xsd.tcl
###############################################################################
#  (c) Copyright 2013 Xilinx, Inc. All rights reserved.
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

# ============================================================================
#
# IPI Flow Script
# ---------------
#
# This script takes a Xidane System Description and runs several XSL
# transformations to take generate an IPI BD Tcl file.
#
#   Xidane        Merge
#   System   -> Repository -+--> BD Tcl
# Description    Defaults
#
# Input:  XD_DESIGN_NAME.xml Xidane System Description file
#
# Output: XD_DESIGN_NAME.bd.tcl file used in the IPI implementation flow
#
# Usage: Pass these values on the command line, e.g.
#          XD_DESIGN_NAME = xdsystem
#          XILINX_XD=/proj/xidane/builds/XIDANE_DEV/latest
#          XD_IDS_VERSION = IDS version number, e.g., 14.4
#
# Usage: Pass these values on the command line, e.g.
#   -dn <design name>       Design name (e.g. xdsystem)
#                           XD_DESIGN_NAME
#   -dp <design path>       Path to the System Description file,
#                           typically <working_dir>/_apfcc/xsd
#                           XD_DESIGN_DIR
#   -bd <name>.bd           Optionally specify the top-level .bd file
#   -ids-ver <version>      IDS version number (e.g. 14.1)
#                           XD_IDS_VERSION
#
# =============================================================================

# Global variables

# Associative array containing share global data
array set glb {}

#set glb(XD_IMPL_TOOL_VIVADO)    "vivado"
#set glb(XD_IMPL_TOOL_DEFAULT)   $glb(XD_IMPL_TOOL_VIVADO)
#set glb(XD_IMPL_TOOL)           $glb(XD_IMPL_TOOL_DEFAULT)

set verbose 0

# Get XILINX_XD from environment or set as needed
if {![info exists ::env(XILINX_XD)]} {
  set THIS_SCRIPT [info script]
  set XILINX_XD [file normalize [file join [file dirname $THIS_SCRIPT] ..]]
  set ::env(XILINX_XD) $XILINX_XD
} else {
  set XILINX_XD $::env(XILINX_XD)
  #puts "INFO: Using user-defined path for XILINX_XD environment variable $XILINX_XD"
}

# Set default values
set XD_DESIGN_NAME ""
set XD_DESIGN_DIR ""
set XD_TOP_BD_OPTION ""
set XD_IDS_VERSION ""
set XD_ADDRGEN_OPTION ""

# Parse command line
for {set i 0} {$i < $argc} {incr i} {
  set arg [lindex $argv $i]
  if {[string equal $arg "-dn"]} {
    incr i
    set XD_DESIGN_NAME [lindex $argv $i]
  } elseif {[string equal $arg "-dp"]} {
    incr i
    set XD_DESIGN_DIR [lindex $argv $i]
  } elseif {[string equal $arg "-bd"]} {
    incr i
    set XD_TOP_BD_OPTION "--stringparam P_XD_TOP_BD [lindex $argv $i]"
  } elseif {[string equal $arg "-disable-address-gen"]} {
    set XD_ADDRGEN_OPTION "--stringparam P_GEN_ADDR_MAP false"
  } elseif {[string equal $arg "-ids-ver"]} {
    incr i
    set XD_IDS_VERSION [lindex $argv $i]
  # -impl-tool <vivado | ipi>
#  } elseif {[string match "-impl-tool" $arg]} {
#    incr i
#    set glb(XD_IMPL_TOOL) [string tolower [lindex $argv $i]]
  } elseif {[string match "-v" $arg]} {
    set verbose 1
  } 
}
set glb(XD_DESIGN_NAME) ${XD_DESIGN_NAME}
set glb(XD_DESIGN_DIR)  ${XD_DESIGN_DIR}
set glb(XD_IDS_VERSION) ${XD_IDS_VERSION}
set glb(XD_TOP_BD_OPTION) ${XD_TOP_BD_OPTION}
set glb(XD_ADDRGEN_OPTION) ${XD_ADDRGEN_OPTION}

proc cmd_path {cmd} {
# this causes problems on Windows under cygwin, so for 2019.2+
# assume the command is in the PATH.
# return [file normalize [exec which $cmd]]
  return $cmd
}

proc exec_command {command} {
  global verbose

  if {$verbose} {
    puts $command
  }
  if { [catch { eval exec $command >@ stdout 2>@stderr } err] } {
    puts $err
    exit 1
  }
}

###############################################################################
# Initialize globals
# - Occurs after command line options have been parsed
###############################################################################

proc initialize_globals {} {
  global glb
  global verbose

  set glb(XD_XILINX_XD_PLATFORM_DIR_RELATIVE) [file join data cf platforms]
  set glb(XD_XILINX_XD_IP_DIR_RELATIVE) [file join data cf ip]
  if {$verbose} {
    set glb(XD_OPT_VERBOSE) "-v"
  } else {
    set glb(XD_OPT_VERBOSE) ""
  }

  if {$verbose} {
    parray glb
  }
}

#============================================================================= 
# Vivado/IPI flows
#
# ipi_create_project_files
#============================================================================= 

# proc ipi_initialize_project_data
#
# The global glb stores values such as files names and other values
# used during processing. They are initialized here.

proc ipi_initialize_project_data {} {
  global  XILINX_XD verbose
  global  glb

  # Define variables
  set glb(XD_DESIGN)        $glb(XD_DESIGN_NAME).xml
  set glb(XD_ERROR)         $glb(XD_DESIGN_NAME)_error_check.xml
  set glb(XD_MERGED)        $glb(XD_DESIGN_NAME)_merged.xml
  set glb(XD_BD_TCL)        $glb(XD_DESIGN_NAME).bd.tcl

  # XD_REPOSITORY is a local, intermediate repository XML output
  # file created by the cf_xsd.tcl script in _cf/xsd (or _apfcc/xsd)
  # using files in that directory, including xd_ip_db.xml. The
  # naming may be confusing - if xd_ip_db.xml were using here in
  # this script in the xsltproc call found in ipi_create_project_files(),
  # it would overwrite the original xd_ip_db.xml and would likely work.
  # One caveat: ensure that xdsystem_xd_repository.xml references in
  # various xsl scripts have been removed (else you get entity not
  # found error messages).
  set glb(XD_REPOSITORY) \
      [file join $glb(XD_DESIGN_DIR) $glb(XD_DESIGN_NAME)_xd_repository.xml]

  set glb(XSL_XDREPOSITORY) \
      [file join ${XILINX_XD} scripts xsd xdBuildRepository.xsl]
  set glb(XSL_XDCHECK) \
      [file join ${XILINX_XD} scripts xsd xdCheckXdML.xsl]
  set glb(XSL_XDMERGE) \
      [file join ${XILINX_XD} scripts xsd xdMerge.xsl]
  set glb(XSL_XD2BD) \
      [file join ${XILINX_XD} scripts xsd xd2bd.xsl]

  if {$verbose} {
    parray glb
  }
}

# proc ipi_clean
#
# Delete files from the previous run

proc ipi_clean {} {
  global  glb

  file delete -force $glb(XD_MERGED) $glb(XD_ERROR)
}

# proc ipi_create_project_files
#
# Generate IPI BD tcl files

proc ipi_create_project_files {} {
  global  XILINX_XD
  global  glb

  # working directory is typically _apfcc/xsd
  set prev_dir [pwd]
  cd $glb(XD_DESIGN_DIR)

  # initialize global variables
  ipi_initialize_project_data

  # remove previously generated files
  ipi_clean

  # perform multiple transformations to create the IPI
  # project files, including TCL, et al

  # Generate XD_REPOSITORY
  exec_command "[cmd_path xsltproc] --path \".:[file join ${XILINX_XD} $glb(XD_XILINX_XD_IP_DIR_RELATIVE)]:[file join ${XILINX_XD} $glb(XD_XILINX_XD_PLATFORM_DIR_RELATIVE)]\" -o $glb(XD_REPOSITORY) $glb(XSL_XDREPOSITORY) $glb(XD_DESIGN)"

  # Generate XD_ERROR
  exec_command "[cmd_path xsltproc] -o $glb(XD_ERROR) $glb(XSL_XDCHECK) $glb(XD_DESIGN)"

  # Generate XD_MERGED
  exec_command "[cmd_path xsltproc] --stringparam P_XD_IP_REPOS $glb(XD_REPOSITORY) -o $glb(XD_MERGED) $glb(XSL_XDMERGE) $glb(XD_DESIGN)"

  # Generate IPI BD Tcl
  exec_command "[cmd_path xsltproc] --stringparam P_XD_IP_REPOS $glb(XD_REPOSITORY) --stringparam P_XILINX_XD ${XILINX_XD} $glb(XD_TOP_BD_OPTION) $glb(XD_ADDRGEN_OPTION) -o $glb(XD_BD_TCL) $glb(XSL_XD2BD) $glb(XD_MERGED)"

  cd $prev_dir
}

#============================================================================= 
# main flow
#============================================================================= 

# Initialized generic globals
initialize_globals

# Generate hardware project files
ipi_create_project_files


