
export SCRIPTS_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export CL_ROOT     = $(realpath $(SCRIPTS_DIR)/../..)

MEM_PATH              ?= $(CL_ROOT)/verif/data/rv32ui-p-add.x
MEM_PATH_BASE_NAME    ?= $(basename ${MEM_PATH})
LINE_COUNT            ?= $(shell echo `wc -l < $(MEM_PATH)`)
MEM_DEPTH             ?= 4096
VCD_FILE              ?= $(MEM_PATH_NOT_DIR:x=vcd)
HW_PROBE							?= 0


BUILD_DIR=${CL_ROOT}/build/output/

# Synthesis & implementation
${BUILD_DIR}/overlay.bit ${BUILD_DIR}/overlay_post_synth.v ${BUILD_DIR}/overlay_routed.v ${BUILD_DIR}/overlay.hwh&: \
	$(shell find ${CL_ROOT}/design/code/ -type f) \
	${CL_ROOT}/build/design/top.v \
	${CL_ROOT}/build/design/top_stub.v \
	${CL_ROOT}/build/design/imemory.v \
	${CL_ROOT}/build/design/dmemory.v \
	${CL_ROOT}/build/design/overlay-2018.3.tcl \
	${CL_ROOT}/build/design/overlay.tcl \
	${CL_ROOT}/build/scripts/generate-bitstream.tcl \
	${CL_ROOT}/build/scripts/pre-opt.tcl \
	${CL_ROOT}/build/scripts/debug.xdc
	mkdir -p ${BUILD_DIR}
	cd ${BUILD_DIR} && vivado -mode batch \
		-source ${CL_ROOT}/build/scripts/generate-bitstream.tcl \
		-tclargs "${CL_ROOT}" "${MEM_PATH}" "${MEM_DEPTH}" "${LINE_COUNT}" "${HW_PROBE}"

# Resource utilization estimation
${BUILD_DIR}/util_est.txt : $(shell find ${CL_ROOT}/design/code/ -type f) \
	$(shell find ${CL_ROOT}/design/code/ -type f) \
	$(shell find ${CL_ROOT}/build/design/ -type f) \
	${CL_ROOT}/build/scripts/estimate-resource-utilization.tcl 
	mkdir -p ${BUILD_DIR}
	vivado -mode batch -nojournal -nolog \
		-source ${CL_ROOT}/build/scripts/estimate-resource-utilization.tcl \
		-tclargs "${CL_ROOT}" "${MEM_PATH}" "${MEM_DEPTH}" "${LINE_COUNT}"

estimate-resource: ${BUILD_DIR}/util_est.txt

bitstream: ${BUILD_DIR}/overlay.bit ${BUILD_DIR}/overlay.hwh 

post-synth-sim: ${BUILD_DIR}/overlay_post_synth.v ${CL_ROOT}/build/scripts/post_synth.sh ${CL_ROOT}/build/design/tb.sv
	cd ${BUILD_DIR} && bash ${CL_ROOT}/build/scripts/post_synth.sh "${CL_ROOT}" "${MEM_PATH}" "${MEM_DEPTH}" "${LINE_COUNT}"

routed-sim: ${BUILD_DIR}/overlay_routed.v ${CL_ROOT}/build/scripts/post_routed.sh ${CL_ROOT}/build/design/tb.sv
	cd ${BUILD_DIR} && bash ${CL_ROOT}/build/scripts/post_routed.sh "${CL_ROOT}" "${MEM_PATH}" "${MEM_DEPTH}" "${LINE_COUNT}"

prepare:
	mkdir -p ${CL_ROOT}/build/to_pynq/
	cp ${BUILD_DIR}/overlay.* ${CL_ROOT}/build/to_pynq/
	cp ${CL_ROOT}/build/scripts/run.sh ${CL_ROOT}/build/to_pynq/
	cp ${CL_ROOT}/build/scripts/run_debug.sh ${CL_ROOT}/build/to_pynq/
	cp ${CL_ROOT}/build/scripts/run.py ${CL_ROOT}/build/to_pynq/
	cp ${MEM_PATH} ${CL_ROOT}/build/to_pynq/

check:
	ssh xilinx@192.168.2.99 "rm -rf /tmp/ece320_to_pynq/ && mkdir -p /tmp/ece320_to_pynq"
	scp -r ${CL_ROOT}/build/to_pynq/* xilinx@192.168.2.99:/tmp/ece320_to_pynq/
	ssh xilinx@192.168.2.99 "bash /tmp/ece320_to_pynq/run.sh $(shell basename "${MEM_PATH}")"
	scp -r xilinx@192.168.2.99:/tmp/ece320_to_pynq/$(shell basename $(basename ${MEM_PATH})).trace ${CL_ROOT}/build/scripts/
	@echo You should find your .trace file in ${CL_ROOT}/build/scripts/

check_debug:
	ssh xilinx@192.168.2.99 "rm -rf /tmp/ece320_to_pynq/ && mkdir -p /tmp/ece320_to_pynq"
	scp -r ${CL_ROOT}/build/to_pynq/* xilinx@192.168.2.99:/tmp/ece320_to_pynq/
	ssh -t xilinx@192.168.2.99 "bash /tmp/ece320_to_pynq/run_debug.sh $(shell basename "${MEM_PATH}") --debug"
	scp -r xilinx@192.168.2.99:/tmp/ece320_to_pynq/$(shell basename $(basename ${MEM_PATH})).trace ${CL_ROOT}/build/scripts/
	@echo You should find your .trace file in ${CL_ROOT}/build/scripts/

print_cl_root:
	@echo ${CL_ROOT}

package:
	make -C ${CL_ROOT}/verif/scripts package VERILATOR=1
	@echo "!!! The package is generated in ${CL_ROOT}/verif/scripts/package.verilator.tar.gz"

clean:
	rm -rf ${CL_ROOT}/build/output ${CL_ROOT}/build/to_pynq
