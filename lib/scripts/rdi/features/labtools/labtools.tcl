# % load_feature labtools
# 
# This file is sourced by load_feature after features.tcl

# libraries
set GRADLE_BUILD 1 
if { $GRADLE_BUILD } {
  #rdi to gradle transition - on windows standalone labtool crashes, libraries are being loaded multiple times
  set target_lib libxv_labtoolstasks
  if { $::tcl_platform(platform) == "windows" } {
    set target_lib xv_labtoolstasks
  }
  rdi::load_library_pkg labtools $target_lib Rdi_labtoolstasks
} else {
  rdi::load_library labtools librdi_labtoolstasks
}
rdi::load_library simulator librdi_wavedatatasks

# the following code is copied from deprecated.tcl since it only takes effect in vivado
# Log argument string to log and journal file
proc rdi::record {args}  {
    set subst_args [uplevel 1 subst -nocommands $args]
    rdi::echo $subst_args
}

# Prevent global procs implementing deprecated commands from showing
# up in command completion
rdi::hide_commands \
 open_hw \
 close_hw \
 read_hw \
 write_hw 
 
# deprecation layer to convert open_hw to open_hw_manager
proc open_hw {args} {

  if { "?" in $args || "-h" in $args || "-help" in $args} {
    error "ERROR: \'open_hw\' is deprecated, please use \'open_hw_manager\' instead."
    return 1;
  } else {
    puts "WARNING: \'open_hw\' is deprecated, please use \'open_hw_manager\' instead."
  }

  set myArgs {}
  foreach arg $args {
    if {![rdi::is_blank $arg]} {
      lappend myArgs $arg
    }
  }

  # straight translation - args are identical
  rdi::record {open_hw_manager $myArgs}
  # load_features labtools
  open_hw_manager {*}$myArgs
}

# deprecation layer to convert close_hw to close_hw_manager
proc close_hw {args} {

  if { "?" in $args || "-h" in $args || "-help" in $args} {
    error "ERROR: \'close_hw\' is deprecated, please use \'close_hw_manager\' instead."
    return 1;
  } else {
    puts "WARNING: \'close_hw\' is deprecated, please use \'close_hw_manager\' instead."
  }

  set myArgs {}
  foreach arg $args {
    if {![rdi::is_blank $arg]} {
      lappend myArgs $arg
    }
  }

  # straight translation - args are identical
  rdi::record {close_hw_manager $myArgs}
  close_hw_manager {*}$myArgs
}

# deprecation layer to convert read_hw to read_hw_core
proc read_hw {args} {

  if { "?" in $args || "-h" in $args || "-help" in $args} {
    error "ERROR: \'read_hw\' is deprecated, please use \'read_hw_core\' instead."
    return 1;
  } else {
    puts "WARNING: \'read_hw\' is deprecated, please use \'read_hw_core\' instead."
  }

  set myArgs {}
  foreach arg $args {
    if {![rdi::is_blank $arg]} {
      lappend myArgs $arg
    }
  }

  # straight translation - args are identical
  rdi::record {read_hw_core $myArgs}
  read_hw_core {*}$myArgs
}

# deprecation layer to convert write_hw to write_hw_core
proc write_hw {args} {

  if { "?" in $args || "-h" in $args || "-help" in $args} {
    error "ERROR: \'write_hw\' is deprecated, please use \'write_hw_core\' instead."
    return 1;
  } else {
    puts "WARNING: \'write_hw\' is deprecated, please use \'write_hw_core\' instead."
  }

  set myArgs {}
  foreach arg $args {
    if {![rdi::is_blank $arg]} {
      lappend myArgs $arg
    }
  }

  # straight translation - args are identical
  rdi::record {write_hw_core $myArgs}
  write_hw_core {*}$myArgs
}


