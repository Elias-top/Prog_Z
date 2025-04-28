namespace eval chipscope::injector {
  global regDict
  global regDictSerial
  global regDictSerial_

  set XSDB_REG_PATH_VERILOG "inst"
  set XSDB_REG_PATH_VHDL "U0"

  set regDict [dict create \
    "SAMPLE_COUNT_NUM_BITS"   {32    0   31 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "SC_WC_VALID_BITS"        {64   32   95 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TRIG_POS_0"              {1    96   96 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TRIG_POS_EQ_MAX_SC"      {1    97   97 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "SC_MAX_EQ_1"             {1    98   98 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "ARM"                     {1    99   99 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg" \
                               1    -1   -1 "axis_ila_intf/inst/u_core_reg/done_o_reg"} \
    "ADV_TRIG_CONFIG"         {1   100  100 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "STRG_QUAL_CONFIG"        {2   101  102 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TRIG_IN_CONFIG"          {1   103  103 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TRIG_OUT_CONFIG"         {2   104  105 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "HALT"                    {1   106  106 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TAS_ENABLE"              {1   -1   -1  "axis_ila_intf/inst/tas_enable_reg" \
                               1   -1   -1  "axis_ila_intf/inst/tas_enable_iclk_reg"} \
    "CC_CASE_SEL"             {4   108  111 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "EN_DEEP_STORAGE"         {1   112  112 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "WINDOW_DEPTH_CONFIG"     {64  128  191 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "WINDOW_COUNT_CONFIG"     {64  192  255 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    "TRIGGER_POS_CONFIG"      {64  256  319 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    ]
    #"SAMPLE_COUNT_NUM_BITS"   {32    0   31 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"SC_WC_VALID_BITS"        {64   32   95 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"TRIG_POS_0"              {1    96   96 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"TRIG_POS_EQ_MAX_SC"      {1    97   97 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"SC_MAX_EQ_1"             {1    98   98 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"ARM"                     {1    99   99 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg" \
    #                           1    -1   -1 "axis_ila_intf/inst/u_core_reg/done_o_reg"} \
    #"ADV_TRIG_CONFIG"         {1   100  100 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"STRG_QUAL_CONFIG"        {2   101  102 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"TRIG_IN_CONFIG"          {1   103  103 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"TRIG_OUT_CONFIG"         {2   104  105 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"HALT"                    {1   106  106 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"TAS_ENABLE"              {1   -1   -1  "axis_ila_intf/inst/tas_enable_reg"} \
    #"CC_CASE_SEL"             {4   108  111 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"EN_DEEP_STORAGE"         {1   112  112 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg"} \
    #"WINDOW_DEPTH_CONFIG"     {64  128  191 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"WINDOW_COUNT_CONFIG"     {64  192  255 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"TRIGGER_POS_CONFIG"      {64  256  319 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"TAS_ENABLE"              {1   107  107 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg"} \
    #"ARM"                     { 99   99 "axis_ila_intf/inst/u_core_reg/u_done_sync/genblk1_0.xpm_cdc_handshake_inst/dest_hsdata_ff_reg" \
                                99   99 "axis_ila_intf/inst/u_core_reg/I_EN_CTL_EQ1.full_data_o_reg" \
                                -1   -1 "axis_ila_intf/inst/arm_iclk_reg" \
                                -1   -1 "axis_ila_intf/inst/arm_reg" } \

  dict set regDictSerial_ "CC_CONFIG_%d"      sequencial {0  3   "cc_axis_mu%d"}
  dict set regDictSerial_ "MATCH_UNIT_%d_0"   sequencial {0  511  "axis_mu%d_0"}
  dict set regDictSerial_ "MATCH_UNIT_%d_1"   sequencial {0  511  "axis_mu%d_1"}
  dict set regDictSerial_ "MATCH_UNIT_%d_2"   sequencial {0  511  "axis_mu%d_2"}
  dict set regDictSerial_ "MATCH_UNIT_%d_3"   sequencial {0  511  "axis_mu%d_3"}
  dict set regDictSerial_ "MATCH_UNIT_%d_4"   sequencial {0  511  "axis_mu%d_4"}
  dict set regDictSerial_ "MATCH_UNIT_%d_5"   sequencial {0  511  "axis_mu%d_5"}
  dict set regDictSerial_ "MATCH_UNIT_%d_6"   sequencial {0  511  "axis_mu%d_6"}
  dict set regDictSerial_ "MATCH_UNIT_%d_7"   sequencial {0  511  "axis_mu%d_7"}
  dict set regDictSerial_ "MATCH_UNIT_%d_8"   sequencial {0  511  "axis_mu%d_8"}
  dict set regDictSerial_ "MATCH_UNIT_%d_9"   sequencial {0  511  "axis_mu%d_9"}
  dict set regDictSerial_ "MATCH_UNIT_%d_10"  sequencial {0  511  "axis_mu%d_10"}
  dict set regDictSerial_ "MATCH_UNIT_%d_11"  sequencial {0  511  "axis_mu%d_11"}
  dict set regDictSerial_ "MATCH_UNIT_%d_12"  sequencial {0  511  "axis_mu%d_12"}
  dict set regDictSerial_ "MATCH_UNIT_%d_13"  sequencial {0  511  "axis_mu%d_13"}
  dict set regDictSerial_ "MATCH_UNIT_%d_14"  sequencial {0  511  "axis_mu%d_14"}
  dict set regDictSerial_ "MATCH_UNIT_%d_15"  sequencial {0  511  "axis_mu%d_15"}
  dict set regDictSerial_ "TC_CONFIG_%d"      sequencial {0  31  "tc_axis_mu%d"}
  #dict set regDictSerial_ "SQC_CONFIG"        sequencial {0  0   "sqc_axis_mu"}

  proc populateSerialRegisters_ {} {
    variable regDictSerial_
    variable regDictSerial
    dict for {regNameFrmt info} $regDictSerial_ {
      dict with info {
        for { set i 0 } { $i < [llength $sequencial] } { incr i } {
          set sIndex [lindex $sequencial $i]
          incr i
          set eIndex [lindex $sequencial $i]
          incr i
          set primFrmt [lindex $sequencial $i]
          for { set index $sIndex } { $index <= $eIndex } { incr index } {
            set pos [string first "%d" $regNameFrmt]
            set regName [string replace $regNameFrmt $pos $pos+1 $index]
            set pos [string first "%d" $primFrmt]
            set primName [string replace $primFrmt $pos $pos+1 $index]
            dict set regDictSerial $regName sequencial $primName
          }
        }
      }
    }
    dict set regDictSerial "SQC_CONFIG" sequencial "sqc_axis_mu"
  }

  proc getSerialPrimitive {primPath regName} {
    variable regDictSerial
    set retPrimInstList [list]
    if {[dict exists $regDictSerial $regName]} {
      set info [dict get $regDictSerial $regName]
      dict with info {
          set primHierName $primPath$sequencial
          set primInstList [get_cells -hierarchical -regexp -filter "NAME =~  \"$primHierName.*\" && (PRIMITIVE_TYPE == CLB.LUT.CFGLUT5 || PRIMITIVE_TYPE == CLB.SRL.SRLC32E)"]
          set j [expr [llength $primInstList] - 1]
          for {set i 0} {$i <= $j} {incr i} {
            set ll [string range [lindex $primInstList $i] [expr [string length [lindex $primInstList $i]] - 2] [expr [string length [lindex $primInstList $i]] - 1]]
            if {[string compare $ll "S1"] != 0} {
              lappend retPrimInstList [lindex $primInstList $i]
            }
          }
      }
    }

set str_full {}
set str_nfull {}
for {set i 0} {$i < [llength $retPrimInstList]} {incr i} {

  set pos [string first "L2_" [lindex $retPrimInstList $i]]
  set str [string range [lindex $retPrimInstList $i] $pos $pos+3]
  
  if {$str == "L2_F" } {
    lappend str_full [lindex $retPrimInstList $i]
  } 
  if {$str == "L2_N" } {
    lappend str_nfull [lindex $retPrimInstList $i]
  }
}

set sort_full_L2 [sort_L2 $str_full]
set temp [expr [llength $sort_full_L2] / 16]
set sort_full [list]
for {set i 0} {$i < $temp} {incr i} {
set temp_list [lrange $sort_full_L2 [expr $i * 16] [expr [expr $i * 16] + 15]]
set temp_list [sort $temp_list]
for {set j 0} {$j < [llength $temp_list]} {incr j} {
   lappend sort_full [lindex $temp_list $j]
}
}
set sort_nfull [sort $str_nfull]

set ret_str {}
  lappend ret_str [lindex $retPrimInstList 0]

  if {$sort_nfull != "" || $sort_nfull != "NULL"} {
    for {set i 0} {$i < [llength $sort_nfull]} {incr i} {
      lappend ret_str [lindex $sort_nfull $i]
    }
  }
  if {$sort_full != "" || $sort_full != "NULL"} {
    for {set i 0} {$i < [llength $sort_full]} {incr i} {
      lappend ret_str [lindex $sort_full $i]
    }
  }

return $ret_str 
}

proc sort_L2 {str} {
set new_s {}
set result_s {}
foreach elem $str {
set pos_s [string first "FULL" $elem]
  set str_s [string range $elem $pos_s+5 $pos_s+6]
lappend new_s [list $elem $str_s]
}
foreach pair_s [lsort -dictionary -decreasing -index 1 $new_s] {
lappend result_s [lindex $pair_s 0]
}
return $result_s
}

proc sort {str} {
set new {}
set result {}
foreach elem $str {
set pos [string first "L1" $elem]
  set str [string range $elem $pos+3 $pos+4]

lappend new [list $elem $str]
}

foreach pair [lsort -dictionary -decreasing -index 1 $new] {lappend result [lindex $pair 0]}

return $result
}


  proc getPrimitive {primPath regName} {
    variable regDict
    if {[dict exists $regDict $regName]} {
      set retPrimInstList [list]
      set primList [dict get $regDict $regName]
      for { set i 1 } { $i < [llength $primList] } { incr i } {
        set sIndex [lindex $primList $i]
        incr i
        set eIndex [lindex $primList $i]
        incr i
        set prim [lindex $primList $i]
        if {$sIndex == -1} {
          set primHierName $primPath$prim
          set primInstList [get_cells $primHierName]
          if {[llength $primInstList] == 1} {
            lappend retPrimInstList $primInstList
          }
        } else {
          for { set index $sIndex } { $index <= $eIndex } { incr index } {
            set primHierName $primPath$prim[$index]
            set primInstList [get_cells $primHierName]
            if {[llength $primInstList] == 1} {
              lappend retPrimInstList $primInstList
            }
          }
        }
        incr i
      }
      return $retPrimInstList
    } else {
      return [getSerialPrimitive $primPath $regName]
    }
  }

proc hex_to_bin {hex} {

set hex_to_bin(0) 0000
set hex_to_bin(1) 0001
set hex_to_bin(2) 0010
set hex_to_bin(3) 0011
set hex_to_bin(4) 0100
set hex_to_bin(5) 0101
set hex_to_bin(6) 0110
set hex_to_bin(7) 0111
set hex_to_bin(8) 1000
set hex_to_bin(9) 1001
set hex_to_bin(A) 1010
set hex_to_bin(B) 1011
set hex_to_bin(C) 1100
set hex_to_bin(D) 1101
set hex_to_bin(E) 1110
set hex_to_bin(F) 1111

set temp [split $hex ""]
foreach t $temp {
                    lappend bin $hex_to_bin($t)
                }
set bin [join $bin ""]
return $bin
}

proc bin_to_hex {bin} {
    set result ""
    set prepend [string repeat 0 [expr (4-[string length $bin]%4)%4]]
    foreach g [regexp -all -inline {[01]{4}} $prepend$bin] {
        foreach {b3 b2 b1 b0} [split $g ""] {
            append result [format %X [expr {$b3*8+$b2*4+$b1*2+$b0}]]
        }
    }
    return $result
} 

proc dec2bin {i {width {}}} {
    set res {}
    if {$i<0} {
        set sign -
        set i [expr {abs($i)}]
    } else {
        set sign {}
    }
    while {$i>0} {
        set res [expr {$i%2}]$res
        set i [expr {$i/2}]
    }
    if {$res eq {}} {set res 0}

    if {$width ne {}} {
        append d [string repeat 0 $width] $res
        set res [string range $d [string length $res] end]
    }
    return $sign$res
}

  proc stampRegister {ilastr regName regValue} {
    variable regDict
    variable XSDB_REG_PATH_VERILOG
    set primPath "$ilastr/$XSDB_REG_PATH_VERILOG/"
    set primList [getPrimitive $primPath $regName]
    if {[dict exists $regDict $regName]} {
      set bitcount [lindex [dict get $regDict $regName] 0]
      if {$bitcount < 4} {
        set regValue_bin [dec2bin $regValue $bitcount]
      } else {
        set regValue_bin [hex_to_bin $regValue]
      }
    } else {
    set len [ string length $regValue ]
    set str_start 0
    set str_end 7
    for { set j 0 }  { $str_start < $len } { incr j } {
    lappend regValue_bin [ string range $regValue $str_start $str_end ]
    incr str_start 8
    incr str_end 8
    }
    }
    set i 0 
    foreach primInst $primList {
      if {[dict exists $regDict $regName]} {
        if {[string compare $regName "ARM"] == 0 || [string compare $regName "TAS_ENABLE"] == 0} {
          set_property INIT [string index $regValue_bin 0] $primInst
        } else {
          set_property INIT [string index $regValue_bin $i] $primInst
        }
      } else {
        set_property INIT [lindex $regValue_bin $i] $primInst
      }
      set i [expr $i + 1]
    }
  }

  proc applyHwIlaTrigger_ {trigfilepath ilastr} {
    source $trigfilepath
    populateSerialRegisters_

    set regList [get_tas_core_registers 0]
    for { set i 0 } { $i < [llength $regList] } { incr i } {
      set regName [lindex $regList $i]
      incr i
      set regValue [lindex $regList $i]
      stampRegister $ilastr $regName $regValue
    }
  }

  # Interface proc
  proc applyHwIlaTrigger {trigfilepath ilastr} {
#    set ilastr design_1_i/axis_ila_0

    source $trigfilepath
    if {$ilastr == "NULL" || $ilastr == ""} {       
    set regList [get_tas_core_info 0]
    for { set i 0 } { $i < [llength $regList] } { incr i } {
      set regName [lindex $regList $i]
      incr i
      set regValue [lindex $regList $i]
   
      if {$regName == "CORE_INSTANCE" } {
        set ilastr $regValue
      }      
    }
    }
  #  populateSerialRegisters_

set hex "C"
# No option to get the value without writing it to a variable
#scan $hex B* bits
#scan $hex %x binary
#binary scan B $hex B* bits
#set binary

set bin [hex_to_bin $hex]

# Prints '01100001011000100110001101100100' 

   applyHwIlaTrigger_ $trigfilepath $ilastr
  }

  proc reportAllRegisters {} {
  }

  proc injectDesign {option} {
  }

}
