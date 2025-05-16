set -e
cl_root=$1
mem_path=$2
mem_depth=$3
line_count=$4
v=$(vivado -version | head -n 1 | cut -d ' ' -f 2)
v=${v:1:6}


build_dir=$cl_root/build/output
xvlog $build_dir/overlay_routed.v
if [ "$v" = "2022.1" ]; then
xvlog $build_dir/.gen/sources_1/bd/overlay/sim/overlay.v
elif [ "$v" = "2018.3" ]; then
xvlog $build_dir/.srcs/sources_1/bd/overlay/sim/overlay.v
fi
xvlog -sv $cl_root/build/design/tb.sv  -d MEM_PATH=\"$mem_path\" -d MEM_DEPTH=$mem_depth -d LINE_COUNT=$line_count
xvlog  $cl_root/build/design/glbl.v
xelab -relax -debug typical tb -L uvm -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip --snapshot tb glbl
xsim tb -t $cl_root/build/scripts/xsim.tcl
