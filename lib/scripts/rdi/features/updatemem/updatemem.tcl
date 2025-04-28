# % load_feature updatemem
# 
# This file is sourced by load_feature after features.tcl

# libraries
#This command was causing crash on windows - loading libraries multiple times - see details in CR-1203090
#rdi::load_library updatemem librdi_updatememtasks
set GRADLE_BUILD 1 
if { $GRADLE_BUILD } {
   set target_lib libxv_updatememtasks
   if { $::tcl_platform(platform) == "windows" } {
      set target_lib xv_updatememtasks
   }
   rdi::load_library_pkg updatemem $target_lib Rdi_updatememtasks
} else {
   rdi::load_library updatemem librdi_updatememtasks
}