#!/usr/bin/tclsh
#  File: build_xd_ip_db.tcl
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

# Set XILINX_XD if not set
if {![info exists ::env(XILINX_XD)]} {
  set THIS_SCRIPT [info script]
  set XILINX_XD [file normalize [file join [file dirname $THIS_SCRIPT] ..]]
  set ::env(XILINX_XD) $XILINX_XD
} else {
  set XILINX_XD $::env(XILINX_XD)
  puts "INFO: Using user-defined path for XILINX_XD environment variable $XILINX_XD"
}

###############################################################################
# utility functions
###############################################################################

proc cmd_path {cmd} {
  # this causes problems on Windows under cygwin, so for 2019.2+
  # assume the command is in the PATH.
  # return [file normalize [exec which $cmd]]
  return $cmd
}

# return $path if absolute else [file join $root_dir $path]
proc to_abs_path {path root_dir} {
# file join return $path if it is absolute, so the code below
# is not needed (also not portable)
# if {[regexp {^/} $path]} {
#   return $path
# }
  return [file join $root_dir $path]
}

# return path to file in a list of file paths or "" if does not exist
proc find_file_in_filepath_list {filename path_list} {
  foreach fn $path_list {
    if {$filename == [file tail $fn]} {
      if {[file exists $fn]} {
        return $fn
      }
      puts "warning: file $fn does not exist"
    }
  }
  puts "warning: $filename not found on list"
  return ""
}

# return path to file in a list of directory paths or "" if does not exist
proc find_file_in_dirpath_list {filename dirpath_list} {
  foreach dir $dirpath_list {
    set filepath [file join $dir $filename]
    if {[file exists $filepath]} {
        return $filepath
    }
  }
  puts "warning: $filename not found on directory list"
  return ""
}

# return list of directories containing the named file
proc find_dirs_with_file {starting_dir search_file} {
  set dir_list {}

  # see if the current directory contains the file
  set file_list [glob -nocomplain -type f -directory $starting_dir $search_file]
  if {[llength $file_list] > 0} {
    lappend dir_list $starting_dir
  }
  
  # look in each sub-directory for the file
  foreach dir_name [glob -nocomplain -type d -directory $starting_dir *] {
    set sub_dir_list [find_dirs_with_file $dir_name $search_file]
    foreach sub_dir $sub_dir_list {
      lappend dir_list $sub_dir
    }
  }

  # return the list of directories
  return $dir_list
}

proc get_files {dir pattern} {
  # Ensure directory name is correct for platform
  set dir [string trimright [file join [file normalize $dir] { }]]

  set fileList {}
  foreach fileName [glob -nocomplain -type f -directory $dir $pattern] {
    lappend fileList $fileName
  }
  foreach dirName [glob -nocomplain -type d -directory $dir *] {
    set subDirList [get_files $dirName $pattern]
    foreach subDirFile $subDirList {
      lappend fileList $subDirFile
    }
  }
  return $fileList
}

proc exec_command {command} {
  global verbose redirect
  if {$verbose} {
    puts $command
  }
  if { [catch { eval exec $command $redirect } err] } {
    puts $err
    exit 1
  }
}

# debugging procs
proc step {name {yesno 1}} {
  set mode [expr {$yesno? "add" : "remove"}]
  trace $mode execution $name {enterstep leavestep} interact
}

proc interact args {
  if {[lindex $args end] eq "leavestep"} {
    puts ==>[lindex $args 2]
    return
  }
  puts -nonewline "$args --"
  while 1 {
    puts -nonewline "> "
    flush stdout
    gets stdin cmd
    if {$cmd eq "c" || $cmd eq ""} break
    catch {uplevel 1 $cmd} res
    if {[string length $res]} {puts $res}
  }
}

# mysplit --
#
#   Splits a string based using another string
#
# Arguments:
#   str       string to split into pieces
#   splitStr  substring
#   mc        magic character that must not exist in the orignal string.
#             Defaults to the NULL character.  Must be a single character.
# Results:
#   Returns a list of strings
#
proc mysplit "str splitStr {mc {\x00}}" {
    return [split [string map [list $splitStr $mc] $str] $mc]
}

