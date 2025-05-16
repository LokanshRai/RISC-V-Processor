set cl_root [lindex $argv 0]
set mem_path [lindex $argv 1]
set mem_depth [lindex $argv 2]
set line_count [lindex $argv 3]
set hw_probe [lindex $argv 4]
source $cl_root/build/scripts/common.tcl
create_project -in_memory -part $part
set_property board_part $board_part [current_project]

# open_checkpoint $cl_root/build/output/overlay_bb.dcp
# add_files $cl_root/build/output/imemory.dcp
add_design_files $cl_root

set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

if { $v == "2022.1" } {
  source $cl_root/build/design/overlay.tcl
} elseif { $v == "2018.3" } {
  # for legacy support
  source $cl_root/build/design/overlay-2018.3.tcl
}
generate_target all [get_files overlay.bd ]
if { $v == "2022.1" } {
	file copy -force ${cl_root}/build/output/.gen/sources_1/bd/overlay/hw_handoff/overlay.hwh ${cl_root}/build/output/
} elseif { $v == "2018.3" } {
  file copy -force ${cl_root}/build/output/.srcs/sources_1/bd/overlay/hw_handoff/overlay.hwh ${cl_root}/build/output/
}

add_files $cl_root/build/design/top.v
if { $v == "2022.1" } {
  add_files $cl_root/build/output/.gen/sources_1/bd/overlay/hdl/overlay_wrapper.v
} elseif { $v == "2018.3" } {
  # 2018.3 has a different project structure
  # add_files $cl_root/build/output/.gen/sources_1/bd/overlay/hdl/overlay_wrapper.v
  add_files $cl_root/build/output/.srcs/sources_1/bd/overlay/hdl/overlay_wrapper.v
  # add_files $cl_root/build/output/.srcs/sources_1/bd/overlay/hw_handoff/overlay.hwh
}


# synth_design -flatten_hierarchy rebuilt -top overlay_wrapper 
synth_design -flatten_hierarchy rebuilt -top overlay_wrapper \
	-verilog_define "MEM_PATH=\"$mem_path\"" \
	-verilog_define "MEM_DEPTH=$mem_depth" \
	-verilog_define "LINE_COUNT=$line_count"

write_checkpoint -force overlay_post_synth.dcp
write_verilog -force overlay_post_synth.v

####
# exit
####

if { $hw_probe != "0" } {
  source $cl_root/build/scripts/pre-opt.tcl
}


opt_design -directive ExploreArea

place_design

route_design

report_utilization -hierarchical -hierarchical_depth 10 -file util.txt
write_checkpoint -force overlay_routed.dcp
write_verilog -force overlay_routed.v

####
# exit
####

set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]

if { $pass == 1 } {
	puts "======= Timing met ======="
} else {
	puts "!!!!!!! Timing failed !!!!!!!"
	exit
}

write_bitstream -force overlay.bit
if { $hw_probe != "0" } {
  write_debug_probes -force overlay.ltx
}
