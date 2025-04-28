namespace eval chipscope::bscanxdc {
  proc apply_bscan_constraints { interfaceindex inst primitiveInst} {

    if { $inst !="" } {
      current_instance -quiet
      current_instance $inst
    }

    set c_projectpart [get_property part [current_project]]
    set es1_part [string match *es1 $c_projectpart ]

    set filter1_USRTCKINT "REF_PIN_NAME=~USRTCKINT[$interfaceindex]"
    set filter1_USRTCK "REF_PIN_NAME=~USRTCK[$interfaceindex]"
    set filter1_USRDRCK "REF_PIN_NAME=~USRDRCK[$interfaceindex]"
    set filter1_USRUPDATE "REF_PIN_NAME=~USRUPDATE[$interfaceindex]"
    create_clock -period 10.0 [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]

    if { $es1_part ne "0" } {

      create_generated_clock -source [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]] -divide_by 1 [get_pins -filter $filter1_USRTCK -of [get_cells -hierarchical $primitiveInst]]
      set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins -filter $filter1_USRTCK -of [get_cells -hierarchical $primitiveInst]]  ]
      create_waiver -internal -quiet -scoped -user pspmc -tags 12436 -type METHODOLOGY -id TIMING-54 -object [get_clocks -of_objects [get_pins -filter $filter1_USRTCK -of [get_cells -hierarchical $primitiveInst]]  ] -description "Avoid warning for valid TCK clock constraint"

      create_clock -period 10.0 [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]
      set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]  ]
      create_waiver -internal -quiet -scoped -user pspmc -tags 12436 -type METHODOLOGY -id TIMING-54 -object [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]  ] -description "Avoid warning for valid DRCK clock constraint"

      create_clock -period 20.0 [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]
      set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]  ]
      create_waiver -internal -quiet -scoped -user pspmc -tags 12436 -type METHODOLOGY -id TIMING-54 -object [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]  ] -description "Avoid warning for valid UPDATE clock constraint"
    } else {

      create_clock -period 10.0 [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]
      create_generated_clock -source [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]] -divide_by 2 [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]] 
      set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]

      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      #set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]

      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      #set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      set_clock_groups -logically_exclusive -group [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -group [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]

      set_multicycle_path 3 -setup -from [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_multicycle_path 2 -hold -end -from [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_multicycle_path 3 -setup -start -from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -to [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]]
      set_multicycle_path 2 -hold -from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -to [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -rise_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -fall_to [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]]
      set_false_path -fall_from [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -rise_to [get_clocks -of_objects [get_pins -filter $filter1_USRUPDATE -of [get_cells -hierarchical $primitiveInst]]]


      create_waiver -type METHODOLOGY -id {TIMING-6} -user "pspmc" -desc "Adding an exception as there is not timing arc for DRCK pin" -scope -internal -objects [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -objects [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      create_waiver -type METHODOLOGY -id {TIMING-7} -user "pspmc" -desc "Adding an exception as there is not timing arc for DRCK pin" -scope -internal -objects [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]] -objects [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]]
      create_waiver -type METHODOLOGY -id {TIMING-6} -user "pspmc" -desc "Adding an exception as there is not timing arc for DRCK pin" -scope -internal -objects [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -objects [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
      create_waiver -type METHODOLOGY -id {TIMING-7} -user "pspmc" -desc "Adding an exception as there is not timing arc for DRCK pin" -scope -internal -objects [get_clocks -of_objects [get_pins -filter $filter1_USRDRCK -of [get_cells -hierarchical $primitiveInst]]] -objects [get_clocks -of_objects [get_pins -filter $filter1_USRTCKINT -of [get_cells -hierarchical $primitiveInst]]]
    }
    if { $inst !="" } {
      current_instance -quiet
    }
  }
}
