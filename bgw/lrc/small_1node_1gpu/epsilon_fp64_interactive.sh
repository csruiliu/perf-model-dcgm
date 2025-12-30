#!/bin/bash

# Allocating resources first, the following command is an example
# salloc -p es2 -A pc_perfume -q es2_normal --nodes=1 --ntasks=1 --cpus-per-task=16 --gres=gpu:H100:1 -t 12:00:00

# Start Singularity server first
# singularity instance start --fakeroot --nv --writable-tmpfs --bind /tmp:/tmp --network=none docker://nvidia/dcgm:4.4.1-2-ubuntu22.04 dcgm-instance

# singularity exec instance://dcgm-instance nv-hostengine -n &

#N10_BGW=/path/to/berkeleygw-workflow
N10_BGW="/global/scratch/users/rliu5/bgw-lrc-h100-fp64"
if [[ -z "${N10_BGW}" ]]; then
    echo "The N10_BGW variable is not defined."
    echo "Please set N10_BGW in site_path_config.sh and try again."
    exit 0
fi

N10_BGW_EXEC="${N10_BGW}/BerkeleyGW-n10/bin"

BGW_LRC="/global/homes/r/ruiliu/perf-model-dcgm/bgw/lrc"

BGW_SMALL="${BGW_LRC}/small_1node_1gpu"

Si_WFN_folder=${N10_BGW}/Si_WFN_folder

Si214_WFN_folder=${Si_WFN_folder}/Si214/WFN_file

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

DCGM_SAMPLE_RATE=1000

dcgm_delay=${DCGM_SAMPLE_RATE} srun -N 1 -c 16 --ntasks-per-node=1 --gpus-per-node=1 --cpu-bind=cores ${DCGM_PATH} ./epsilon.cplx.x > ${RESULTS_DIR}/${SLURM_JOB_ID}.out

unlink epsilon.cplx.x
unlink epsilon.inp
unlink WFN.h5
unlink WFNq.h5
rm -f eps0mat.h5
