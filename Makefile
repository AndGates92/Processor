VCOM = vcom
VCOM_OPT = -quiet -explicit -O0 -93
VCOM_WORK = -work

ROOT_DIR = .
SRC_DIR = ${ROOT_DIR}/src
RTL_DIR = ${SRC_DIR}/rtl
RTL_PKG_DIR = ${SRC_DIR}/pkg
RTL_CFG_DIR = ${SRC_DIR}/cfg

VERIF_DIR = ${ROOT_DIR}/verif
VERIF_TB_DIR = ${VERIF_DIR}/tb
VERIF_PKG_DIR = ${VERIF_DIR}/pkg
VERIF_MODELS_DIR = ${VERIF_DIR}/models

WORK_DIR = ${ROOT_DIR}/work
GHDL = ghdl
GHDL_ARGS = -g --workdir=${WORK_DIR}
GHDL_RUN_ARGS = --vcd=

LOG_FILE = ${WORK_DIR}/summary.log
SUMMARY_FILE = ${WORK_DIR}/summary

WAVE_READER = gtkwave

all:
	make clean
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
	make fifo_1clk_all
	make ddr2_phy_init_all
	make ddr2_phy_bank_ctrl_all
	make ddr2_phy_col_ctrl_all

clean:
	rm -rf ${LOG_FILE} ${SUMMARY_FILE} ${WORK_DIR}/*

work_dir:
	mkdir -p ${WORK_DIR}

libraries: 
	@echo "Analysing ${RTL_PKG_DIR}/type_conversion_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/type_conversion_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/proc_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/proc_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/bram_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/bram_pkg.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/mem_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/mem_model_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_mrs_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_mrs_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_phy_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_phy_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_phy_init_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_phy_init_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_phy_bank_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_phy_bank_ctrl_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ddr2_phy_col_ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ddr2_phy_col_ctrl_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/alu_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/alu_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/ctrl_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/reg_file_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/reg_file_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/decode_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/decode_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/execute_dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/execute_dcache_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/execute_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/execute_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/icache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/icache_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/dcache_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/fifo_1clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/fifo_1clk_pkg.vhd
	@echo "Analysing ${RTL_PKG_DIR}/fifo_2clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_PKG_DIR}/fifo_2clk_pkg.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/tb_pkg.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/alu_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/alu_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/reg_file_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/reg_file_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/fifo_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/fifo_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/ctrl_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/ctrl_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/execute_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/execute_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/decode_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/decode_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/ddr2_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/ddr2_pkg_tb.vhd
	@echo "Analysing ${VERIF_PKG_DIR}/ddr2_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_PKG_DIR}/ddr2_model_pkg.vhd

reg_file: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/reg_file_pkg.o
	@echo "Analysing ${RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/reg_file.vhd
	@echo "Analysing ${VERIF_TB_DIR}reg_file_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/reg_file_tb.vhd
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

alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing ${RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/alu.vhd
	@echo "Analysing ${VERIF_TB_DIR}/alu_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/alu_tb.vhd
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
	@echo "Analysing ${RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/mul.vhd
	@echo "Analysing ${VERIF_TB_DIR}/mul_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/mul_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/mul_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/mul_cfg.vhd
	@echo "Elaborating mul_cfg"
	${GHDL} -e ${GHDL_ARGS} config_mul
	rm -r e~config_mul.o
	mv config_mul ${WORK_DIR}

simulate_mul: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/mul.o ${WORK_DIR}/mul_cfg.o ${WORK_DIR}/mul_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_mul ${GHDL_RUN_ARGS}mul.vcd

mul_all:
	make work_dir
	make libraries
	make mul
	make simulate_mul


div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o
	@echo "Analysing ${RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/div.vhd
	@echo "Analysing ${VERIF_TB_DIR}/div_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/div_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/div_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/div_cfg.vhd
	@echo "Elaborating div_cfg"
	${GHDL} -e ${GHDL_ARGS} config_div
	rm -r e~config_div.o
	mv config_div ${WORK_DIR}

simulate_div: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/div.o ${WORK_DIR}/div_cfg.o ${WORK_DIR}/div_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_div ${GHDL_RUN_ARGS}div.vcd

div_all:
	make work_dir
	make libraries
	make div
	make simulate_div

decode_stage: ${WORK_DIR}/decode_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o
	@echo "Analysing ${RTL_DIR}/decode.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/decode.vhd
	@echo "Analysing ${VERIF_TB_DIR}/decode_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/decode_tb.vhd
	@echo "Elaborating decode_stage_tb"
	${GHDL} -e ${GHDL_ARGS} decode_stage_tb
	rm -r e~decode_stage_tb.o
	mv decode_stage_tb ${WORK_DIR}

simulate_decode_stage: ${WORK_DIR}/decode_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/decode.o ${WORK_DIR}/decode_tb.o
	cd ${WORK_DIR} && ${GHDL} -r decode_stage_tb ${GHDL_RUN_ARGS}decode.vcd

decode_stage_all:
	make work_dir
	make libraries
	make decode_stage
	make simulate_decode_stage

ctrl: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o
	@echo "Analysing ${RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ctrl.vhd
	@echo "Analysing ${VERIF_TB_DIR}/ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/ctrl_tb.vhd
	@echo "Elaborating ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ctrl_tb
	rm -r e~ctrl_tb.o
	mv ctrl_tb ${WORK_DIR}

simulate_ctrl: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl.o ${WORK_DIR}/ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ctrl_tb ${GHDL_RUN_ARGS}ctrl.vcd

ctrl_all:
	make work_dir
	make libraries
	make ctrl
	make simulate_ctrl

execute: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/alu.vhd
	@echo "Analysing ${RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/mul.vhd
	@echo "Analysing ${RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/div.vhd
	@echo "Analysing ${RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/reg_file.vhd
	@echo "Analysing ${VERIF_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ctrl.vhd
	@echo "Analysing ${RTL_DIR}/execute.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/execute.vhd
	@echo "Analysing ${VERIF_TB_DIR}/execute_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/execute_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/execute_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/execute_cfg.vhd
	@echo "Elaborating execute_cfg"
	${GHDL} -e ${GHDL_ARGS} config_execute
	rm -r e~config_execute.o
	mv config_execute ${WORK_DIR}

simulate_execute: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_pkg.o ${WORK_DIR}/execute.o  ${WORK_DIR}/execute_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_execute ${GHDL_RUN_ARGS}execute.vcd

execute_all:
	make work_dir
	make libraries
	make execute
	make simulate_execute

icache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${RTL_DIR}/icache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/icache.vhd
	@echo "Analysing ${VERIF_TB_DIR}/icache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/icache_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/icache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/icache_cfg.vhd
	@echo "Elaborating icache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_icache
	rm -r e~config_icache.o
	mv config_icache ${WORK_DIR}

simulate_icache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/icache_pkg.o ${WORK_DIR}/icache.o  ${WORK_DIR}/icache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_icache ${GHDL_RUN_ARGS}icache.vcd

icache_all:
	make work_dir
	make libraries
	make icache
	make simulate_icache

dcache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/execute_pkg.o
	@echo "Analysing ${RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${RTL_DIR}/dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/dcache.vhd
	@echo "Analysing ${VERIF_TB_DIR}/dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/dcache_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/dcache_cfg.vhd
	@echo "Elaborating dcache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_dcache
	rm -r e~config_dcache.o
	mv config_dcache ${WORK_DIR}

simulate_dcache: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/dcache_pkg.o ${WORK_DIR}/dcache.o  ${WORK_DIR}/dcache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_dcache ${GHDL_RUN_ARGS}dcache.vcd

dcache_all:
	make work_dir
	make libraries
	make dcache
	make simulate_dcache

execute_dcache: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/ctrl_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_dcache_pkg.o
	@echo "Analysing ${RTL_DIR}/alu.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/alu.vhd
	@echo "Analysing ${RTL_DIR}/mul.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/mul.vhd
	@echo "Analysing ${RTL_DIR}/div.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/div.vhd
	@echo "Analysing ${RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/reg_file.vhd
	@echo "Analysing ${RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${RTL_DIR}/dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/dcache.vhd
	@echo "Analysing ${VERIF_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ctrl.vhd
	@echo "Analysing ${RTL_DIR}/execute_dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/execute_dcache.vhd
	@echo "Analysing ${VERIF_TB_DIR}/execute_dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/execute_dcache_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/execute_dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/execute_dcache_cfg.vhd
	@echo "Elaborating execute_dcache_cfg"
	${GHDL} -e ${GHDL_ARGS} config_execute_dcache
	rm -r e~config_execute_dcache.o
	mv config_execute_dcache ${WORK_DIR}

simulate_execute_dcache: ${WORK_DIR}/ctrl_pkg_tb.o ${WORK_DIR}/execute_pkg_tb.o ${WORK_DIR}/reg_file_pkg_tb.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg.o ${WORK_DIR}/decode_pkg.o ${WORK_DIR}/mem_model_pkg.o ${WORK_DIR}/execute_dcache_pkg.o ${WORK_DIR}/execute_dcache.o  ${WORK_DIR}/execute_dcache_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_execute_dcache ${GHDL_RUN_ARGS}execute_dcache.vcd

execute_dcache_all:
	make work_dir
	make libraries
	make execute_dcache
	make simulate_execute_dcache

fifo_1clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/bram_pkg.o ${WORK_DIR}/fifo_1clk_pkg.o
	@echo "Analysing ${RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${RTL_DIR}/fifo_1clk.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/fifo_1clk.vhd
	@echo "Analysing ${VERIF_TB_DIR}/fifo_1pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/fifo_1clk_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/fifo_1clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/fifo_1clk_cfg.vhd
	@echo "Elaborating fifo_1clk_cfg"
	${GHDL} -e ${GHDL_ARGS} config_fifo_1clk
	rm -r e~config_fifo_1clk.o
	mv config_fifo_1clk ${WORK_DIR}

simulate_fifo_1clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/fifo_1clk_pkg.o ${WORK_DIR}/fifo_1clk.o  ${WORK_DIR}/fifo_1clk_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_fifo_1clk ${GHDL_RUN_ARGS}fifo_1clk.vcd

fifo_1clk_all:
	make work_dir
	make libraries
	make fifo_1clk
	make simulate_fifo_1clk

fifo_2clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/bram_pkg.o ${WORK_DIR}/fifo_2clk_pkg.o
	@echo "Analysing ${RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${RTL_DIR}/gray_cnt.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/gray_cnt.vhd
	@echo "Analysing ${RTL_DIR}/fifo_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/fifo_ctrl.vhd
	@echo "Analysing ${RTL_DIR}/fifo_2clk.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/fifo_2clk.vhd
	@echo "Analysing ${VERIF_TB_DIR}/fifo_2pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/fifo_2clk_tb.vhd
	@echo "Analysing ${RTL_CFG_DIR}/fifo_2clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_CFG_DIR}/fifo_2clk_cfg.vhd
	@echo "Elaborating fifo_2clk_cfg"
	${GHDL} -e ${GHDL_ARGS} config_fifo_2clk
	rm -r e~config_fifo_2clk.o
	mv config_fifo_2clk ${WORK_DIR}

simulate_fifo_2clk: ${WORK_DIR}/fifo_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/fifo_2clk_pkg.o ${WORK_DIR}/fifo_2clk.o  ${WORK_DIR}/fifo_2clk_tb.o
	cd ${WORK_DIR} && ${GHDL} -r config_fifo_2clk ${GHDL_RUN_ARGS}fifo_2clk.vcd

fifo_2clk_all:
	make work_dir
	make libraries
	make fifo_2clk
	make simulate_fifo_2clk

ddr2_phy_init: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${RTL_DIR}/ddr2_phy_init.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ddr2_phy_init.vhd
	@echo "Analysing ${VERIF_TB_DIR}/ddr2_phy_init_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/ddr2_phy_init_tb.vhd
	@echo "Elaborating ddr2_phy_init_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_init_tb
	rm -r e~ddr2_phy_init_tb.o
	mv ddr2_phy_init_tb ${WORK_DIR}

simulate_ddr2_phy_init: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_phy_init.o  ${WORK_DIR}/ddr2_phy_init_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_init_tb ${GHDL_RUN_ARGS}ddr2_phy_init.vcd

ddr2_phy_init_all:
	make work_dir
	make libraries
	make ddr2_phy_init
	make simulate_ddr2_phy_init

ddr2_phy_bank_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${RTL_DIR}/ddr2_phy_bank_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ddr2_phy_bank_ctrl.vhd
	@echo "Analysing ${VERIF_TB_DIR}/ddr2_phy_bank_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/ddr2_phy_bank_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_bank_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_bank_ctrl_tb
	rm -r e~ddr2_phy_bank_ctrl_tb.o
	mv ddr2_phy_bank_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_bank_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl.o  ${WORK_DIR}/ddr2_phy_bank_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_bank_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_bank_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_bank_ctrl.vcd

ddr2_phy_bank_ctrl_all:
	make work_dir
	make libraries
	make ddr2_phy_bank_ctrl
	make simulate_ddr2_phy_bank_ctrl

ddr2_phy_col_ctrl: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o

	@echo "Analysing ${RTL_DIR}/ddr2_phy_col_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ${RTL_DIR}/ddr2_phy_col_ctrl.vhd
	@echo "Analysing ${VERIF_TB_DIR}/ddr2_phy_col_ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ${VERIF_TB_DIR}/ddr2_phy_col_ctrl_tb.vhd
	@echo "Elaborating ddr2_phy_col_ctrl_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_col_ctrl_tb
	rm -r e~ddr2_phy_col_ctrl_tb.o
	mv ddr2_phy_col_ctrl_tb ${WORK_DIR}

simulate_ddr2_phy_col_ctrl: ${WORK_DIR}/ddr2_pkg_tb.o ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_mrs_pkg.o ${WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl.o  ${WORK_DIR}/ddr2_phy_col_ctrl_pkg.o ${WORK_DIR}/ddr2_phy_col_ctrl_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_col_ctrl_tb ${GHDL_RUN_ARGS}ddr2_phy_col_ctrl.vcd

ddr2_phy_col_ctrl_all:
	make work_dir
	make libraries
	make ddr2_phy_col_ctrl
	make simulate_ddr2_phy_col_ctrl

