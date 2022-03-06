#!/bin/bash

if [ $2 = "cp38" ]; then
	export PATH=/opt/python/cp38-cp38/bin/:$PATH
fi

if [ $2 = "cp39" ]; then
	export PATH=/opt/python/cp39-cp39/bin/:$PATH
fi


cmake -Bbuild 
cmake --build build --target python_build
cd $1
python3 setup.py bdist_wheel --python-tag=$2 --plat-name=manylinux_2_17_x86_64



