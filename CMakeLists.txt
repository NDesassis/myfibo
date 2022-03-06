#########
# GCC
#########
# Build static library (and install python package)
# cmake -Bbuild -H.
# cmake --build build --target python_install

# Build and install shared library (and don't build python package)
# cmake -Bbuild -H. -DCMAKE_INSTALL_PREFIX=/home/fors/myfibo_install
# cmake --build build --target install

#########
# MSVC
#########
# Build static library (and install python package)
# cmake -Bbuild -H.
# cmake --build build --target python_install --config Release

# Build and install shared library (and don't build python package)
# cmake -Bbuild -H. -DCMAKE_INSTALL_PREFIX=C:/users/user/myfibo_install
# cmake --build build --target install --config Release

# For recent UseSWIG
cmake_minimum_required(VERSION 3.20)

# Verbose makefiles
#set(CMAKE_VERBOSE_MAKEFILE ON)

# Define project here
project(myfibo
  VERSION      0.0.2
  DESCRIPTION  "Fibonacci simple class"
  HOMEPAGE_URL "https://github.com/fabien-ors/myfibo"
  LANGUAGES    C CXX # Enable C language for third party libraries
)

####################################################
## CONFIGURATION

# Get the project date
string(TIMESTAMP ${PROJECT_NAME}_DATE "%Y/%m/%d - %H:%M")

# Convert project name to uppercase
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UP)

# Fix version.h automatically
configure_file(version.h.in version.h)

# Activate verbose mode
#set(CMAKE_VERBOSE_MAKEFILE ON)

####################################################
## BUILD

include(cmake/cpp.cmake)
# TODO : Add doxygen feature
#include(cmake/doxygen.cmake)
include(cmake/install.cmake)


####################################################
## PACKAGES

add_subdirectory(python)


####################################################
## TESTING

# Add build_test and test targets
include(CTest)
enable_testing()

add_subdirectory(tests)


