# vitis_analyzer.tcl feature script
#
# Loaded during startup

# Provide Vivado 2018.3 so that Tcl scripts can check
# This must come first so that features can check.
package provide Vivado 1.2019.1

namespace import common::*
load_features base
# libraries
# Temp changes to support gradle builds, which creates the libs with
# libxv_ prefix instead of librdi_ prefix. gradle build scripts search
# and replace "set GRADLE_BUILD 1" with "set GRADLE_BUILD 1" during build,
# so libxv_* libs are loaded when the tool is run from gradle build products
# rdi::load_library "hsm" librdi_hsmtasks
set GRADLE_BUILD 1
if { $GRADLE_BUILD } {
  set target_lib libxv_vitisanalyzertasks
  #added to support windows frank windows lib prefix is xv_
  if { $::tcl_platform(platform) == "windows" } {
    set target_lib xv_vitisanalyzertasks
  }
} else {
  set target_lib librdi_vitisanalyzertasks
}
rdi::load_library vitisanalyzer {$target_lib}

# name of java entry and library
namespace eval rdi {
  set javajar planAhead.jar
  set javamainclass ui/PlanAhead
  set javamainmethod jswMain
}
# tcl prompt
set tcl_prompt1 {puts -nonewline {vitis_analyzer% }}
# start editline
rdi::start_editline vitis_analyzer

