# Labtools.tcl feature script
#
# Loaded during startup

#puts "DEBUG: ======= BEGIN VIVADO_LAB.TCL LOADER SCRIPT ==========="
namespace import common::*
load_features writecfgmem

set CMDHASH [dict create]

proc unregister {cmd} {
#  puts "DEBUG: unregister_task: $cmd"
  rdi::unregister_task $cmd
}


### BASE LIBRARY ###
# These are the base tcl commands for vivado we must have
#
load_features base
# Record a baseline set of good commands we will keep. 
# After loading the "core" library we will remove commands not in the
# "keeper" list but leave the baseline set intact.
foreach cmd [info commands] {
  dict set CMDHASH $cmd 1
}


### LABTOOLS LIBRARY
# This is the set of labtools (hw) commands. Loading this will also include
# common waveform support
#
load_features labtools

set_param labtools.standaloneMode true

rdi::load_library salt {librdi_standalonetasks}

### updatemem
# Load updatemem tcl commmand, but only if updatemem is installed.
#
namespace eval hw {
  set updatemem_path {}
  if { [info exists ::env(RDI_BINROOT)] } {
    set updatemem_path [file join $::env(RDI_BINROOT) updatemem]

  } elseif { [info exists ::env(RDI_APPROOT)] } {
    set updatemem_path [file join $::env(RDI_APPROOT) bin updatemem]
  } 

  if { ([string length $updatemem_path] != 0) && ([file exist $updatemem_path]) } {
    rdi::load_library updatemem {librdi_updatememtasks}
  }
  unset updatemem_path
}

# name of java entry and library
namespace eval rdi {
  set javajar planAhead.jar
  set javamainclass ui/PlanAhead
  set javamainmethod jswMain

  # Hide features
  hide_features core
  hide_features ipintegrator
  hide_features ipservices
  hide_features planahead
  hide_features updatemem
  hide_features vivado
}


namespace eval hw {
  # export all for now, we can be more selective if we chose
  # however, this will auto export all new commands for us
  namespace export *;
}

namespace import -force ::hw::*;


# tcl prompts
# NOTE: This does not stick - there must be another
# thing that is resetting the prompt...
#
set tcl_prompt1 {puts -nonewline {vivado_lab% }}
# start editline
rdi::start_editline vivado_lab

#puts "DEBUG: ======= END VIVADO_LAB.TCL LOADER SCRIPT ==========="



