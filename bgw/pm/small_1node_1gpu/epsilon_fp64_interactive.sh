#!/bin/bash

source ../../common/site_path_config.sh

#N10_BGW=/path/to/berkeleygw-workflow
export N10_BGW="/pscratch/sd/r/ruiliu/bgw-pm-a100-fp64"
if [[ -z "${N10_BGW}" ]]; then
    echo "The N10_BGW variable is not defined."
    echo "Please set N10_BGW in site_path_config.sh and try again."
    exit 0
fi

export BGW_SMALL="${BGW_PM}/small_1node_1gpu"

export RESULTS_DIR="${BGW_PM}/results/EPS_SMALL_FP64_${SLURM_JOB_ID}"

mkdir -p $RESULTS_DIR
#stripe_large $RESULTS_DIR
cd    ${RESULTS_DIR}
ln -s ${N10_BGW_EXEC}/epsilon.cplx.x .
ln -s  ${BGW_SMALL}/epsilon.inp .
ln -sfn  ${Si214_WFN_folder}/WFNq.h5      .
ln -sfn  ${Si214_WFN_folder}/WFN_out.h5   ./WFN.h5

ulimit -s unlimited

export OMP_NUM_THREADS=16
export OMP_PLACES=cores
export OMP_PROC_BIND=spread

export HDF5_USE_FILE_LOCKING=FALSE
export BGW_HDF5_WRITE_REDIST=1
export BGW_WFN_HDF5_INDEPENDENT=1

DCGM_PATH="${BGW_PM}/wrap_dcgmi_container.sh"

export DCGM_SAMPLE_RATE=1000

dcgm_delay=${DCGM_SAMPLE_RATE} srun -N 1 -c 32 --ntasks-per-node=1 --gpus-per-node=1 --cpu-bind=cores ${DCGM_PATH} ./epsilon.cplx.x > ${RESULTS_DIR}/${SLURM_JOB_ID}.out

unlink epsilon.cplx.x
unlink epsilon.inp
unlink WFN.h5
unlink WFNq.h5
rm -f eps0mat.h5
