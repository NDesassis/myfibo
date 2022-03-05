#!/bin/bash

export PATH = /opt/python/$PATH
cmake -Bbuild 
cmake --build build --target python_build
python3 setup.py bdist_wheel --plat-name=manylinux_2_x86_64

