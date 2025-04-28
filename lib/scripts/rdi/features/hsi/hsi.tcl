# % load_feature labtools
# 
# This file is sourced by load_feature after features.tcl

# libraries
# Temp changes to support gradle builds, which creates the libs with
# libxv_ prefix instead of librdi_ prefix. gradle build scripts search
# and replace "set GRADLE_BUILD 1" with "set GRADLE_BUILD 1" during build,
# so libxv_* libs are loaded when the tool is run from gradle build products
# rdi::load_library "hsm" librdi_hsmtasks
set GRADLE_BUILD 1
if { $GRADLE_BUILD } {
  if { $::tcl_platform(platform) == "windows" } {
    set target_lib xv_hsmtasks
  } else {
    set target_lib libxv_hsmtasks
  }
} else {
  set target_lib librdi_hsmtasks
}
set pkg_name "Rdi_hsmtasks"

rdi::load_library_pkg "hsm" $target_lib $pkg_name

# export all commands from the hsi:: Tcl namespace
namespace eval hsi {namespace export *}

namespace eval hsm { namespace import ::hsi::* }



