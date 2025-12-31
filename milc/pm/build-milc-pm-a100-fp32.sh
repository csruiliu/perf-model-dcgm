#! /usr/bin/bash

BASE_DIRECTORY=$(pwd)
QUDA_DIRECTORY=${BASE_DIRECTORY}/install
MILC_DIRECTORY=${BASE_DIRECTORY}/milc_qcd

# Hack to find the CUDA directory
CUDA_DIRECTORY=$(which nvcc)
CUDA_DIRECTORY=${CUDA_DIRECTORY/\bin\/nvcc/}

pushd .

cd $BASE_DIRECTORY
if [ ! -d ${MILC_DIRECTORY} ]
then
  git clone --branch develop https://github.com/milc-qcd/milc_qcd ${MILC_DIRECTORY}
fi

cd ${MILC_DIRECTORY}
git checkout f803f4bf

cd ${MILC_DIRECTORY}/ks_imp_rhmc

if [ ! -f "./Makefile" ]
then
  cp ../Makefile .
fi

if [ -f "./su3_rhmd_hisq" ]
then
  rm ./su3_rhmd_hisq
fi

COMPILER="gnu" \
CTIME="-DCGTIME -DFFTIME -DGATIME -DGFTIME -DREMAP -DPRTIME -DIOTIME" \
CGEOM="-DFIX_NODE_GEOM -DFIX_IONODE_GEOM" \
MY_CC=cc \
MY_CXX=CC \
CUDA_HOME=${CUDA_DIRECTORY} \
QUDA_HOME=${QUDA_DIRECTORY} \
WANTQUDA=true \
WANT_FN_CG_GPU=true \
WANT_FL_GPU=true \
WANT_GF_GPU=true \
WANT_FF_GPU=true \
WANT_GA_GPU=true \
WANT_MIXED_PRECISION_GPU=0 \
PRECISION=1 \
MPP=true \
OMP=true \
WANTQIO=true \
WANTQMP=true \
QIOPAR=${QUDA_DIRECTORY} \
QMPPAR=${QUDA_DIRECTORY} \
LDFLAGS="-L${CUDA_MATH}/lib64 -Wl,-rpath,${CUDA_MATH}/lib64" \
make -j 1 su3_rhmd_hisq

popd
