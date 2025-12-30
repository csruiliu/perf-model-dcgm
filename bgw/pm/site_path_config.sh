#!/bin/bash

#libraries... you may need to add FFTW, or Scalapack or...
HDF_LIBPATH=
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HDF_LIBPATH

# Path for execution
#export N10_BGW_WORKFLOW=$N10_BGW/berkeleygw-workflow
export N10_BGW_EXEC="${N10_BGW}/BerkeleyGW-n10/bin"

export BGW_PM="/global/homes/r/ruiliu/perf-model-dcgm/bgw/pm"

#input data
Si_WFN_folder=${N10_BGW}/Si_WFN_folder
Si214_WFN_folder=${Si_WFN_folder}/Si214/WFN_file
Si510_WFN_folder=${Si_WFN_folder}/Si510/WFN_file
Si998_WFN_folder=${Si_WFN_folder}/Si998/WFN_file
Si2742_WFN_folder=${Si_WFN_folder}/Si2742/WFN_file

#Si214_Benchmark_folder=$N10_BGW_WORKFLOW/benchmark/small_Si214
#Si510_Benchmark_folder_Medium=$N10_BGW_WORKFLOW/benchmark/medium_Si510
#Si998_Benchmark_folder_=$N10_BGW_WORKFLOW/benchmark/reference_Si998
#Si2742_Benchmark_folder_Small=$N10_BGW_WORKFLOW/benchmark/target_Si2742

#any modules that should be loaded at runtime
if module list 2>&1 | grep -q "PrgEnv-gnu"; then
    module swap PrgEnv-gnu PrgEnv-nvidia
else
    module load PrgEnv-nvidia
fi
module load cray-hdf5-parallel
module load cray-fftw
module load cray-libsci