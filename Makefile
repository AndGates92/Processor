VCOM = vcom
VCOM_OPT = -quiet -explicit -O0 -93
VCOM_WORK = -work

GHDL = ghdl

ROOT_DIR = .
SCRIPT_DIR = ${ROOT_DIR}/scripts

SRC_DIR = ${ROOT_DIR}/src
COMMON_SRC_DIR = ${SRC_DIR}/common
COMMON_RTL_DIR = ${COMMON_SRC_DIR}/rtl
COMMON_RTL_PKG_DIR = ${COMMON_SRC_DIR}/pkg
COMMON_RTL_CFG_DIR = ${COMMON_SRC_DIR}/cfg
COMMON_RTL_MODELS_DIR = ${COMMON_SRC_DIR}/models
CPU_SRC_DIR = ${SRC_DIR}/cpu
CPU_RTL_DIR = ${CPU_SRC_DIR}/rtl
CPU_RTL_PKG_DIR = ${CPU_SRC_DIR}/pkg
CPU_RTL_CFG_DIR = ${CPU_SRC_DIR}/cfg
DDR2_SRC_DIR = ${SRC_DIR}/ddr2
DDR2_CTRL_SRC_DIR = ${DDR2_SRC_DIR}/ctrl
DDR2_CTRL_RTL_DIR = ${DDR2_CTRL_SRC_DIR}/rtl
DDR2_CTRL_RTL_PKG_DIR = ${DDR2_CTRL_SRC_DIR}/pkg
DDR2_CTRL_RTL_CFG_DIR = ${DDR2_CTRL_SRC_DIR}/cfg

VERIF_DIR = ${ROOT_DIR}/verif
COMMON_VERIF_DIR = ${VERIF_DIR}/common
COMMON_VERIF_TB_DIR = ${COMMON_VERIF_DIR}/tb
COMMON_VERIF_PKG_DIR = ${COMMON_VERIF_DIR}/pkg
COMMON_VERIF_MODELS_DIR = ${COMMON_VERIF_DIR}/models
COMMON_VERIF_CFG_DIR = ${COMMON_VERIF_DIR}/cfg
CPU_VERIF_DIR = ${VERIF_DIR}/cpu
CPU_VERIF_TB_DIR = ${CPU_VERIF_DIR}/tb
CPU_VERIF_PKG_DIR = ${CPU_VERIF_DIR}/pkg
CPU_VERIF_CFG_DIR = ${CPU_VERIF_DIR}/cfg
CPU_VERIF_MODELS_DIR = ${CPU_VERIF_DIR}/models
DDR2_VERIF_DIR = ${VERIF_DIR}/ddr2
DDR2_CTRL_VERIF_DIR = ${DDR2_VERIF_DIR}/ctrl
DDR2_CTRL_VERIF_TB_DIR = ${DDR2_CTRL_VERIF_DIR}/tb
DDR2_CTRL_VERIF_PKG_DIR = ${DDR2_CTRL_VERIF_DIR}/pkg
DDR2_CTRL_VERIF_CFG_DIR = ${DDR2_CTRL_VERIF_DIR}/cfg
DDR2_CTRL_VERIF_MODELS_DIR = ${DDR2_CTRL_VERIF_DIR}/models

WAVES_DIR = /tmp

OSVVM_LIB_NAME = osvvm

OSVVM_ROOT_DIR = osvvm
OSVVM_SRC_DIR = ${OSVVM_ROOT_DIR}/src
OSVVM_WORK_DIR = ${OSVVM_ROOT_DIR}/work

OSVVM_GHDL_ARGS = -a --work=${OSVVM_LIB_NAME} --workdir=${OSVVM_WORK_DIR} --std=08

DDR2_OSVVM_TB_LIB_NAME = ddr2_osvvm_tb

DDR2_OSVVM_TB_ROOT_DIR = ddr2_osvvm_tb
DDR2_OSVVM_TB_WORK_DIR = ${DDR2_OSVVM_TB_ROOT_DIR}/work

DDR2_OSVVM_TB_GHDL_ARGS = --work=${DDR2_OSVVM_TB_LIB_NAME} --workdir=${DDR2_OSVVM_TB_WORK_DIR} --std=08 -P${OSVVM_WORK_DIR}

ROOT_WORK_DIR = ${ROOT_DIR}/work

COMMON_RTL_PKG_LIB_NAME = common_rtl_pkg
COMMON_RTL_PKG_WORK_DIR = ${ROOT_WORK_DIR}/common_rtl_pkg_work
COMMON_RTL_PKG_GHDL_ARGS = -g --work=${COMMON_RTL_PKG_LIB_NAME} --workdir=${COMMON_RTL_PKG_WORK_DIR}

COMMON_TB_PKG_LIB_NAME = common_tb_pkg
COMMON_TB_PKG_WORK_DIR = ${ROOT_WORK_DIR}/common_tb_pkg_work
COMMON_TB_PKG_GHDL_ARGS = -g --work=${COMMON_TB_PKG_LIB_NAME} --workdir=${COMMON_TB_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR}

