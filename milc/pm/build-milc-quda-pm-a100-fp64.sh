#!/bin/bash

BASE_DIRECTORY=$(pwd)
SOURCE_DIRECTORY=${BASE_DIRECTORY}/quda
BUILD_DIRECTORY=${BASE_DIRECTORY}/build
INSTALL_DIRECTORY=${BASE_DIRECTORY}/install
MILC_DIRECTORY=${BASE_DIRECTORY}/milc_qcd

# Hack to find the CUDA directory
CUDA_DIRECTORY=$(which nvcc)
CUDA_DIRECTORY=${CUDA_DIRECTORY/\bin\/nvcc/}

pushd .

#############################################
# Part 1: Build QUDA
#############################################

cd $BASE_DIRECTORY
if [ ! -d ${SOURCE_DIRECTORY} ]
then
  git clone --branch develop https://github.com/lattice/quda ${SOURCE_DIRECTORY}
fi

cd ${SOURCE_DIRECTORY}
git checkout c75b77c731eb9ad16c93b4fc312e80225a84f1ea

mkdir -p ${BUILD_DIRECTORY}
mkdir -p ${INSTALL_DIRECTORY}

cd ${BUILD_DIRECTORY}

cmake ${BASE_DIRECTORY}/quda/ \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY} \
  -DQUDA_GPU_ARCH=sm_80 \
  -DQUDA_DIRAC_DEFAULT_OFF=ON \
  -DQUDA_DIRAC_STAGGERED=ON \
  -DQUDA_QMP=ON \
  -DQUDA_QIO=ON \
  -DCUDA_cublas_LIBRARY=$CUDA_MATH/lib64/libcublas.so \
  -DCUDA_cufft_LIBRARY=$CUDA_MATH/lib64/libcufft.so \
  -DQUDA_DOWNLOAD_USQCD=ON && \
cmake --build ${BUILD_DIRECTORY} --target all -- -j && \
cmake --build ${BUILD_DIRECTORY} --target install -- -j

# Check if QUDA build was successful
if [ $? -ne 0 ]; then
  echo "QUDA build failed, exiting..."
  popd
  exit 1
fi

#############################################
# Part 2: Build MILC
#############################################

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
QUDA_HOME=${INSTALL_DIRECTORY} \
WANTQUDA=true \
WANT_FN_CG_GPU=true \
WANT_FL_GPU=true \
WANT_GF_GPU=true \
WANT_FF_GPU=true \
WANT_GA_GPU=true \
WANT_MIXED_PRECISION_GPU=0 \
PRECISION=2 \
MPP=true \
OMP=true \
WANTQIO=true \
WANTQMP=true \
QIOPAR=${INSTALL_DIRECTORY} \
QMPPAR=${INSTALL_DIRECTORY} \
LDFLAGS="-L${CUDA_MATH}/lib64 -Wl,-rpath,${CUDA_MATH}/lib64" \
make -j 1 su3_rhmd_hisq

popd