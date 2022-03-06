#!/bin/bash

export PATH=/opt/python/cp39-cp39/bin/:$PATH
#python3 -m pip install twine
cmake -Bbuild 
cmake --build build --target python_build
cd $1
python3 setup.py bdist_wheel --plat-name=manylinux_2_17_x86_64

#python3 -m twine upload --repository-url https://test.pypi.org/legacy/ --verbose dist/* -u $2 -p $3



