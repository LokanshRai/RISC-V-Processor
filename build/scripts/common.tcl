# add search path for board files
set_param board.repoPaths [list "$cl_root/build/board_files/" ]
set part xc7z020clg400-1
set board_part "www.digilentinc.com:pynq-z1:part0:1.0"
puts "cl_root: $cl_root"

proc add_design_files_from_list { filename cl_root } {
  set result {}
  set f [open $filename r]
  foreach line [split [read $f] \n] {
    if {([string trim $line] != "") && ([string trim $line] != "imemory.v") && ([string trim $line] != "dmemory.v")} {
      lappend result $cl_root/design/code/$line
    }
  }
  return $result
}

proc add_design_files { cl_root } {
	add_files "$cl_root/build/design/imemory.v" "$cl_root/build/design/dmemory.v" "$cl_root/design/design_wrapper.v" "$cl_root/build/design/top_stub.v" "$cl_root/design/signals.h" [ add_design_files_from_list "$cl_root/verif/scripts/design.f" "$cl_root" ] 
	# add_files -fileset sim_1 [ add_design_files_from_list "$cl_root/verif/scripts/design.f" "$cl_root" ] "$cl_root/design/design_wrapper.v" "$cl_root/build/design/top.v" "$cl_root/design/signals.h"
	# add_files -fileset sources_1 [ add_design_files_from_list "$cl_root/verif/scripts/design.f" "$cl_root" ] "$cl_root/design/design_wrapper.v" "$cl_root/build/design/top.v" "$cl_root/design/signals.h"
}

set v [version -short]
if { $v != "2022.1" && $v != "2018.3" } {
  error "Only Vivado 2022.1 and Vivado 2018.3 are supported"
}
