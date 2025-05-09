################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name s_axis_aclk -period 10 [get_ports s_axis_aclk]
create_clock -name s_axi_aclk -period 10 [get_ports s_axi_aclk]
create_clock -name m_axi_aclk -period 10 [get_ports m_axi_aclk]

################################################################################