####################################################################################################
# HEADER_BEGIN
# COPYRIGHT NOTICE
# Copyright 2001-2022 Xilinx Inc. All Rights Reserved.
# http://www.xilinx.com/support
# HEADER_END
####################################################################################################

####################################################################################################
##
## Company:        Xilinx, Inc.
## Created by:     Frank Mueller
##
## Version:        2022.01.26
## Description:    This utility marks and highlights GTs, REFCLKs, HARD-IP and their connections
##
####################################################################################################

####################################################################################################
## 2022.01.26 - initial version
## 2023.01.16 - Ver 2 - Fix for CR-1129569 & CR-1122107 and support for CPM5N & HNICX
####################################################################################################

set hardBlocks {PCIE40E5 PCIE50E5 CPM5 DCMAC MRMAC ILKNF HSC VDU HNICX CPM5N}
set GT_QUADs {GTYE5_QUAD GTYP_QUAD GTME5_QUAD}
#array set markColor [list GTYE5_QUAD {185 45 190} GTYP_QUAD {0 0 255} GTME5_QUAD {0 255 255} PCIE50E5 {255 0 0} CPM5 {255 0 255} DCMAC {255 200 0} MRMAC {255 255 0} ILKNF {14 173 0} HSC {204 204 255}]
#GT_QUAD
set GT_QUAD_COLOR red
set HARD_IP_COLOR blue
array set markColor [list GTYE5_QUAD $GT_QUAD_COLOR GTYP_QUAD $GT_QUAD_COLOR GTME5_QUAD $GT_QUAD_COLOR PCIE40E5 $HARD_IP_COLOR PCIE50E5 $HARD_IP_COLOR CPM5 $HARD_IP_COLOR DCMAC $HARD_IP_COLOR MRMAC $HARD_IP_COLOR ILKNF $HARD_IP_COLOR HSC $HARD_IP_COLOR HNICX $HARD_IP_COLOR  CPM5N $HARD_IP_COLOR]
set op "mark"

#set RefCLkColor {0 255 0}; #green
set RefCLkColor green; #green

proc IS_GT_QUAD {cells} {
    if {[filter $cells PRIMITIVE_SUBGROUP==GT] > 0} {return 1} else {return 0} 
}

proc get_GT_QUAD_cells {{cells ""}} {
    if {$cells == ""} {return [get_cells -hier -filter PRIMITIVE_SUBGROUP==GT]} else {return [filter $cells PRIMITIVE_SUBGROUP==GT]} 
}

proc getRefClkIBuf {cells} {
    set REFCLKPins HSCLK?_*PLL*REFCLK?
    set IBUFDS_GT [get_cells -quiet -of [get_pins -leaf -of [get_nets -of [get_pins -of [filter $cells REF_NAME=~GT*QUAD] -filter REF_PIN_NAME=~$REFCLKPins] ] -filter DIRECTION==OUT] -filter REF_NAME=~IBUFDS_GT*]
    return $IBUFDS_GT
}

proc markRefClkIBuf {cells} {
    global RefCLkColor
	global op
    if {[getRefClkIBuf $cells] != ""} {
		if {$op eq "mark"} {
			mark_objects [getRefClkIBuf $cells] -color $RefCLkColor
		} elseif {$op eq "unmark"} {
			unmark_objects [getRefClkIBuf $cells] 
		}
    }
    
}

proc markRefClkPorts {cells} {
    global RefCLkColor
	global op
	    foreach cell $cells {
        if {[getRefClkIBuf $cell] != ""} {
			if {$op eq "mark"} {
				mark_objects [get_ports -of [getRefClkIBuf $cell] ] -color $RefCLkColor
			} elseif {$op eq "unmark"} {
				unmark_objects  [get_ports -of [getRefClkIBuf $cell] ]
			}
        }
    }
    
}
proc highLightRefClkNet {cells} {
    global RefCLkColor
	global op
    foreach cell $cells {
        if {[getRefClkIBuf $cell] != ""} {
			if {$op eq "mark"} {
				highlight_objects [get_nets -of [get_pins -of [getRefClkIBuf $cell] -filter REF_PIN_NAME==O]] -color $RefCLkColor
			} elseif {$op eq "unmark"} {
				unhighlight_objects [get_nets -of [get_pins -of [getRefClkIBuf $cell] -filter REF_PIN_NAME==O]] 
			}
        }
    }
    
}

