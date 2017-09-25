VCOM = vcom
VCOM_OPT = -quiet -explicit -O0 -93
VCOM_WORK = -work

ROOT_DIR = .
SRC_DIR = ${ROOT_DIR}/src
COMMON_SRC_DIR = ${SRC_DIR}/common
COMMON_RTL_DIR = ${COMMON_SRC_DIR}/rtl
COMMON_RTL_PKG_DIR = ${COMMON_SRC_DIR}/pkg
COMMON_RTL_CFG_DIR = ${COMMON_SRC_DIR}/cfg
CPU_SRC_DIR = ${SRC_DIR}/cpu
CPU_RTL_DIR = ${CPU_SRC_DIR}/rtl
CPU_RTL_PKG_DIR = ${CPU_SRC_DIR}/pkg
CPU_RTL_CFG_DIR = ${CPU_SRC_DIR}/cfg
DDR2_SRC_DIR = ${SRC_DIR}/ddr2
DDR2_RTL_DIR = ${DDR2_SRC_DIR}/rtl
DDR2_RTL_PKG_DIR = ${DDR2_SRC_DIR}/pkg
DDR2_RTL_CFG_DIR = ${DDR2_SRC_DIR}/cfg

VERIF_DIR = ${ROOT_DIR}/verif
COMMON_VERIF_DIR = ${VERIF_DIR}/common
COMMON_VERIF_TB_DIR = ${COMMON_VERIF_DIR}/tb
COMMON_VERIF_PKG_DIR = ${COMMON_VERIF_DIR}/pkg
COMMON_VERIF_MODELS_DIR = ${COMMON_VERIF_DIR}/models
CPU_VERIF_DIR = ${VERIF_DIR}/cpu
CPU_VERIF_TB_DIR = ${CPU_VERIF_DIR}/tb
CPU_VERIF_PKG_DIR = ${CPU_VERIF_DIR}/pkg
CPU_VERIF_MODELS_DIR = ${CPU_VERIF_DIR}/models
DDR2_VERIF_DIR = ${VERIF_DIR}/ddr2
DDR2_VERIF_TB_DIR = ${DDR2_VERIF_DIR}/tb
DDR2_VERIF_PKG_DIR = ${DDR2_VERIF_DIR}/pkg
DDR2_VERIF_MODELS_DIR = ${DDR2_VERIF_DIR}/models

WAVES_DIR = /tmp

WORK_DIR = ${ROOT_DIR}/work
GHDL = ghdl
GHDL_ARGS = -g --workdir=${WORK_DIR}
GHDL_RUN_ARGS = --vcd=${WAVES_DIR}/

