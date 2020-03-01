#!/bin/sh

d=${PWD}
bd=${d}/build
id=${d}/installed

if [ ! -d ${bd} ] ; then
    mkdir ${bd}
fi

cd ${bd}
cmake -G "Ninja" \
      -DCMAKE_INSTALL_PREFIX=${id} \
      -DCMAKE_BUILD_TYPE="Release" \
      ..

if [ $? -ne 0 ] ; then
    echo "Failed to configure"
    exit
fi

ninja


