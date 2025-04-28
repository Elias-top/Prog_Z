# 
# This script defines all Rodin features available
# Script is sourced at application startup time

namespace eval rdi {
    set approot $::env(HDI_APPROOT)
    set ldext [info sharedlibextension]
    set task_libraries {}

    proc load_library { feature library } {
        if { [lsearch $rdi::task_libraries $library$rdi::ldext] == -1 } {
            if {[catch {uplevel 1 load $library$rdi::ldext} result]} {
                error "$result\nCould not load library '$library' needed by '$feature', please check installation."
            }
            lappend rdi::task_libraries $library$rdi::ldext
        }
    }

    # with gradle build, the library name has the prefix of libxv_
    # but the Init procedure in c++ usually has Rdi_ prefix
    # if you want to load the gradle built library without renaming
    # the Init procedure in c++, you can use the following tcl proc
    proc load_library_pkg { feature library package } {
        # puts "debug: load_library_pkg: $feature $library $package"
        if { [lsearch $rdi::task_libraries $library$rdi::ldext] == -1 } {
            if {[catch {uplevel 1 load $library$rdi::ldext $package} result]} {
                error "$result\nCould not load library '$library' ('$package') needed by '$feature', please check installation."
            }
            lappend rdi::task_libraries $library$rdi::ldext
        }
    }

    proc load_internal_library { feature library } {
        if { [get_param tcl.dontLoadInternalLibraries] == 0 } {
            if { [lsearch $rdi::task_libraries $library$rdi::ldext] == -1 } {
                set libfile [rdi::utils::find_approot_file [file join lib $::env(RDI_PLATFORM)$::env(RDI_OPT_EXT) $library$rdi::ldext]]
                if {[file exists $libfile] && [catch {uplevel 1 load $libfile} result]==0} {
                    lappend rdi::task_libraries $library$rdi::ldext
                }
            }
        }
    }

    proc load_internal_library_pkg { feature library package } {
        if { [get_param tcl.dontLoadInternalLibraries] == 0 } {
            if { [lsearch $rdi::task_libraries $library$rdi::ldext] == -1 } {
                set libfile [rdi::utils::find_approot_file [file join lib $::env(RDI_PLATFORM)$::env(RDI_OPT_EXT) $library$rdi::ldext]]
                if {[file exists $libfile] && [catch {uplevel 1 load $libfile $package} result]==0} {
                    lappend rdi::task_libraries $library$rdi::ldext
                }
            }
        }
    }
}

namespace eval rdi::utils {
    set platformSeparator ":"
    if {[info exist tcl_platform(platform)] && ($tcl_platform(platform) == "windows")} {
        set platformSeparator ";"
    }
    proc find_approot_file {relPath} {
        variable platformSeparator
        set foundFile [file join $rdi::approot $relPath]
        foreach rdiRoot [split "$::env(RDI_APPROOT)" $platformSeparator] {
            set foundFile [file join $rdiRoot $relPath]
            if {[file exists $foundFile]} {
                break
            }
        }
        return $foundFile
    }
}


