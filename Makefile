VCOM = vcom
VCOM_OPT = -quiet -explicit -O0 -93
VCOM_WORK = -work

WORK_DIR = ./work
GHDL = ghdl
GHDL_ARGS = -g --workdir=${WORK_DIR}
GHDL_RUN_ARGS = --vcd=

LOG_FILE = work/summary.log
SUMMARY_FILE = work/summary

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

clean:
	rm -rf ${LOG_FILE} ${SUMMARY_FILE} ${WORK_DIR}

work_dir:
	mkdir -p ${WORK_DIR}

libraries: 
	@echo "Analysing proc_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} proc_pkg.vhd
	@echo "Analysing bram_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_pkg.vhd
	@echo "Analysing mem_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} mem_model_pkg.vhd
	@echo "Analysing ddr2_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_pkg.vhd
	@echo "Analysing ddr2_phy_init_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_phy_init_pkg.vhd
	@echo "Analysing ddr2_phy_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_phy_pkg.vhd
	@echo "Analysing ddr2_model_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_model_pkg.vhd
	@echo "Analysing alu_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} alu_pkg.vhd
	@echo "Analysing ctrl_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl_pkg.vhd
	@echo "Analysing reg_file_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file_pkg.vhd
	@echo "Analysing decode_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} decode_pkg.vhd
	@echo "Analysing execute_dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_dcache_pkg.vhd
	@echo "Analysing execute_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_pkg.vhd
	@echo "Analysing icache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} icache_pkg.vhd
	@echo "Analysing dcache_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} dcache_pkg.vhd
	@echo "Analysing fifo_1clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_1clk_pkg.vhd
	@echo "Analysing fifo_2clk_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_2clk_pkg.vhd
	@echo "Analysing tb_pkg.vhd"
	${GHDL} -a ${GHDL_ARGS} tb_pkg.vhd
	@echo "Analysing alu_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} alu_pkg_tb.vhd
	@echo "Analysing reg_file_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file_pkg_tb.vhd
	@echo "Analysing fifo_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_pkg_tb.vhd
	@echo "Analysing ctrl_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl_pkg_tb.vhd
	@echo "Analysing execute_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_pkg_tb.vhd
	@echo "Analysing decode_pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} decode_pkg_tb.vhd

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

alu: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/alu_pkg_tb.o ${WORK_DIR}/alu_pkg.o
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
	@echo "Analysing div.vhd"
	${GHDL} -a ${GHDL_ARGS} div.vhd
	@echo "Analysing div_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} div_tb.vhd
	@echo "Analysing div_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} div_cfg.vhd
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
	@echo "Analysing decode.vhd"
	${GHDL} -a ${GHDL_ARGS} decode.vhd
	@echo "Analysing decode_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} decode_tb.vhd
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
	@echo "Analysing ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl.vhd
	@echo "Analysing ctrl_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl_tb.vhd
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
	@echo "Analysing alu.vhd"
	${GHDL} -a ${GHDL_ARGS} alu.vhd
	@echo "Analysing mul.vhd"
	${GHDL} -a ${GHDL_ARGS} mul.vhd
	@echo "Analysing div.vhd"
	${GHDL} -a ${GHDL_ARGS} div.vhd
	@echo "Analysing reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file.vhd
	@echo "Analysing mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} mem_model.vhd
	@echo "Analysing ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl.vhd
	@echo "Analysing execute.vhd"
	${GHDL} -a ${GHDL_ARGS} execute.vhd
	@echo "Analysing execute_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_tb.vhd
	@echo "Analysing execute_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_cfg.vhd
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
	@echo "Analysing bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_1port.vhd
	@echo "Analysing bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_2port.vhd
	@echo "Analysing bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_rst.vhd
	@echo "Analysing icache.vhd"
	${GHDL} -a ${GHDL_ARGS} icache.vhd
	@echo "Analysing icache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} icache_tb.vhd
	@echo "Analysing icache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} icache_cfg.vhd
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
	@echo "Analysing bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_1port.vhd
	@echo "Analysing bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_2port.vhd
	@echo "Analysing bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_rst.vhd
	@echo "Analysing dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} dcache.vhd
	@echo "Analysing dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} dcache_tb.vhd
	@echo "Analysing dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} dcache_cfg.vhd
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
	@echo "Analysing alu.vhd"
	${GHDL} -a ${GHDL_ARGS} alu.vhd
	@echo "Analysing mul.vhd"
	${GHDL} -a ${GHDL_ARGS} mul.vhd
	@echo "Analysing div.vhd"
	${GHDL} -a ${GHDL_ARGS} div.vhd
	@echo "Analysing reg_file.vhd"
	${GHDL} -a ${GHDL_ARGS} reg_file.vhd
	@echo "Analysing bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_rst.vhd
	@echo "Analysing bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_1port.vhd
	@echo "Analysing bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_2port.vhd
	@echo "Analysing dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} dcache.vhd
	@echo "Analysing mem_model.vhd"
	${GHDL} -a ${GHDL_ARGS} mem_model.vhd
	@echo "Analysing ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} ctrl.vhd
	@echo "Analysing execute_dcache.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_dcache.vhd
	@echo "Analysing execute_dcache_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_dcache_tb.vhd
	@echo "Analysing execute_dcache_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} execute_dcache_cfg.vhd
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
	@echo "Analysing bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_1port.vhd
	@echo "Analysing bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_2port_sim.vhd
	@echo "Analysing bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_rst.vhd
	@echo "Analysing fifo_1clk.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_1clk.vhd
	@echo "Analysing fifo_1pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_1clk_tb.vhd
	@echo "Analysing fifo_1clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_1clk_cfg.vhd
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
	@echo "Analysing bram_1port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_1port.vhd
	@echo "Analysing bram_2port.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_2port_sim.vhd
	@echo "Analysing bram_rst.vhd"
	${GHDL} -a ${GHDL_ARGS} bram_rst.vhd
	@echo "Analysing gray_cnt.vhd"
	${GHDL} -a ${GHDL_ARGS} gray_cnt.vhd
	@echo "Analysing fifo_ctrl.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_ctrl.vhd
	@echo "Analysing fifo_2clk.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_2clk.vhd
	@echo "Analysing fifo_2pkg_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_2clk_tb.vhd
	@echo "Analysing fifo_2clk_cfg.vhd"
	${GHDL} -a ${GHDL_ARGS} fifo_2clk_cfg.vhd
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

ddr2_phy_init: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_pkg.o
	@echo "Analysing ddr2_phy_init.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_phy_init.vhd
	@echo "Analysing ddr2_phy_init_tb.vhd"
	${GHDL} -a ${GHDL_ARGS} ddr2_phy_init_tb.vhd
	@echo "Elaborating ddr2_phy_init_tb"
	${GHDL} -e ${GHDL_ARGS} ddr2_phy_init_tb
	rm -r e~ddr2_phy_init_tb.o
	mv ddr2_phy_init_tb ${WORK_DIR}

simulate_ddr2_phy_init: ${WORK_DIR}/tb_pkg.o ${WORK_DIR}/proc_pkg.o ${WORK_DIR}/ddr2_phy_pkg.o ${WORK_DIR}/ddr2_phy_init_pkg.o ${WORK_DIR}/ddr2_phy_init.o  ${WORK_DIR}/ddr2_phy_init_tb.o
	cd ${WORK_DIR} && ${GHDL} -r ddr2_phy_init_tb ${GHDL_RUN_ARGS}ddr2_phy_init.vcd

ddr2_phy_init_all:
	make work_dir
	make libraries
	make ddr2_phy_init
	make simulate_ddr2_phy_init

