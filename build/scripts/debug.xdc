# This file contains an example of how you can add a debug probe for the probe `F_PC
# You should not modify code blocks guarded by DO NOT EDIT, doing so could result in incorrect generation of debug probe


###############
# DO NOT EDIT #
###############
# create the debug core (and dbg_hub automatically)
create_debug_core u_ila_0 ila


###############
# DO NOT EDIT #
###############
# some fixed parameter that is used in the dialog
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]


# The 1024 refers to the number of clock cycles you want per capture, it should be 1024 at minimum and should be a power of 2, for example, 2048 or 4096
# Increasing this number consumes hardware resources
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]

###############
# DO NOT EDIT #
###############
# these parameters may affect timing
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]

###############
# DO NOT EDIT #
###############
# Setup the clock for u_ila_0
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list overlay_i/top_design/clk ]]

####################
# START OF ONE PROBE
####################
# create actual probe
# each block of code corresponds to a signal that you want to probe
# probes have the name probe0, probe1 etc, the counter is incremented whenever create_debug_port is called
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# specify the width of the signal
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [ get_nets  [ list \
  {overlay_i/top_design/inst/F_PC[0]} \
  {overlay_i/top_design/inst/F_PC[1]} \
  {overlay_i/top_design/inst/F_PC[2]} \
  {overlay_i/top_design/inst/F_PC[3]} \
  {overlay_i/top_design/inst/F_PC[4]} \
  {overlay_i/top_design/inst/F_PC[5]} \
  {overlay_i/top_design/inst/F_PC[6]} \
  {overlay_i/top_design/inst/F_PC[7]} \
  {overlay_i/top_design/inst/F_PC[8]} \
  {overlay_i/top_design/inst/F_PC[9]} \
  {overlay_i/top_design/inst/F_PC[10]} \
  {overlay_i/top_design/inst/F_PC[11]} \
  {overlay_i/top_design/inst/F_PC[12]} \
  {overlay_i/top_design/inst/F_PC[13]} \
  {overlay_i/top_design/inst/F_PC[14]} \
  {overlay_i/top_design/inst/F_PC[15]} \
  {overlay_i/top_design/inst/F_PC[16]} \
  {overlay_i/top_design/inst/F_PC[17]} \
  {overlay_i/top_design/inst/F_PC[18]} \
  {overlay_i/top_design/inst/F_PC[19]} \
  {overlay_i/top_design/inst/F_PC[20]} \
  {overlay_i/top_design/inst/F_PC[21]} \
  {overlay_i/top_design/inst/F_PC[22]} \
  {overlay_i/top_design/inst/F_PC[23]} \
  {overlay_i/top_design/inst/F_PC[24]} \
  {overlay_i/top_design/inst/F_PC[25]} \
  {overlay_i/top_design/inst/F_PC[26]} \
  {overlay_i/top_design/inst/F_PC[27]} \
  {overlay_i/top_design/inst/F_PC[28]} \
  {overlay_i/top_design/inst/F_PC[29]} \
  {overlay_i/top_design/inst/F_PC[30]} \
  {overlay_i/top_design/inst/F_PC[31]} ]
]
##################
# END OF ONE PROBE
##################
# REMEMBER THIS LINE
create_debug_port u_ila_0 probe  

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [ get_nets overlay_i/top_design/inst/rst_reg ]


########################
# Here goes other probes
########################


# # Call creat_debug_port to add a new probe
# create_debug_port u_ila_0 probe

###############
# DO NOT EDIT #
###############
# Something for the debug hub
# when you create u_ila_0, the dbg_hub is created as well
# these parts should be constant
set_property C_CLK_INPUT_FREQ_HZ 50000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER true [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets [list overlay_i/top_design/clk ]]


