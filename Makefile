VCOM = vcom
VCOM_OPT = -quiet -explicit -O0 -93
VCOM_WORK = -work

WORK_DIR = ./work
GHDL = ghdl
GHDL_ARGS = -g --workdir=${WORK_DIR}
GHDL_RUN_ARGS = --vcd=

WAVE_READER = gtkwave

all:
	make reg_file_all
	make mul_all
	make div_all
	make alu_all
	make decode_stage_all

work_dir:
	mkdir -p ${WORK_DIR}

libraries: 
	@echo "Analysing proc_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} proc_pkg.vhd
	@echo "Analysing alu_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} alu_pkg.vhd
	@echo "Analysing reg_file_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file_pkg.vhd
	@echo "Analysing pipeline_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} pipeline_pkg.vhd
	@echo "Analysing tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} tb_pkg.vhd

reg_file: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/reg_file_pkg.o
	@echo "Analysing reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file.vhd
	@echo "Analysing reg_file_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file_tb.vhd
	@echo "Elaborating reg_file_tb"
	${GHDL} -e ${GHDL_ARGS} reg_file_tb
	rm -r e~reg_file_tb.o
	mv reg_file_tb ${WORK_DIR}

simulate_reg_file: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/reg_file_pkg.o ${WORK_DIR}/reg_file.o ${WORK_DIR}/reg_file_tb.o
	cd ${WORK_DIR} && ${GHDL} -r reg_file_tb ${GHDL_RUN_ARGS}reg_file.vcd

reg_file_all:
	make work_dir
	make libraries
	make reg_file
	make simulate_reg_file

alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing alu.vhd"
	${GHDL} -a ${GHDL_ARGS} alu.vhd
	@echo "Analysing alu_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} alu_tb.vhd
	@echo "Elaborating alu_tb"
	${GHDL} -e ${GHDL_ARGS} alu_tb
	rm -r e~alu_tb.o
	mv alu_tb ${WORK_DIR}

simulate_alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/alu.o ${WORK_DIR}/alu_tb.o
	cd ${WORK_DIR} &&  ${GHDL} -r alu_tb ${GHDL_RUN_ARGS}alu.vcd

alu_all:
	make work_dir
	make libraries
	make alu
	make simulate_alu

mul: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing mul.vhd"
	${GHDL} -a ${GHDL_ARGS} mul.vhd
	@echo "Analysing mul_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} mul_tb.vhd
	@echo "Analysing mul_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} mul_cfg.vhd
	@echo "Elaborating mul_tb"
	${GHDL} -e ${GHDL_ARGS} mul_tb
	rm -r e~mul_tb.o
	mv mul_tb ${WORK_DIR}

simulate_mul: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/mul.o ${WORK_DIR}/mul_cfg.o ${WORK_DIR}/mul_tb.o
	cd ${WORK_DIR} && ${GHDL} -r mul_tb ${GHDL_RUN_ARGS}mul.vcd

mul_all:
	make work_dir
	make libraries
	make mul
	make simulate_mul


div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing div.vhd"
	${GHDL} -a ${GHDL_ARGS} div.vhd
	@echo "Analysing div_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} div_tb.vhd
	@echo "Analysing div_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} div_cfg.vhd
	@echo "Elaborating div_tb"
	${GHDL} -e ${GHDL_ARGS} div_tb
	rm -r e~div_tb.o
	mv div_tb ${WORK_DIR}

simulate_div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/div.o ${WORK_DIR}/div_cfg.o ${WORK_DIR}/div_tb.o
	cd ${WORK_DIR} && ${GHDL} -r div_tb ${GHDL_RUN_ARGS}div.vcd

div_all:
	make work_dir
	make libraries
	make div
	make simulate_div

decode_stage: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/pipeline_pkg.o
	@echo "Analysing decode.vhd"
	${GHDL} -a ${GHDL_ARGS} decode.vhd
	@echo "Analysing decode_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} decode_tb.vhd
	@echo "Elaborating decode_stage_tb"
	${GHDL} -e ${GHDL_ARGS} decode_stage_tb
	rm -r e~decode_stage_tb.o
	mv decode_stage_tb ${WORK_DIR}

simulate_decode_stage: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/pipeline_pkg.o ${WORK_DIR}/decode.o ${WORK_DIR}/decode_tb.o
	cd ${WORK_DIR} && ${GHDL} -r decode_stage_tb ${GHDL_RUN_ARGS}decode.vcd

decode_stage_all:
	make work_dir
	make libraries
	make decode_stage
	make simulate_decode_stage