LOG_FILES = ${WORK_DIR}/*.log
SUMMARY_FILE = ${WORK_DIR}/summary

WAVE_READER = gtkwave

all:
	make clean
	make all_common
	make all_cpu
	make all_ddr2

all_common:
	make fifo_1clk_all
	make arbiter_all

all_cpu:
	make reg_file_all
	make mul_all
	make div_all
	make alu_all
	make decode_stage_all
	make ctrl_all
	make icache_all
	make dcache_all
	make execute_all
	make execute_dcache_all

all_ddr2:
	make ddr2_phy_init_all
	make ddr2_phy_bank_ctrl_all
	make ddr2_phy_col_ctrl_all
	make ddr2_phy_ref_ctrl_all
	make ddr2_phy_cmd_ctrl_all
	make ddr2_phy_odt_ctrl_all
	make ddr2_phy_mrs_ctrl_all
	make ddr2_phy_cmd_dec_all
	make ddr2_phy_arbiter_all

clean:
	rm -rf ${LOG_FILES} ${SUMMARY_FILE} ${WORK_DIR}/*

work_dir:
	mkdir -p ${WORK_DIR}

common_rtl_libraries: 
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/type_conversion_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/type_conversion_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/bram_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/bram_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/functions_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/functions_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/arbiter_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/arbiter_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/fifo_1clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/fifo_1clk_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/fifo_2clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/fifo_2clk_pkg.vhd

ddr2_rtl_libraries:
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_define_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_define_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_mrs_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_mrs_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_init_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_init_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_bank_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_bank_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_col_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_col_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_ref_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_ref_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_cmd_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_cmd_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_arbiter_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_arbiter_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_cmd_dec_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_cmd_dec_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_odt_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_odt_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_RTL_PKG_DIR}/ddr2_phy_mrs_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_PKG_DIR}/ddr2_phy_mrs_ctrl_pkg.vhd

cpu_rtl_libraries:
	@echo "Analysing ${CPU_RTL_PKG_DIR}/proc_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/proc_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/alu_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/alu_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/ctrl_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/reg_file_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/reg_file_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/decode_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/decode_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/execute_dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/execute_dcache_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/execute_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/execute_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/icache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/icache_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_PKG_DIR}/dcache_pkg.vhd

common_verif_libraries:
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/shared_tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/shared_tb_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/functions_tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/functions_tb_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/common_log_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/common_log_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/common_tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/common_tb_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/mem_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/mem_model_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/fifo_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/fifo_pkg_tb.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/ddr2_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/ddr2_model_pkg.vhd

cpu_verif_libraries:
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/alu_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/alu_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/reg_file_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/reg_file_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/ctrl_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/ctrl_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/execute_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/execute_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/decode_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/decode_pkg_tb.vhd

ddr2_verif_libraries:
	@echo "Analysing ${DDR2_VERIF_PKG_DIR}/ddr2_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_PKG_DIR}/ddr2_pkg_tb.vhd

common_libraries:
	make common_rtl_libraries
	make common_verif_libraries

cpu_libraries:
	make cpu_rtl_libraries
	make cpu_verif_libraries

ddr2_libraries:
	make ddr2_rtl_libraries
	make ddr2_verif_libraries

reg_file: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/reg_file_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}reg_file_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/reg_file_tb.vhd
	@echo "Elaborating reg_file_tb"
	${GHDL} -e ${GHDL_ARGS} reg_file_tb
	rm -r e~reg_file_tb.o
	mv reg_file_tb ${WORK_DIR}

simulate_reg_file: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/reg_file_pkg.o ${WORK_DIR}/reg_file.o ${WORK_DIR}/reg_file_tb.o
	cd ${WORK_DIR} && ${GHDL} -r reg_file_tb ${GHDL_RUN_ARGS}reg_file.vcd

reg_file_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make reg_file
	make simulate_reg_file

alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/alu_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/alu_tb.vhd
	@echo "Elaborating alu_tb"
	${GHDL} -e ${GHDL_ARGS} alu_tb
	rm -r e~alu_tb.o
	mv alu_tb ${WORK_DIR}

simulate_alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/alu.o ${WORK_DIR}/alu_tb.o
	cd ${WORK_DIR} &&  ${GHDL} -r alu_tb ${GHDL_RUN_ARGS}alu.vcd

alu_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make alu
	make simulate_alu

mul: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/mul_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/mul_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/mul_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/mul_cfg.vhd
	@echo "Elaborating mul_cfg"
	${GHDL} -e ${GHDL_ARGS} config_mul
	rm -r e~config_mul.o
	mv config_mul ${WORK_DIR}

simulate_mul: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/mul.o ${WORK_DIR}/mul_cfg.o ${WORK_DIR}/mul_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_mul ${GHDL_RUN_ARGS}mul.vcd

mul_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make mul
	make simulate_mul


div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/div_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/div_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/div_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/div_cfg.vhd
	@echo "Elaborating div_cfg"
	${GHDL} -e ${GHDL_ARGS} config_div
	rm -r e~config_div.o
	mv config_div ${WORK_DIR}

simulate_div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/div.o ${WORK_DIR}/div_cfg.o ${WORK_DIR}/div_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_div ${GHDL_RUN_ARGS}div.vcd

div_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make div
	make simulate_div

decode_stage: ${WORK_DIR}/decode_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/decode.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/decode.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/decode_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/decode_tb.vhd
	@echo "Elaborating decode_stage_tb"
	${GHDL} -e ${GHDL_ARGS} decode_stage_tb
	rm -r e~decode_stage_tb.o
	mv decode_stage_tb ${WORK_DIR}

simulate_decode_stage: ${WORK_DIR}/decode_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/decode.o ${WORK_DIR}/decode_tb.o
	cd ${WORK_DIR} && ${GHDL} -r decode_stage_tb ${GHDL_RUN_ARGS}decode.vcd

decode_stage_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make decode_stage
	make simulate_decode_stage

ctrl: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/ctrl_tb.vhd
	@echo "Elaborating ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ctrl_tb
	rm -r e~ctrl_tb.o
	mv ctrl_tb ${WORK_DIR}

simulate_ctrl: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl.o ${WORK_DIR}/ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ctrl_tb ${GHDL_RUN_ARGS}ctrl.vcd

ctrl_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make ctrl
	make simulate_ctrl

execute: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${COMMON_VERIF_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_RTL_DIR}/execute.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/execute.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/execute_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/execute_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/execute_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/execute_cfg.vhd
	@echo "Elaborating execute_cfg"
	${GHDL} -e ${GHDL_ARGS} config_execute
	rm -r e~config_execute.o
	mv config_execute ${WORK_DIR}

simulate_execute: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_pkg.o ${WORK_DIR}/execute.o  ${WORK_DIR}/execute_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_execute ${GHDL_RUN_ARGS}execute.vcd

execute_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make execute
	make simulate_execute

icache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${CPU_RTL_DIR}/icache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/icache.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/icache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/icache_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/icache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/icache_cfg.vhd
	@echo "Elaborating icache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_icache
	rm -r e~config_icache.o
	mv config_icache ${WORK_DIR}

simulate_icache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/icache_pkg.o ${WORK_DIR}/icache.o  ${WORK_DIR}/icache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_icache ${GHDL_RUN_ARGS}icache.vcd

icache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make icache
	make simulate_icache

dcache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${CPU_RTL_DIR}/dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/dcache.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/dcache_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd
	@echo "Elaborating dcache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_dcache
	rm -r e~config_dcache.o
	mv config_dcache ${WORK_DIR}

simulate_dcache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/dcache_pkg.o ${WORK_DIR}/dcache.o  ${WORK_DIR}/dcache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_dcache ${GHDL_RUN_ARGS}dcache.vcd

dcache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make dcache
	make simulate_dcache

execute_dcache: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_dcache_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${CPU_RTL_DIR}/dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/dcache.vhd
	@echo "Analysing ${COMMON_VERIF_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_RTL_DIR}/execute_dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_DIR}/execute_dcache.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/execute_dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_VERIF_TB_DIR}/execute_dcache_tb.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/execute_dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${CPU_RTL_CFG_DIR}/execute_dcache_cfg.vhd
	@echo "Elaborating execute_dcache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_execute_dcache
	rm -r e~config_execute_dcache.o
	mv config_execute_dcache ${WORK_DIR}

simulate_execute_dcache: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_dcache_pkg.o ${WORK_DIR}/execute_dcache.o  ${WORK_DIR}/execute_dcache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_execute_dcache ${GHDL_RUN_ARGS}execute_dcache.vcd

execute_dcache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make execute_dcache
	make simulate_execute_dcache

arbiter: ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/arbiter_pkg.o

	@echo "Analysing ${COMMON_RTL_DIR}/arbiter.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/arbiter.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/arbiter_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/arbiter_tb.vhd
	@echo "Elaborating arbiter_tb"
	${GHDL} -e ${GHDL_ARGS} arbiter_tb
	rm -r e~arbiter_tb.o
	mv arbiter_tb ${WORK_DIR}

simulate_arbiter: ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/arbiter.o ${WORK_DIR}/arbiter_pkg.o ${WORK_DIR}/arbiter_tb.o
	cd ${WORK_DIR} && ${GHDL} -r arbiter_tb ${GHDL_RUN_ARGS}arbiter.vcd

arbiter_all:
	make work_dir
	make common_libraries
	make arbiter
	make simulate_arbiter

fifo_1clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/bram_pkg.o ${WORK_DIR}/fifo_1clk_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_1clk.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_1clk.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/fifo_1pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/fifo_1clk_tb.vhd
	@echo "Analysing ${COMMON_RTL_CFG_DIR}/fifo_1clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_CFG_DIR}/fifo_1clk_cfg.vhd
	@echo "Elaborating fifo_1clk_cfg"
	${GHDL} -e ${GHDL_ARGS} config_fifo_1clk
	rm -r e~config_fifo_1clk.o
	mv config_fifo_1clk ${WORK_DIR}

simulate_fifo_1clk: ${WORK_DIR}/fifo_pkg_tb.o  ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/fifo_1clk_pkg.o ${WORK_DIR}/fifo_1clk.o  ${WORK_DIR}/fifo_1clk_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_fifo_1clk ${GHDL_RUN_ARGS}fifo_1clk.vcd

fifo_1clk_all:
	make work_dir
	make common_libraries
	make fifo_1clk
	make simulate_fifo_1clk

fifo_2clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/bram_pkg.o ${WORK_DIR}/fifo_2clk_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/gray_cnt.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/gray_cnt.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_ctrl.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_2clk.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_2clk.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/fifo_2pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/fifo_2clk_tb.vhd
	@echo "Analysing ${COMMON_RTL_CFG_DIR}/fifo_2clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${COMMON_RTL_CFG_DIR}/fifo_2clk_cfg.vhd
	@echo "Elaborating fifo_2clk_cfg"
	${GHDL} -e ${GHDL_ARGS} config_fifo_2clk
	rm -r e~config_fifo_2clk.o
	mv config_fifo_2clk ${WORK_DIR}

simulate_fifo_2clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/functions_tb_pkg.o ${WORK_DIR}/common_log_pkg.o ${WORK_DIR}/common_tb_pkg.o ${WORK_DIR}/shared_tb_pkg.o ${WORK_DIR}/fifo_2clk_pkg.o ${WORK_DIR}/fifo_2clk.o  ${WORK_DIR}/fifo_2clk_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_fifo_2clk ${GHDL_RUN_ARGS}fifo_2clk.vcd

fifo_2clk_all:
	make work_dir
	make common_libraries
	make fifo_2clk
	make simulate_fifo_2clk

ddr2_phy_init: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_init.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_init.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_init_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_init_tb.vhd
	@echo "Elaborating ddr2_phy_init_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_init_tb
	rm -r e~ddr2_phy_init_tb.o
	mv ddr2_phy_init_tb ${WORK_DIR}

simulate_ddr2_phy_init: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_phy_init.o  ${WORK_DIR}/ddr2_phy_init_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_init_tb ${GHDL_RUN_ARGS}ddr2_phy_init.vcd

ddr2_phy_init_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_init
	make simulate_ddr2_phy_init

ddr2_phy_bank_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_bank_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_bank_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_bank_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_bank_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_bank_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_bank_ctrl_tb
	rm -r e~ddr2_phy_bank_ctrl_tb.o
	mv ddr2_phy_bank_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_bank_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl.o  ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_bank_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_bank_ctrl.vcd

ddr2_phy_bank_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_bank_ctrl
	make simulate_ddr2_phy_bank_ctrl

ddr2_phy_col_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_col_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_col_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_col_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_col_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_col_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_col_ctrl_tb
	rm -r e~ddr2_phy_col_ctrl_tb.o
	mv ddr2_phy_col_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_col_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl.o  ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_col_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_col_ctrl.vcd

ddr2_phy_col_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_col_ctrl
	make simulate_ddr2_phy_col_ctrl

ddr2_phy_ref_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_ref_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_ref_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_ref_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_ref_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_ref_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_ref_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_ref_ctrl_tb
	rm -r e~ddr2_phy_ref_ctrl_tb.o
	mv ddr2_phy_ref_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_ref_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_ref_ctrl.o  ${WORK_DIR}/ddr2_phy_ref_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_ref_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_ref_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_ref_ctrl.vcd

ddr2_phy_ref_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_ref_ctrl
	make simulate_ddr2_phy_ref_ctrl

ddr2_phy_cmd_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_cmd_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_bank_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_bank_ctrl.vhd
	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_col_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_col_ctrl.vhd
	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_cmd_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_cmd_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_cmd_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_cmd_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_cmd_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_cmd_ctrl_tb
	rm -r e~ddr2_phy_cmd_ctrl_tb.o
	mv ddr2_phy_cmd_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_cmd_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl.o ${WORK_DIR}/ddr2_phy_col_ctrl.o ${WORK_DIR}/ddr2_phy_cmd_ctrl.o ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_cmd_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_cmd_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_cmd_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_cmd_ctrl.vcd

ddr2_phy_cmd_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_cmd_ctrl
	make simulate_ddr2_phy_cmd_ctrl

ddr2_phy_cmd_dec: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_cmd_dec_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_cmd_dec.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_cmd_dec.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_cmd_dec_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_cmd_dec_tb.vhd
	@echo "Elaborating ddr2_phy_cmd_dec_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_cmd_dec_tb
	rm -r e~ddr2_phy_cmd_dec_tb.o
	mv ddr2_phy_cmd_dec_tb ${WORK_DIR}

simulate_ddr2_phy_cmd_dec: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_cmd_dec.o ${WORK_DIR}/ddr2_phy_cmd_dec_pkg.o ${WORK_DIR}/ddr2_phy_cmd_dec_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_cmd_dec_tb ${GHDL_RUN_ARGS}ddr2_phy_cmd_dec.vcd

ddr2_phy_cmd_dec_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_cmd_dec
	make simulate_ddr2_phy_cmd_dec

ddr2_phy_arbiter: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_arbiter_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_arbiter.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_arbiter.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_arbiter_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_arbiter_tb.vhd
	@echo "Elaborating ddr2_phy_arbiter_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_arbiter_tb
	rm -r e~ddr2_phy_arbiter_tb.o
	mv ddr2_phy_arbiter_tb ${WORK_DIR}

simulate_ddr2_phy_arbiter: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_phy_arbiter.o ${WORK_DIR}/ddr2_phy_arbiter_pkg.o ${WORK_DIR}/ddr2_phy_arbiter_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_arbiter_tb ${GHDL_RUN_ARGS}ddr2_phy_arbiter.vcd

ddr2_phy_arbiter_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_arbiter
	make simulate_ddr2_phy_arbiter

ddr2_phy_odt_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_odt_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_odt_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_odt_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_odt_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_odt_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_odt_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_odt_ctrl_tb
	rm -r e~ddr2_phy_odt_ctrl_tb.o
	mv ddr2_phy_odt_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_odt_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_odt_ctrl.o  ${WORK_DIR}/ddr2_phy_odt_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_odt_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_odt_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_odt_ctrl.vcd

ddr2_phy_odt_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_odt_ctrl
	make simulate_ddr2_phy_odt_ctrl

ddr2_phy_mrs_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_mrs_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${DDR2_RTL_DIR}/ddr2_phy_mrs_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_RTL_DIR}/ddr2_phy_mrs_ctrl.vhd
	@echo "Analysing ${DDR2_VERIF_TB_DIR}/ddr2_phy_mrs_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${DDR2_VERIF_TB_DIR}/ddr2_phy_mrs_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_mrs_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_mrs_ctrl_tb
	rm -r e~ddr2_phy_mrs_ctrl_tb.o
	mv ddr2_phy_mrs_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_mrs_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_define_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_mrs_ctrl.o  ${WORK_DIR}/ddr2_phy_mrs_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_mrs_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_mrs_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_mrs_ctrl.vcd

ddr2_phy_mrs_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_phy_mrs_ctrl
	make simulate_ddr2_phy_mrs_ctrl
