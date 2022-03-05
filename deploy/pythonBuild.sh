#!/bin/bash

export PATH=/opt/python/cp39-cp39/bin/:$PATH
python3 -m pip install twine
cmake -Bbuild 
cmake --build build --target python_build
cd $3
python3 setup.py bdist_wheel --plat-name=manylinux_2_x86_64

export TWINE_USERNAME=$1
export TWINE_PASSWORD=$2

echo $3/dist/
python3 -m twine upload --repository-url https://test.pypi.org/legacy/ $3/dist/*


