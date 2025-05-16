set cl_root [lindex $argv 0]
set mem_path [lindex $argv 1]
set mem_depth [lindex $argv 2]
set line_count [lindex $argv 3]
source common.tcl
create_project -in_memory -part $part
set_property board_part $board_part [current_project]

add_design_files $cl_root
add_files $cl_root/build/design/top.v

# synthesize the design only
synth_design -flatten_hierarchy rebuilt -mode out_of_context -top top \
	-verilog_define "MEM_PATH=\"$mem_path\"" \
	-verilog_define "MEM_DEPTH=$mem_depth" \
	-verilog_define "LINE_COUNT=$line_count"

report_utilization -force -file $cl_root/build/output/util_est.txt
report_utilization -hierarchical -force -file $cl_root/build/output/util_est_hier.txt