proc getConnectedHardIP {dataNet} {
    
    if {[get_cells -of [get_pins -leaf -of $dataNet -filter DIRECTION==IN] -filter PRIMITIVE_SUBGROUP==GT] != ""} {
        #TX
        set hardIP [get_cells -of [get_pins -leaf -of $dataNet -filter DIRECTION==OUT]]
    } elseif {[get_cells -of [get_pins -leaf -of $dataNet -filter DIRECTION==OUT] -filter PRIMITIVE_SUBGROUP==GT] != ""} {
        #RX
        set hardIP [get_cells -of [get_pins -leaf -of $dataNet -filter DIRECTION==IN]]
    }
    return $hardIP
    
}

proc highLightTXRXData {GT_QUADs hardIP} {
    # puts $GT_QUADs
    # puts $hardIP
    global markColor
	global op
    foreach GT_QUAD $GT_QUADs {
        set TXDataNets [get_nets -of [get_pins -of $GT_QUAD -filter REF_PIN_NAME=~CH*_TXDATA[*]] -filter TYPE=~SIGNAL]
		set hardIPPins [get_pins -quiet -leaf -of $TXDataNets -filter DIRECTION==OUT&&NAME=~${hardIP}/*]
		if {$hardIPPins != ""} {
			if {$op eq "mark"} {
				highlight_objects [lindex [get_nets -of $hardIPPins] 0] -color $markColor([get_property REF_NAME $hardIP])
			} elseif {$op eq "unmark"} {
				unhighlight_objects [lindex [get_nets -of $hardIPPins] 0] 
			}
		}
    }
   
}

proc markAllHardIPs {} {
    global hardBlocks
    global markColor
    global GT_QUAD_COLOR
    global GT_QUADs
	global op

	set GT_QUADCells [get_cells -hier -filter PRIMITIVE_SUBGROUP==GT]
	if {$GT_QUADCells != ""} {
		# puts is_gt_quad
		# puts $GT_QUADCells
		if {$op eq "mark"} {
			mark_objects $GT_QUADCells -color $GT_QUAD_COLOR
		} elseif {$op eq "unmark"} {
			unmark_objects $GT_QUADCells 
		}
		markRefClkIBuf $GT_QUADCells
		markRefClkPorts $GT_QUADCells
		highLightRefClkNet $GT_QUADCells
		foreach hardIP $hardBlocks {
			set hardIPCell [get_cells -quiet -hier -filter REF_NAME=~${hardIP}]
			if {$hardIPCell != ""} {
				# puts $hardIP
				# puts $hardIPCell
				if {$op eq "mark"} {
					mark_objects $hardIPCell -color $markColor($hardIP)
				} elseif {$op eq "unmark"} {
					unmark_objects $hardIPCell 
				}
				highLightTXRXData $GT_QUADCells $hardIPCell
			}
		}
	}
}   

proc markSelHardIPs {} {
    global hardBlocks
    global markColor
    global GT_QUAD_COLOR
    global GT_QUADs
	global op
	
	set selection [get_selected_objects]
	set GT_QUADCells [filter $selection PRIMITIVE_SUBGROUP==GT]
	if {$GT_QUADCells != ""} {
		# puts is_gt_quad
		# puts $GT_QUADCells
		if {$op eq "mark"} {
			mark_objects $GT_QUADCells -color $GT_QUAD_COLOR
		} elseif {$op eq "unmark"} {
			unmark_objects $GT_QUADCells 
		}
		markRefClkIBuf $GT_QUADCells
		highLightRefClkNet $GT_QUADCells
		foreach hardIP $hardBlocks {
			set hardIPCell [filter $selection REF_NAME=~${hardIP}]
			if {$hardIPCell != ""} {
				# puts $hardIP
				# puts $hardIPCell
				if {$op eq "mark"} {
					mark_objects $hardIPCell -color $markColor($hardIP)
				} elseif {$op eq "unmark"} {
					unmark_objects $hardIPCell 
				}
				highLightTXRXData $GT_QUADCells $hardIPCell
			}
		}
	}
}   


# for marking
#set op "mark"
# for unmarking
#set op "unmark"
#markSelHardIPs

set op "mark"
markAllHardIPs
