#! /usr/bin/bash

BASE_DIRECTORY=$(pwd)
SOURCE_DIRECTORY=${BASE_DIRECTORY}/quda
BUILD_DIRECTORY=${BASE_DIRECTORY}/build
INSTALL_DIRECTORY=${BASE_DIRECTORY}/install


pushd .

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

popd
