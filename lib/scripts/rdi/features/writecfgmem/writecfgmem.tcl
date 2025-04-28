# % load_feature writecfgmem
# 
# This file is sourced by load_feature after features.tcl
# libraries
set target_lib libxv_writecfgmemtasks
if { $::tcl_platform(platform) == "windows" } {
  set target_lib xv_writecfgmemtasks
}
rdi::load_library_pkg writecfgmem $target_lib Rdi_writecfgmemtasks