COMMON_RTL_LIB_NAME = common_rtl
COMMON_RTL_WORK_DIR = ${ROOT_WORK_DIR}/common_rtl_work
COMMON_RTL_GHDL_ARGS = -g --work=${COMMON_RTL_LIB_NAME} --workdir=${COMMON_RTL_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR}

COMMON_TB_LIB_NAME = common_tb
COMMON_TB_WORK_DIR = ${ROOT_WORK_DIR}/common_tb_work
COMMON_TB_GHDL_ARGS = -g  --work=${COMMON_TB_LIB_NAME} --workdir=${COMMON_TB_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_RTL_WORK_DIR} -P${COMMON_TB_PKG_WORK_DIR}

CPU_RTL_PKG_LIB_NAME = cpu_rtl_pkg
CPU_RTL_PKG_WORK_DIR = ${ROOT_WORK_DIR}/cpu_rtl_pkg_work
CPU_RTL_PKG_GHDL_ARGS = -g --work=${CPU_RTL_PKG_LIB_NAME} --workdir=${CPU_RTL_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR}

CPU_TB_PKG_LIB_NAME = cpu_tb_pkg
CPU_TB_PKG_WORK_DIR = ${ROOT_WORK_DIR}/cpu_tb_pkg_work
CPU_TB_PKG_GHDL_ARGS = -g --work=${CPU_TB_PKG_LIB_NAME} --workdir=${CPU_TB_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_TB_PKG_WORK_DIR} -P${CPU_RTL_PKG_WORK_DIR}

CPU_RTL_LIB_NAME = cpu_rtl
CPU_RTL_WORK_DIR = ${ROOT_WORK_DIR}/cpu_rtl_work
CPU_RTL_GHDL_ARGS = -g --work=${CPU_RTL_LIB_NAME} --workdir=${CPU_RTL_WORK_DIR} -P${CPU_RTL_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_RTL_WORK_DIR}

CPU_TB_LIB_NAME = cpu_tb
CPU_TB_WORK_DIR = ${ROOT_WORK_DIR}/cpu_tb_work
CPU_TB_GHDL_ARGS = -g  --work=${CPU_TB_LIB_NAME} --workdir=${CPU_TB_WORK_DIR} -P${CPU_RTL_WORK_DIR} -P${CPU_RTL_PKG_WORK_DIR} -P${CPU_TB_PKG_WORK_DIR} -P${COMMON_RTL_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_TB_PKG_WORK_DIR}

DDR2_CTRL_RTL_PKG_LIB_NAME = ddr2_ctrl_rtl_pkg
DDR2_CTRL_RTL_PKG_WORK_DIR = ${ROOT_WORK_DIR}/ddr2_ctrl_rtl_pkg_work
DDR2_CTRL_RTL_PKG_GHDL_ARGS = -g --work=${DDR2_CTRL_RTL_PKG_LIB_NAME} --workdir=${DDR2_CTRL_RTL_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR}

DDR2_CTRL_TB_PKG_LIB_NAME = ddr2_ctrl_tb_pkg
DDR2_CTRL_TB_PKG_WORK_DIR = ${ROOT_WORK_DIR}/ddr2_ctrl_tb_pkg_work
DDR2_CTRL_TB_PKG_GHDL_ARGS = -g --work=${DDR2_CTRL_TB_PKG_LIB_NAME} --workdir=${DDR2_CTRL_TB_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_TB_PKG_WORK_DIR} -P${DDR2_CTRL_RTL_PKG_WORK_DIR}

DDR2_CTRL_RTL_LIB_NAME = ddr2_ctrl_rtl
DDR2_CTRL_RTL_WORK_DIR = ${ROOT_WORK_DIR}/ddr2_ctrl_rtl_work
DDR2_CTRL_RTL_GHDL_ARGS = -g --work=${DDR2_CTRL_RTL_LIB_NAME} --workdir=${DDR2_CTRL_RTL_WORK_DIR} -P${DDR2_CTRL_RTL_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_RTL_WORK_DIR}

DDR2_CTRL_TB_LIB_NAME = ddr2_ctrl_tb
DDR2_CTRL_TB_WORK_DIR = ${ROOT_WORK_DIR}/ddr2_ctrl_tb_work
DDR2_CTRL_TB_GHDL_ARGS = -g  --work=${DDR2_CTRL_TB_LIB_NAME} --workdir=${DDR2_CTRL_TB_WORK_DIR} -P${DDR2_CTRL_RTL_WORK_DIR} -P${DDR2_CTRL_RTL_PKG_WORK_DIR} -P${DDR2_CTRL_TB_PKG_WORK_DIR} -P${COMMON_RTL_PKG_WORK_DIR} -P${COMMON_TB_PKG_WORK_DIR}

GHDL_RUN_ARGS = --vcd=${WAVES_DIR}/