proc xpath_get_value {xml_file xpath} {
  global XILINX_XD
  set xsl_file [file join $XILINX_XD scripts xdcc xpathValueOf.xsl]
  set command "[cmd_path xsltproc] --stringparam xpath \"$xpath\" $xsl_file $xml_file"
  puts "$command"
  # Escape opening brackets so they don't get evaluated by Tcl interpreter
  regsub -all {\[} $command "\\\[" escaped_command
  catch { eval exec $escaped_command 2>@ stderr } result
  return $result
}

############################################################
# ipxact accel constructor for Vivado IPI (IPXACT)
# the "object" consists of several fields and accessors
#
# ip_dir       - accelerator's ip directory
#                e.g., _sysl/vhls/accel/solution/impl/ip
# ip_name      - accelerator's name
# clk_id       - platform clock id for the accel instance
# buffer_depth - multi-buffer depth for all BRAM arguments
############################################################
# For Vivado/IPI flows only
proc process_ipxact_accel_path {ip_dir {clk_id 0} {buffer_depth 1} accelList} {
  global    accels
  global    ip_search

  puts "processing accelerators: $ip_dir"
  if {$ip_search} {
    set ip_path_dir_list [find_dirs_with_file $ip_dir component.xml]
  } else {
    set ip_path_dir_list [list ${ip_dir}]
  }
  foreach ip_path_dir $ip_path_dir_list {
    lappend accels [create_ipxact_accel $ip_path_dir $clk_id $buffer_depth $accelList]
  }
}

proc create_ipxact_accel {ip_dir {clk_id 0} {buffer_depth 1} accelList} {
  puts "ip_dir: $ip_dir"
  set component_xml [file join $ip_dir component.xml]
  set ip_name [xpath_get_value $component_xml "spirit:component/spirit:name/text()"]
  puts "ip_name: $ip_name"
  set accelNames $ip_name
  if {[string length $accelList] > 0} {
    set accelNames $accelList
  }
  return [list $ip_name $ip_dir $clk_id $buffer_depth $accelNames]
}

proc accel_dir {accel} {
  return [lindex $accel 1]
}

proc accel_name {accel} {
  return [lindex $accel 0]
}

proc accel_ip_name {accel} {
  return [lindex $accel 0]
  set version_str ""
  regexp {_top_v1_00_a} [accel_name $accel] version_str
  if {$version_str == ""} {
    regexp {_v[0-9]+_} [accel_name $accel] version_str
  }
  return [lindex [mysplit [accel_name $accel] $version_str] 0]
}

proc accel_clk_id {accel} {
  return [lindex $accel 2]
}

proc accel_buffer_depth {accel} {
  return [lindex $accel 3]
}

proc accel_kernel_names {accel} {
  return [lindex $accel 4]
}

###############################################################################
# return list of standard CF IP accels
###############################################################################

# remove element v from list l
proc lremove {l v} {
  upvar 1 $l var
  set idx [lsearch -exact $var $v]
  set var [lreplace $var $idx $idx]
}

proc get_std_xd_ip_list {XILINX_XD} {
global xsd_platform_xml
# filter out the legacy xml files so that they don't have to be 
# deleted 
  #return "[lsearch -all -inline [glob -tail -directory [file join $XILINX_XD data cf ip] *.xml] *_v*] [lsearch -all -inline [glob -tail -directory [file join $XILINX_XD data cf platforms] *.xml] *_v*]"
# return "[lsearch -all -inline [glob -tail -directory [file join $XILINX_XD data cf ip] *.xml] *_v*] [lsearch -all -inline [glob -tail -directory [file join $XILINX_XD platforms] *.xml] *_v*] ${xsd_platform_xml}"
  return "[lsearch -all -inline [glob -tail -directory [file join $XILINX_XD data cf ip] *.xml] *] [file tail ${xsd_platform_xml}]"
}

proc create_merged_fcnmap_file {mergedFcnmapFile mergedIndexFile fcnmapFileList} {
  global XILINX_XD

  set fp [open ${mergedIndexFile} w]
  puts $fp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $fp "<xd:component xmlns:xd=\"http://www.xilinx.com/xd\" xd:type=\"design\">"
  puts $fp "  <xd:repository xd:vendor=\"xilinx.com\" xd:library=\"xd\" xd:name=\"design_lib\" xd:version=\"1.0\">"
  foreach fcnmapFile $fcnmapFileList {
    puts $fp "    <xd:file xd:name=\"[file tail ${fcnmapFile}]\"/>"
  }
  puts $fp "  </xd:repository>"
  puts $fp "</xd:component>"
  close $fp

  # call XSLT script to build the merged fcnmap from the index file
  set command "[cmd_path xsltproc] \
        --path \"[file dirname ${mergedFcnmapFile}]\" \
        -o ${mergedFcnmapFile} \
        [file join ${XILINX_XD} scripts xsd xdBuildRepository.xsl] \
        ${mergedIndexFile}"
  exec_command $command
}


###############################################################################
# create HLS accelerator accel database files in a target directory
# Could be called during xdcc compile step
#
# output XML files
# ${acc_name}_top.xml   port interface for HLS accelerator
# ${acc_name}_if.xml    encapsulates mapping from HLS accelerator to xd_adapter
#
# intermediate generated files
# ${acc_name}.xml       file currently read by XidanePass for an HLS accelerator
#
# @param acc_name       accelerator name 
# @param hls_accel_dir  root of the HLS accelerator's accel directory
# @param clk_id         Platform clock id for this accelerator
# @param buffer_depth   Adapter multi-buffer depth; same for all BRAM ports
# @param db_dir         target directory where database files will be created
# @param XILINX_XD      absolute path to install root
# @param run_dir        absolute path to directory root for any relative paths
# @param verbose
###############################################################################
# Vivado/IPI flow
proc create_hls_accel_db_files {acc_name hls_accel_dir clk_id buffer_depth \
                                kernel_names db_dir XILINX_XD run_dir verbose} {
  set ret_dir [pwd]
  set db_dir_abs [to_abs_path $db_dir run_dir]

  set hls_accel_dir_abs [to_abs_path $hls_accel_dir $run_dir]
  set hls_rpt_dir [file join ${hls_accel_dir_abs} .. .. .. syn report]
  set hls_db_dir [file join ${hls_accel_dir_abs} .. .. .. .autopilot db]

  # Handle the ipxact directory structure
  set test_dir [file normalize [file join ${hls_accel_dir_abs} .. .. syn report]]
  if {[file exists $test_dir]} {
    set hls_rpt_dir $test_dir
  }
  set test_dir [file normalize [file join ${hls_accel_dir_abs} .. .. .autopilot db]]
  if {[file exists $test_dir]} {
    set hls_db_dir $test_dir
  }

  set acc_rpt_file [file join ${hls_rpt_dir} ${acc_name}_csynth.xml]
  set acc_rtl_tcl_file [file join ${hls_db_dir} ${acc_name}.rtl_wrap.cfg.tcl]

  if {$verbose} {
    puts "create_hls_accel_db_files"
    puts "     XILINX_XD: ${XILINX_XD}"
    puts "      acc name: ${acc_name}"
    puts "       db root: ${db_dir}"
    puts "    accel root: ${hls_accel_dir_abs}"
    puts "hls_report_dir: $hls_rpt_dir"
    puts "    hls_db_dir: $hls_db_dir"
  }

  cd $db_dir_abs

  set kNameList [split $kernel_names :]
  foreach kName $kNameList {

  # Check for params files
  set ipName ${acc_name}
  set params_file [file join ${db_dir} ${kName}.params.xml]
  if {[file exists $params_file]} {
    set p_comps_params_string "--stringparam P_COMP_PARAMS ${params_file}"
  } else {
    set p_comps_params_string ""
  }
  if {![string equal ${ipName} ${kName}] } {
    append p_comps_params_string " --stringparam P_XD_COMP_NAME ${kName}"
    append p_comps_params_string " --stringparam P_XD_COMP_REF ${ipName}"
  }

  set fcnmapFileList [glob "[file join ${db_dir} ${kName}.*fcnmap.xml]"]
  set acc_fcnmaps [lindex $fcnmapFileList 0]
  if {[llength $fcnmapFileList] > 1} {
    set mergedFcnmapFile [file join ${db_dir} ${kName}.fcnmap.merged]
    set mergedIndexFile [file join ${db_dir} ${kName}.index.merged]
    create_merged_fcnmap_file ${mergedFcnmapFile} ${mergedIndexFile} $fcnmapFileList
    set acc_fcnmaps ${mergedFcnmapFile}
  }

  set command "[cmd_path xsltproc] \
      --stringparam P_XD_AUTOESL_COMP TRUE \
      --stringparam P_XD_COMP_TYPE accelerator \
      --stringparam P_XD_COMP_FCNMAPS ${acc_fcnmaps} \
      $p_comps_params_string \
      -o [file join ${db_dir_abs} ${kName}.xml] \
      [file join ${XILINX_XD} scripts xsd ipxact2xdcomp.xsl] \
      [file join ${hls_accel_dir_abs} component.xml]"
  exec_command $command

  set internalKernelXml [file join ${hls_accel_dir_abs} component.internal.xml]
  if {[file exists $internalKernelXml]} {
    set command "[cmd_path xsltproc] \
      --stringparam P_XD_AUTOESL_COMP TRUE \
      --stringparam P_XD_COMP_TYPE accelerator \
      $p_comps_params_string \
      -o [file join ${db_dir_abs} ${kName}.internal.xml] \
      [file join ${XILINX_XD} scripts xsd ipxact2xdcomp.xsl] \
      $internalKernelXml"
    exec_command $command
  }
  }

  cd $ret_dir
}

###############################################################################
# Create an IP repository database file
#
# @param ip_db_file_list  ip database files in addition to std cf ip
# @param db_file          name of the XML database to be created
# @param XILINX_XD
# @param run_dir
#
# Creates database files
# xd_ip_index.xml <xd:repository/> list of ip.xml files 
# $db_file        XML database containing all <xd:component/> in xd_ip_index.xml
###############################################################################
proc create_ip_database {ip_db_file_list db_file XILINX_XD run_dir verbose} {
  global   glb xsd_dir xsd_platform_xml
  set db_file_abs [to_abs_path $db_file $run_dir]
  set db_file_name [file tail $db_file_abs]
  set db_file_dir [file dirname $db_file_abs]

  if {$verbose} {
    puts "create_ip_database"
    puts "     XILINX_XD: ${XILINX_XD}"
    puts "       run_dir: $run_dir"
    puts "       db_file: ${db_file}"
    puts "   db_file_abs: ${db_file_abs}"
    puts "   db_file_dir: ${db_file_dir}"
    puts "  db_file_name: ${db_file_name}"
  }

  set db_file_index [file join $db_file_dir "xd_ip_index.xml"]
  set fp [open $db_file_index w]
  puts $fp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $fp "<xd:component xmlns:xd=\"http://www.xilinx.com/xd\" xd:type=\"design\">"
  puts $fp "  <xd:repository xd:vendor=\"xilinx.com\" xd:library=\"xd\" xd:name=\"design_lib\" xd:version=\"1.0\">"
  foreach ip_file $ip_db_file_list {
    puts $fp "    <xd:file xd:name=\"[file tail $ip_file]\"/>"
  }
  puts $fp "  </xd:repository>"
  puts $fp "</xd:component>"
  close $fp

  # workaraound for Windows : copy IP and Platform XML to
  # _sysl/.cdb/repowork and use with --path, instead of looking
  # in the install area (seems not to like the Windows paths)
  set repowork_dir [file join $xsd_dir repowork]
  file mkdir $repowork_dir

  set from_ip_dir [file join ${XILINX_XD} $glb(XD_XILINX_XD_IP_DIR_RELATIVE)]
  set ip_xml_files [get_files $from_ip_dir *.xml]
  foreach ip_xml $ip_xml_files {
    file copy -force $ip_xml $repowork_dir
  }

  if {[file exists ${xsd_platform_xml}]} {
    file copy -force ${xsd_platform_xml} $repowork_dir
  }
# set from_platform_dir [file join ${XILINX_XD} $glb(XD_XILINX_XD_PLATFORM_DIR_RELATIVE)]
# set platform_xml_files [get_files $from_platform_dir *.xml]
# foreach platform_xml $platform_xml_files {
#   file copy -force $platform_xml $repowork_dir
#   puts "platform XML $platform_xml"
# }

  # call XSLT script to build the database from the index file
  # Previous --path value
  # . [file join ${XILINX_XD} $glb(XD_XILINX_XD_IP_DIR_RELATIVE)] [file join ${XILINX_XD} $glb(XD_XILINX_XD_PLATFORM_DIR_RELATIVE)] ${db_file_dir}

  set command "[cmd_path xsltproc] \
        --path \". ${repowork_dir} ${db_file_dir}\" \
        -o ${db_file_abs} \
        [file join ${XILINX_XD} scripts xsd xdBuildRepository.xsl] \
        ${db_file_index}"
  exec_command $command

  # clean up repository database, merge fcnmap metadate into HLS xd:components
  # To do: refactor database entry processing into compile step
  set command "[cmd_path xsltproc] \
        -o ${db_file_abs} \
        [file join ${XILINX_XD} scripts xsd xdMergeFcnmapsIntoComps.xsl] \
        ${db_file_abs}"
  exec_command $command

}

###############################################################################
# Globals 
###############################################################################

# Associative array containing share global data
array set glb {}

#set glb(XD_IMPL_TOOL_IDS)       "ids"
#set glb(XD_IMPL_TOOL_VIVADO)    "vivado"
#set glb(XD_IMPL_TOOL_DEFAULT)   $glb(XD_IMPL_TOOL_VIVADO)
#set glb(XD_IMPL_TOOL)           $glb(XD_IMPL_TOOL_DEFAULT)

set accels {}
set accel_name ""
set verbose 0
set clk_id 0
set buffer_depth 1
set help 0
set xsd_platform_xml "zynq"
set db_file ""
set db_dir ""

set proj_folder "_sysl"
set opt_platform "-sds-pf"

set ip_search 1


###############################################################################
# Define filenames and directories
###############################################################################
set APCC_DIR_SDS_COMPONENTDB    ".cdb"

set run_dir [pwd]
set sdscc_dir [file join $run_dir ${proj_folder}]
set xsd_dir [file join $sdscc_dir $APCC_DIR_SDS_COMPONENTDB]

if {$verbose} {
  set redirect ">@ stdout 2>@ stderr"
} else {
  set redirect "2>@ stderr"
}

###############################################################################
# Parse command line 
###############################################################################

# loop through arguments in order, assigning global variables
for {set i 0} {$i < $argc} {incr i} {
  set arg [lindex $argv $i]
  if {[string equal $arg ${opt_platform}]} {
    incr i
    set xsd_platform_xml [lindex $argv $i]
  } elseif {[string equal $arg "-o"]} {
    incr i
    set db_file [lindex $argv $i]
  } elseif {[string equal $arg "-cf"]} {
    incr i
    set cf_file [lindex $argv $i]
  } elseif {[string equal $arg "-clkid"]} {
    incr i
    set clk_id [lindex $argv $i]
  } elseif {[string equal $arg "-dmclkid"]} {
    incr i
    set clk_id [lindex $argv $i]
  } elseif {[string equal $arg "-buffer_depth"]} {
    incr i
    set buffer_depth [lindex $argv $i]
  } elseif {[string match "-ip" $arg]} {
    incr i
    set accelList ""
    set ipTokenList [ split [lindex $argv $i] , ]
    set ipTokenCount [llength $ipTokenList]
    set ipPath [lindex $ipTokenList 0]
    for {set t 1} {$t < $ipTokenCount} {incr t} {
      if {$t > 1} {
        append accelList ":"
      }
      append accelList [lindex $ipTokenList $t]
    }
    process_ipxact_accel_path [to_abs_path $ipPath $run_dir] $clk_id $buffer_depth $accelList
  } elseif {[string match "-ip_search" $arg]} {
    # this needs to appear before the -ip option
    incr i
    set ip_search [lindex $argv $i]
  } elseif {[string match "--help" $arg]} {
    set help 1
  } elseif {[string match "-v" $arg]} {
    set verbose 1
  } else {
    puts "warning: ignoring arg $arg"
  }
}

# Print help information
if {$help} {
  puts "Usage: build_xd_ip_db \[options\] accel..."
  puts "   Creates an XML IP database "
  puts ""  
  puts "Options:"
  puts "  -o  <file name>       XML database file name (defaults to ./xd_ip_db.xml)"
  puts "  -cf <file name>       CF system description file"
  puts "  -clkid <id>           Use clock <id> for following ip arguments"
  puts "  -buffer_depth <depth> Set buffer depth <depth> for following ip arguments"
  puts "  -ip <ip_path>         Path to the ipxact core. Argument must be the last for a particular ip"
  puts "  -v                    Display the programs invoked by the script"
  puts "  --help                Display this information"
  puts ""
  puts "  -ip, -clkid, -buffer_depth may be used multiple times to change values"
  puts ""
  exit 0
}

###############################################################################
# Initialize globals
# - Occurs after command line options have been parsed
###############################################################################
proc initialize_globals {} {
  global glb
  global verbose

  set glb(XD_XILINX_XD_IP_DIR_RELATIVE) [file join data cf ip]
  set glb(XD_XILINX_XD_PLATFORM_DIR_RELATIVE) [file join platforms]
  if {$verbose} {
    set glb(XD_OPT_VERBOSE) "-v"
  } else {
    set glb(XD_OPT_VERBOSE) ""
  }

  if {$verbose} {
    parray glb
  }
}

initialize_globals

###############################################################################
# set the data base file name if not passed on command-line
###############################################################################

# Main flow for Vivado/IPI
proc main_flow {} {
    global    db_file run_dir accels
    global    XILINX_XD verbose

    if {$db_file == ""} {
	set db_file_abs [file join $run_dir xd_ip_db.xml]
	set db_dir $run_dir
    } else {
	set db_file_abs [to_abs_path $db_file $run_dir]
	set db_dir [file dirname $db_file]
    }
    
    set db_file_name [file tail $db_file_abs]
    set db_file_dir [file dirname $db_file_abs]
    
    if {$verbose} {
	puts "build_xd_ip_db"
	puts "  XILINX_XD: ${XILINX_XD}"
	puts "    DB root: ${db_dir}"
	puts "     accels: "
	foreach accel $accels {
	    puts "         name: [accel_name $accel]"
	    puts "    directory: [accel_dir $accel]"
	    puts "      ip_name: [accel_ip_name $accel]"
	    puts "       clk_id: [accel_clk_id $accel]"
	    puts " buffer_depth: [accel_buffer_depth $accel]"
	    puts " kernel_names: [accel_kernel_names $accel]"
	    puts ""
	}
    }
    # initialize the list of IP from install area
    set ip_file_list "[get_std_xd_ip_list $XILINX_XD]"
    
    # iterate accelerator list, creating accelDB entries and them adding to IP list
    foreach accel $accels {
      set acc_name [accel_ip_name ${accel}]
      expr {"[create_hls_accel_db_files ${acc_name} \
                                      [accel_dir ${accel}] \
                                      [accel_clk_id ${accel}] \
                                      [accel_buffer_depth ${accel}] \
                                      [accel_kernel_names ${accel}] \
                                      $db_file_dir \
                                      $XILINX_XD $run_dir $verbose]"}
	
	# lappend ip_file_list "[accel_ip_name $accel].xml"
        set kNameList [split [accel_kernel_names $accel] :]
        foreach kName $kNameList {
	  lappend ip_file_list "${kName}.xml"
        }
        if {[file exists [file join ${db_dir} ${kName}.internal.xml]]} { 
          lappend ip_file_list "${kName}.internal.xml"
        }
	
	if {[file exists [file join ${db_dir} ${acc_name}_if.xml]]} { 
          lappend ip_file_list "${acc_name}_if.xml"
	}
	
	#search for files of the form: <ip>.*.xml
	#set fcnmaps [glob "[file join ${db_dir} [accel_ip_name ${accel}]*.fcnmap.xml]"]
	set fcnmaps [glob "[file join ${db_dir} *.fcnmap.xml]"]
	foreach fcnmap $fcnmaps {
	    #if {[file exists [file join ${db_dir} [accel_ip_name ${accel}].fcnmap.xml]]} { }
	    lappend ip_file_list [file tail $fcnmap]
	}
    }

    # create the database with IP in the IP list
    expr {"[create_ip_database ${ip_file_list} [file join ${db_dir} ${db_file_abs}] \
                             $XILINX_XD $run_dir $verbose]"}
}

###############################################################################
# Main Flow
###############################################################################
main_flow


