#!/bin/sh

WORK_DIRNAME=work

if [ -n "${PROC_PROJ}" ]; then
	WORK_DIR=${PROC_PROJ}/VHDL_code/work
fi

# $WORK_DIR doesn't exist or $PROJ_DIR is not defined
if [ ! -d ${WORK_DIR} ] || [ ! -n "${PROC_PROJ}" ]; then

	echo Looking for $WORK_DIRNAME in tree from current directory `pwd`

	#initialize exit status and work directory
	WORK_DIR=`pwd`
	SEARCH_EXIT_STATUS=1

	while [ $SEARCH_EXIT_STATUS -eq 1 ];
	do
		ls -d ${WORK_DIR}/*/ 2>/dev/null | grep $WORK_DIRNAME
		SEARCH_EXIT_STATUS=$?

		if [ ${SEARCH_EXIT_STATUS} -eq 1 ]; then
			if [ "${WORK_DIR}" = "/" ]; then
				echo No $WORK_DIRNAME directory found in tree
				echo Root directory reached
				echo Exiting with exit status 1
				exit 1
			else
				WORK_DIR=`readlink --canonicalize ${WORK_DIR}/..`
			fi
		else
			WORK_DIR=${WORK_DIR}/${WORK_DIRNAME}
		fi
	done
fi

echo Work directory: ${WORK_DIR}

SUMMARY_LOC=${WORK_DIR}
SUMMARY_LOG_BASENAME=summary
DATE=`date +%d_%b_%y`
TIME=`date +%H_%M_%S`

if [ -f ${SUMMARY_LOC}/${SUMMARY_LOG_BASENAME} ]; then
	SUMMARY_LOG_NAME=${SUMMARY_LOG_BASENAME}_DATE_${DATE}_TIME_${TIME}
else
	SUMMARY_LOG_NAME=${SUMMARY_LOG_BASENAME}
fi

echo Summary file name: ${SUMMARY_LOG_NAME}

SUMMARY_LOG_FULL_PATH=${SUMMARY_LOC}/${SUMMARY_LOG_NAME}
echo Summary file full path: ${SUMMARY_LOG_FULL_PATH}
summary_files=`find ${WORK_DIR} -mindepth 2 -name 'summary'`
cat ${summary_files} > ${SUMMARY_LOG_FULL_PATH}

NUM_FAILS=`grep -c 'FAILED' ${SUMMARY_LOG_FULL_PATH}`
NUM_PASSES=`grep -c 'PASSED' ${SUMMARY_LOG_FULL_PATH}`
TOT_TESTS=`expr "${NUM_FAILS}" + "${NUM_PASSES}"`
TEST_PASSED=`sed -n '/PASSED/p' ${SUMMARY_LOG_FULL_PATH} | sed 's/:.*/,/' | sed 's/, /,/'`
TEST_FAILED=`sed -n '/FAILED/p' ${SUMMARY_LOG_FULL_PATH} | sed 's/:.*/,/' | sed 's/, /,/'`
echo
echo "============================"
echo "     Regression results"
echo "============================"
echo
echo PASS: ${NUM_PASSES} out of ${TOT_TESTS} tests
echo
if [ ${NUM_PASSES} -gt 0 ]; then
	echo Test passed:
	echo ' '$TEST_PASSED | tr ',' '\n'
else
	echo No test passed
fi
echo FAIL: ${NUM_FAILS} out of ${TOT_TESTS} tests
echo 
if [ ${NUM_FAILS} -gt 0 ]; then
	echo Test failed:
	echo $TEST_FAILED | tr ',' '\n'
else
	echo No test failed
fi