LOG_FILES = ${ROOT_WORK_DIR}/*.log
SUMMARY_FILE = ${ROOT_WORK_DIR}/summary

WAVE_READER = gtkwave

all:
	make clean
	make all_common
	make all_cpu
	make all_ddr2
	${SCRIPT_DIR}/postprocess.sh

all_common:
	make fifo_1clk_all
	make arbiter_all

all_cpu:
	make reg_file_all
	make mul_all
	make div_all
	make alu_all
	make decode_all
	make ctrl_all
	make icache_all
	make dcache_all
	make execute_all
	make execute_dcache_all

all_ddr2:
	make all_ddr2_ctrl

all_ddr2_ctrl:
	make ddr2_ctrl_init_all
	make ddr2_ctrl_arbiter_all
	make ddr2_ctrl_arbiter_top_all
	make ddr2_ctrl_regs_all
	make ddr2_ctrl_bank_ctrl_all
	make ddr2_ctrl_col_ctrl_all
	make ddr2_ctrl_ref_ctrl_all
	make ddr2_ctrl_cmd_ctrl_all
	make ddr2_ctrl_odt_ctrl_all
	make ddr2_ctrl_mrs_ctrl_all
	make ddr2_ctrl_cmd_dec_all
	make ddr2_ctrl_ctrl_top_all

clean:
	rm -rf ${LOG_FILES} ${SUMMARY_FILE} ${ROOT_WORK_DIR}/*

osvvm_libraires:
	@echo "Analysing OSVVM source files"
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/NamePkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/TranscriptPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/TextUtilPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/VendorCovApiPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/OsvvmGlobalPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/AlertLogPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/MemoryPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/MessagePkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/RandomBasePkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/ResolutionPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/SortListPkg_int.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/ScoreboardGenericPkg.vhd
#	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/ScoreboardPkg_int.vhd
#	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/ScoreboardPkg_slv.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/TbUtilPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/RandomPkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/CoveragePkg.vhd
	${GHDL} ${OSVVM_GHDL_ARGS} ${OSVVM_SRC_DIR}/OsvvmContext.vhd

work_dir:
	make common_work_dir
	make cpu_work_dir
	make ddr2_work_dir

common_work_dir:
	mkdir -p ${COMMON_RTL_PKG_WORK_DIR}
	mkdir -p ${COMMON_RTL_WORK_DIR}
	mkdir -p ${COMMON_TB_PKG_WORK_DIR}
	mkdir -p ${COMMON_TB_WORK_DIR}

cpu_work_dir:
	mkdir -p ${CPU_RTL_PKG_WORK_DIR}
	mkdir -p ${CPU_RTL_WORK_DIR}
	mkdir -p ${CPU_TB_PKG_WORK_DIR}
	mkdir -p ${CPU_TB_WORK_DIR}

ddr2_work_dir:
	mkdir -p ${DDR2_CTRL_RTL_PKG_WORK_DIR}
	mkdir -p ${DDR2_CTRL_RTL_WORK_DIR}
	mkdir -p ${DDR2_CTRL_TB_PKG_WORK_DIR}
	mkdir -p ${DDR2_CTRL_TB_WORK_DIR}

common_rtl_libraries: 
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/type_conversion_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/type_conversion_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/bram_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/bram_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/functions_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/functions_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/arbiter_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/arbiter_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/mem_model_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/mem_model_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/fifo_1clk_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/fifo_1clk_pkg.vhd
	@echo "Analysing ${COMMON_RTL_PKG_DIR}/fifo_2clk_pkg.vhd"
	${GHDL} -a ${COMMON_RTL_PKG_GHDL_ARGS} ${COMMON_RTL_PKG_DIR}/fifo_2clk_pkg.vhd

ddr2_rtl_libraries:
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_define_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_define_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_gen_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_io_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_odt_ac_timing_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_mrs_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_mrs_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_mrs_max_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_mrs_max_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_init_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_init_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_bank_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_bank_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_col_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_col_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_ref_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_ref_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_cmd_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_cmd_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_top_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_arbiter_top_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_cmd_dec_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_cmd_dec_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_odt_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_odt_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_mrs_ctrl_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_mrs_ctrl_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_regs_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_regs_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_ctrl_top_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_PKG_GHDL_ARGS} ${DDR2_CTRL_RTL_PKG_DIR}/ddr2_ctrl_ctrl_top_pkg.vhd

cpu_rtl_libraries:
	@echo "Analysing ${CPU_RTL_PKG_DIR}/proc_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/proc_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/alu_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/alu_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/ctrl_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/ctrl_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/reg_file_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/reg_file_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/decode_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/decode_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/execute_dcache_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/execute_dcache_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/execute_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/execute_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/icache_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/icache_pkg.vhd
	@echo "Analysing ${CPU_RTL_PKG_DIR}/dcache_pkg.vhd"
	${GHDL} -a ${CPU_RTL_PKG_GHDL_ARGS} ${CPU_RTL_PKG_DIR}/dcache_pkg.vhd

common_verif_libraries:
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/shared_pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/shared_pkg_tb.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/functions_pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/functions_pkg_tb.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/common_log_pkg.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/common_log_pkg.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/common_pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/common_pkg_tb.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/fifo_pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/fifo_pkg_tb.vhd
	@echo "Analysing ${COMMON_VERIF_PKG_DIR}/ddr2_model_pkg.vhd"
	${GHDL} -a ${COMMON_TB_PKG_GHDL_ARGS} ${COMMON_VERIF_PKG_DIR}/ddr2_model_pkg.vhd

cpu_verif_libraries:
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/cpu_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/cpu_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/cpu_log_pkg.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/cpu_log_pkg.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/alu_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/alu_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/reg_file_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/reg_file_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/ctrl_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/ctrl_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/execute_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/execute_pkg_tb.vhd
	@echo "Analysing ${CPU_VERIF_PKG_DIR}/decode_pkg_tb.vhd"
	${GHDL} -a ${CPU_TB_PKG_GHDL_ARGS} ${CPU_VERIF_PKG_DIR}/decode_pkg_tb.vhd

ddr2_verif_libraries:
	@echo "Analysing ${DDR2_CTRL_VERIF_PKG_DIR}/ddr2_log_pkg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_PKG_GHDL_ARGS} ${DDR2_CTRL_VERIF_PKG_DIR}/ddr2_log_pkg.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_PKG_DIR}/ddr2_pkg_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_PKG_GHDL_ARGS} ${DDR2_CTRL_VERIF_PKG_DIR}/ddr2_pkg_tb.vhd

common_libraries:
	make common_rtl_libraries
	make common_verif_libraries

cpu_libraries:
	make cpu_rtl_libraries
	make cpu_verif_libraries

ddr2_libraries:
	make ddr2_rtl_libraries
	make ddr2_verif_libraries

reg_file: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/reg_file_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/reg_file_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/reg_file_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/reg_file_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/reg_file_tb_cfg.vhd
	@echo "Elaborating reg_file_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_reg_file_tb
	rm -r e~config_reg_file_tb.o
	mv config_reg_file_tb ${CPU_TB_WORK_DIR}

simulate_reg_file: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/reg_file_pkg.o ${CPU_RTL_WORK_DIR}/reg_file.o ${CPU_TB_WORK_DIR}/reg_file_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_reg_file_tb ${GHDL_RUN_ARGS}reg_file.vcd

reg_file_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make reg_file
	make simulate_reg_file

alu: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_TB_PKG_WORK_DIR}/alu_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/alu_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/alu_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/alu_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/alu_tb_cfg.vhd
	@echo "Elaborating alu_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_alu_tb
	rm -r e~config_alu_tb.o
	mv config_alu_tb ${CPU_TB_WORK_DIR}

simulate_alu: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_WORK_DIR}/alu.o ${CPU_TB_WORK_DIR}/alu_tb.o
	cd ${CPU_TB_WORK_DIR} &&  ${GHDL} -r config_alu_tb ${GHDL_RUN_ARGS}alu.vcd

alu_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make alu
	make simulate_alu

mul: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/mul_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/mul_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/mul_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/mul_tb_cfg.vhd
	@echo "Elaborating mul_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_mul_tb
	rm -r e~config_mul_tb.o
	mv config_mul_tb ${CPU_TB_WORK_DIR}

simulate_mul: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_WORK_DIR}/mul.o ${CPU_TB_WORK_DIR}/mul_tb_cfg.o ${CPU_TB_WORK_DIR}/mul_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_mul_tb ${GHDL_RUN_ARGS}mul.vcd

mul_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make mul
	make simulate_mul


div: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/div_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/div_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/div_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/div_tb_cfg.vhd
	@echo "Elaborating div_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_div_tb
	rm -r e~config_div_tb.o
	mv config_div_tb ${CPU_TB_WORK_DIR}

simulate_div: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_WORK_DIR}/div.o ${CPU_TB_WORK_DIR}/div_tb_cfg.o ${CPU_TB_WORK_DIR}/div_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_div_tb ${GHDL_RUN_ARGS}div.vcd

div_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make div
	make simulate_div

decode: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/decode_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/decode.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/decode.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/decode_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/decode_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/decode_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/decode_tb_cfg.vhd
	@echo "Elaborating decode_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_decode_tb
	rm -r e~config_decode_tb.o
	mv config_decode_tb ${CPU_TB_WORK_DIR}

simulate_decode: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/decode_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_WORK_DIR}/decode.o ${CPU_TB_WORK_DIR}/decode_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_decode_tb ${GHDL_RUN_ARGS}decode.vcd

decode_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make decode
	make simulate_decode

ctrl: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_PKG_WORK_DIR}/ctrl_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/ctrl_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/ctrl_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/ctrl_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/ctrl_tb_cfg.vhd
	@echo "Elaborating ctrl_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_ctrl_tb
	rm -r e~config_ctrl_tb.o
	mv config_ctrl_tb ${CPU_TB_WORK_DIR}

simulate_ctrl: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_WORK_DIR}/ctrl.o ${CPU_TB_WORK_DIR}/ctrl_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_ctrl_tb ${GHDL_RUN_ARGS}ctrl.vcd

ctrl_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make ctrl
	make simulate_ctrl

execute: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/execute_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/reg_file_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/alu_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_PKG_WORK_DIR}/ctrl_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/mem_model_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${COMMON_RTL_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_RTL_DIR}/execute.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/execute.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/execute_cfg.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_CFG_DIR}/execute_cfg.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/execute_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/execute_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/execute_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/execute_tb_cfg.vhd
	@echo "Elaborating execute_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_execute_tb
	rm -r e~config_execute_tb.o
	mv config_execute_tb ${CPU_TB_WORK_DIR}

simulate_execute: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/execute_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/reg_file_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/alu_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/mem_model_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_pkg.o ${CPU_RTL_WORK_DIR}/execute.o  ${CPU_TB_WORK_DIR}/execute_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_execute_tb ${GHDL_RUN_ARGS}execute.vcd

execute_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make execute
	make simulate_execute

icache: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_PKG_WORK_DIR}/ctrl_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${CPU_RTL_DIR}/icache.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/icache.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/icache_cfg.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_CFG_DIR}/icache_cfg.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/icache_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/icache_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/icache_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/icache_tb_cfg.vhd
	@echo "Elaborating icache_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_icache_tb
	rm -r e~config_icache_tb.o
	mv config_icache_tb ${CPU_TB_WORK_DIR}

simulate_icache: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/icache_pkg.o ${CPU_RTL_WORK_DIR}/icache.o  ${CPU_TB_WORK_DIR}/icache_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_icache_tb ${GHDL_RUN_ARGS}icache.vcd

icache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make icache
	make simulate_icache

dcache: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_PKG_WORK_DIR}/ctrl_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${CPU_RTL_DIR}/dcache.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/dcache.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/dcache_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/dcache_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/dcache_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/dcache_tb_cfg.vhd
	@echo "Elaborating dcache_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_dcache_tb
	rm -r e~config_dcache_tb.o
	mv config_dcache_tb ${CPU_TB_WORK_DIR}

simulate_dcache: ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/dcache_pkg.o ${CPU_RTL_WORK_DIR}/dcache.o  ${CPU_TB_WORK_DIR}/dcache_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_dcache_tb ${GHDL_RUN_ARGS}dcache.vcd

dcache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make dcache
	make simulate_dcache

execute_dcache: ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/execute_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/reg_file_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/alu_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${CPU_RTL_PKG_WORK_DIR}/ctrl_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/mem_model_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_dcache_pkg.o
	@echo "Analysing ${CPU_RTL_DIR}/alu.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/alu.vhd
	@echo "Analysing ${CPU_RTL_DIR}/mul.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/mul.vhd
	@echo "Analysing ${CPU_RTL_DIR}/div.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/div.vhd
	@echo "Analysing ${CPU_RTL_DIR}/reg_file.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/reg_file.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port.vhd
	@echo "Analysing ${CPU_RTL_DIR}/dcache.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/dcache.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_CFG_DIR}/dcache_cfg.vhd
	@echo "Analysing ${COMMON_RTL_MODELS_DIR}/mem_model.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_MODELS_DIR}/mem_model.vhd
	@echo "Analysing ${CPU_RTL_DIR}/ctrl.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/ctrl.vhd
	@echo "Analysing ${CPU_RTL_DIR}/execute_dcache.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_DIR}/execute_dcache.vhd
	@echo "Analysing ${CPU_RTL_CFG_DIR}/execute_dcache_cfg.vhd"
	${GHDL} -a ${CPU_RTL_GHDL_ARGS} ${CPU_RTL_CFG_DIR}/execute_dcache_cfg.vhd
	@echo "Analysing ${CPU_VERIF_TB_DIR}/execute_dcache_tb.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_TB_DIR}/execute_dcache_tb.vhd
	@echo "Analysing ${CPU_VERIF_CFG_DIR}/execute_dcache_tb_cfg.vhd"
	${GHDL} -a ${CPU_TB_GHDL_ARGS} ${CPU_VERIF_CFG_DIR}/execute_dcache_tb_cfg.vhd
	@echo "Elaborating execute_dcache_tb_cfg"
	${GHDL} -e ${CPU_TB_GHDL_ARGS} config_execute_dcache_tb
	rm -r e~config_execute_dcache_tb.o
	mv config_execute_dcache_tb ${CPU_TB_WORK_DIR}

simulate_execute_dcache: ${CPU_TB_PKG_WORK_DIR}/ctrl_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/execute_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/reg_file_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/alu_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${CPU_TB_PKG_WORK_DIR}/cpu_log_pkg.o ${CPU_TB_PKG_WORK_DIR}/cpu_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${CPU_RTL_PKG_WORK_DIR}/proc_pkg.o ${CPU_RTL_PKG_WORK_DIR}/alu_pkg.o ${CPU_RTL_PKG_WORK_DIR}/decode_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/mem_model_pkg.o ${CPU_RTL_PKG_WORK_DIR}/execute_dcache_pkg.o ${CPU_RTL_WORK_DIR}/execute_dcache.o  ${CPU_TB_WORK_DIR}/execute_dcache_tb.o
	cd ${CPU_TB_WORK_DIR} && ${GHDL} -r config_execute_dcache_tb ${GHDL_RUN_ARGS}execute_dcache.vcd

execute_dcache_all:
	make work_dir
	make common_libraries
	make cpu_libraries
	make execute_dcache
	make simulate_execute_dcache

arbiter: ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/arbiter_pkg.o

	@echo "Analysing ${COMMON_RTL_DIR}/arbiter.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/arbiter.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/arbiter_tb.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/arbiter_tb.vhd
	@echo "Analysing ${COMMON_VERIF_CFG_DIR}/arbiter_tb_cfg.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_CFG_DIR}/arbiter_tb_cfg.vhd
	@echo "Elaborating arbiter_tb_cfg"
	${GHDL} -e ${COMMON_TB_GHDL_ARGS} config_arbiter_tb
	rm -r e~config_arbiter_tb.o
	mv config_arbiter_tb ${COMMON_TB_WORK_DIR}

simulate_arbiter: ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_WORK_DIR}/arbiter.o ${COMMON_RTL_PKG_WORK_DIR}/arbiter_pkg.o ${COMMON_TB_WORK_DIR}/arbiter_tb.o
	cd ${COMMON_TB_WORK_DIR} && ${GHDL} -r config_arbiter_tb ${GHDL_RUN_ARGS}arbiter.vcd

arbiter_all:
	make work_dir
	make common_libraries
	make arbiter
	make simulate_arbiter

fifo_1clk: ${COMMON_TB_PKG_WORK_DIR}/fifo_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/bram_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/fifo_1clk_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_1clk.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_1clk.vhd
	@echo "Analysing ${COMMON_RTL_CFG_DIR}/fifo_1clk_cfg.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_CFG_DIR}/fifo_1clk_cfg.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/fifo_1pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/fifo_1clk_tb.vhd
	@echo "Analysing ${COMMON_VERIF_CFG_DIR}/fifo_1clk_cfg.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_CFG_DIR}/fifo_1clk_tb_cfg.vhd
	@echo "Elaborating fifo_1clk_cfg_tb_cfg"
	${GHDL} -e ${COMMON_TB_GHDL_ARGS} config_fifo_1clk_tb
	rm -r e~config_fifo_1clk_tb.o
	mv config_fifo_1clk_tb ${COMMON_TB_WORK_DIR}

simulate_fifo_1clk: ${COMMON_TB_PKG_WORK_DIR}/fifo_pkg_tb.o  ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/fifo_1clk_pkg.o ${COMMON_RTL_WORK_DIR}/fifo_1clk.o  ${COMMON_TB_WORK_DIR}/fifo_1clk_tb.o
	cd ${COMMON_TB_WORK_DIR} && ${GHDL} -r config_fifo_1clk_tb ${GHDL_RUN_ARGS}fifo_1clk.vcd

fifo_1clk_all:
	make work_dir
	make common_libraries
	make fifo_1clk
	make simulate_fifo_1clk

fifo_2clk: ${COMMON_TB_PKG_WORK_DIR}/fifo_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/bram_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/fifo_2clk_pkg.o
	@echo "Analysing ${COMMON_RTL_DIR}/bram_1port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_1port.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_2port.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_2port_sim.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/bram_rst.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/bram_rst.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/gray_cnt.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/gray_cnt.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_ctrl.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_ctrl.vhd
	@echo "Analysing ${COMMON_RTL_CFG_DIR}/fifo_2clk_cfg.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_CFG_DIR}/fifo_2clk_cfg.vhd
	@echo "Analysing ${COMMON_RTL_DIR}/fifo_2clk.vhd"
	${GHDL} -a ${COMMON_RTL_GHDL_ARGS} ${COMMON_RTL_DIR}/fifo_2clk.vhd
	@echo "Analysing ${COMMON_VERIF_TB_DIR}/fifo_2pkg_tb.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_TB_DIR}/fifo_2clk_tb.vhd
	@echo "Analysing ${COMMON_VERIF_CFG_DIR}/fifo_2clk_tb_cfg.vhd"
	${GHDL} -a ${COMMON_TB_GHDL_ARGS} ${COMMON_VERIF_CFG_DIR}/fifo_2clk_tb_cfg.vhd
	@echo "Elaborating fifo_2clk_tb_cfg"
	${GHDL} -e ${COMMON_TB_GHDL_ARGS} config_fifo_2clk_tb
	rm -r e~config_fifo_2clk_tb.o
	mv config_fifo_2clk_tb ${COMMON_TB_WORK_DIR}

simulate_fifo_2clk: ${COMMON_TB_PKG_WORK_DIR}/fifo_pkg_tb.o  ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/common_log_pkg.o ${COMMON_TB_PKG_WORK_DIR}/common_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${COMMON_RTL_PKG_WORK_DIR}/fifo_2clk_pkg.o ${COMMON_RTL_WORK_DIR}/fifo_2clk.o  ${COMMON_TB_WORK_DIR}/fifo_2clk_tb.o
	cd ${COMMON_TB_WORK_DIR} && ${GHDL} -r config_fifo_2clk_tb ${GHDL_RUN_ARGS}fifo_2clk.vcd

fifo_2clk_all:
	make work_dir
	make common_libraries
	make fifo_2clk
	make simulate_fifo_2clk

ddr2_ctrl_init: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_init_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_init.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_init.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_init_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_init_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_init_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_init_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_init_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_init_tb
	rm -r e~config_ddr2_ctrl_init_tb.o
	mv config_ddr2_ctrl_init_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_init: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_init_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_init.o  ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_init_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_init_tb ${GHDL_RUN_ARGS}ddr2_ctrl_init.vcd

ddr2_ctrl_init_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_init
	make simulate_ddr2_ctrl_init

ddr2_ctrl_bank_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_bank_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_bank_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_bank_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_bank_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_bank_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_bank_ctrl_tb
	rm -r e~config_ddr2_ctrl_bank_ctrl_tb.o
	mv config_ddr2_ctrl_bank_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_bank_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_bank_ctrl.o  ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_bank_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_bank_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_bank_ctrl.vcd

ddr2_ctrl_bank_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_bank_ctrl
	make simulate_ddr2_ctrl_bank_ctrl

ddr2_ctrl_col_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_col_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_col_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_col_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_col_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_col_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_col_ctrl_tb
	rm -r e~config_ddr2_ctrl_col_ctrl_tb.o
	mv config_ddr2_ctrl_col_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_col_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_col_ctrl.o  ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_col_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_col_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_col_ctrl.vcd

ddr2_ctrl_col_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_col_ctrl
	make simulate_ddr2_ctrl_col_ctrl

ddr2_ctrl_ref_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ref_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_ref_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_ref_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_ref_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_ref_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_ref_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_ref_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_ref_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_ref_ctrl_tb
	rm -r e~config_ddr2_ctrl_ref_ctrl_tb.o
	mv config_ddr2_ctrl_ref_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_ref_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_ref_ctrl.o  ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ref_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_ref_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_ref_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_ref_ctrl.vcd

ddr2_ctrl_ref_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_ref_ctrl
	make simulate_ddr2_ctrl_ref_ctrl

ddr2_ctrl_cmd_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_cmd_ctrl_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_cmd_ctrl_cfg.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_cmd_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_cmd_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_cmd_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_cmd_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_cmd_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_cmd_ctrl_tb
	rm -r e~config_ddr2_ctrl_cmd_ctrl_tb.o
	mv config_ddr2_ctrl_cmd_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_cmd_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_bank_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_col_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_cmd_ctrl.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_cmd_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_cmd_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_cmd_ctrl.vcd

ddr2_ctrl_cmd_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_cmd_ctrl
	make simulate_ddr2_ctrl_cmd_ctrl

ddr2_ctrl_cmd_dec: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_dec_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_dec.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_dec.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_cmd_dec_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_cmd_dec_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_cmd_dec_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_cmd_dec_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_cmd_dec_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_cmd_dec_tb
	rm -r e~config_ddr2_ctrl_cmd_dec_tb.o
	mv config_ddr2_ctrl_cmd_dec_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_cmd_dec: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_cmd_dec.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_dec_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_cmd_dec_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_cmd_dec_tb ${GHDL_RUN_ARGS}ddr2_ctrl_cmd_dec.vcd

ddr2_ctrl_cmd_dec_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_cmd_dec
	make simulate_ddr2_ctrl_cmd_dec

ddr2_ctrl_arbiter: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_arbiter_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_arbiter_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_arbiter_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_arbiter_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_arbiter_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_arbiter_tb
	rm -r e~config_ddr2_ctrl_arbiter_tb.o
	mv config_ddr2_ctrl_arbiter_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_arbiter: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_arbiter_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_arbiter_tb ${GHDL_RUN_ARGS}ddr2_ctrl_arbiter.vcd

ddr2_ctrl_arbiter_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_arbiter
	make simulate_ddr2_ctrl_arbiter

ddr2_ctrl_arbiter_top: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_top_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_top.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_top.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_arbiter_top_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_arbiter_top_cfg.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_arbiter_top_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_arbiter_top_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_arbiter_top_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_arbiter_top_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_arbiter_top_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_arbiter_top_tb
	rm -r e~config_ddr2_ctrl_arbiter_top_tb.o
	mv config_ddr2_ctrl_arbiter_top_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_arbiter_top: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.o  ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter_top.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_top_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_arbiter_top_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_arbiter_top_tb ${GHDL_RUN_ARGS}ddr2_ctrl_arbiter_top.vcd

ddr2_ctrl_arbiter_top_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_arbiter_top
	make simulate_ddr2_ctrl_arbiter_top

ddr2_ctrl_odt_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_odt_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_odt_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_odt_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_odt_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_odt_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_odt_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_odt_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_odt_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_odt_ctrl_tb
	rm -r e~config_ddr2_ctrl_odt_ctrl_tb.o
	mv config_ddr2_ctrl_odt_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_odt_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_odt_ctrl.o  ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_odt_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_odt_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_odt_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_odt_ctrl.vcd

ddr2_ctrl_odt_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_odt_ctrl
	make simulate_ddr2_ctrl_odt_ctrl

ddr2_ctrl_mrs_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_mrs_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_mrs_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_mrs_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_mrs_ctrl_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_mrs_ctrl_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_mrs_ctrl_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_mrs_ctrl_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_mrs_ctrl_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_mrs_ctrl_tb
	rm -r e~config_ddr2_ctrl_mrs_ctrl_tb.o
	mv config_ddr2_ctrl_mrs_ctrl_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_mrs_ctrl: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_mrs_ctrl.o  ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_mrs_ctrl_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_mrs_ctrl_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_mrs_ctrl_tb ${GHDL_RUN_ARGS}ddr2_ctrl_mrs_ctrl.vcd

ddr2_ctrl_mrs_ctrl_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_mrs_ctrl
	make simulate_ddr2_ctrl_mrs_ctrl

ddr2_ctrl_regs: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_regs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_regs.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_regs.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_regs_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_regs_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_regs_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_regs_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_regs_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_regs_tb
	rm -r e~config_ddr2_ctrl_regs_tb.o
	mv config_ddr2_ctrl_regs_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_regs: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_regs.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_regs_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_regs_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_regs_tb ${GHDL_RUN_ARGS}ddr2_ctrl_regs.vcd

ddr2_ctrl_regs_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_regs
	make simulate_ddr2_ctrl_regs

ddr2_ctrl_ctrl_top: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_top_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_odt_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ref_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_mrs_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ctrl_top_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_top.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_arbiter_top.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_odt_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_odt_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_mrs_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_mrs_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_bank_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_cmd_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_col_ctrl.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_ref_ctrl.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_ctrl_top.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_DIR}/ddr2_ctrl_ctrl_top.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_arbiter_top_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_arbiter_top_cfg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_cmd_ctrl_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_cmd_ctrl_cfg.vhd
	@echo "Analysing ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_ctrl_top_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_RTL_GHDL_ARGS} ${DDR2_CTRL_RTL_CFG_DIR}/ddr2_ctrl_ctrl_top_cfg.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_ctrl_top_tb.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_TB_DIR}/ddr2_ctrl_ctrl_top_tb.vhd
	@echo "Analysing ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_ctrl_top_tb_cfg.vhd"
	${GHDL} -a ${DDR2_CTRL_TB_GHDL_ARGS} ${DDR2_CTRL_VERIF_CFG_DIR}/ddr2_ctrl_ctrl_top_tb_cfg.vhd
	@echo "Elaborating ddr2_ctrl_ctrl_top_tb_cfg"
	${GHDL} -e ${DDR2_CTRL_TB_GHDL_ARGS} config_ddr2_ctrl_ctrl_top_tb
	rm -r e~config_ddr2_ctrl_ctrl_top_tb.o
	mv config_ddr2_ctrl_ctrl_top_tb ${DDR2_CTRL_TB_WORK_DIR}

simulate_ddr2_ctrl_ctrl_top: ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_pkg_tb.o ${DDR2_CTRL_TB_PKG_WORK_DIR}/ddr2_log_pkg.o ${COMMON_RTL_PKG_WORK_DIR}/functions_pkg.o ${COMMON_TB_PKG_WORK_DIR}/functions_pkg_tb.o ${COMMON_TB_PKG_WORK_DIR}/shared_pkg_tb.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_define_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_ctrl_pkg.o  ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_arbiter_top.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_arbiter_top_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_mrs_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_gen_ac_timing_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_mrs_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_ref_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_odt_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_bank_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_col_ctrl.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_bank_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_col_ctrl_pkg.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_cmd_ctrl.o ${DDR2_CTRL_RTL_WORK_DIR}/ddr2_ctrl_ctrl_top.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_odt_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ref_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_mrs_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_cmd_ctrl_pkg.o ${DDR2_CTRL_RTL_PKG_WORK_DIR}/ddr2_ctrl_ctrl_top_pkg.o ${DDR2_CTRL_TB_WORK_DIR}/ddr2_ctrl_ctrl_top_tb.o
	cd ${DDR2_CTRL_TB_WORK_DIR} && ${GHDL} -r config_ddr2_ctrl_ctrl_top_tb ${GHDL_RUN_ARGS}ddr2_ctrl_ctrl_top.vcd

ddr2_ctrl_ctrl_top_all:
	make work_dir
	make common_libraries
	make ddr2_libraries
	make ddr2_ctrl_ctrl_top
	make simulate_ddr2_ctrl_ctrl_top
