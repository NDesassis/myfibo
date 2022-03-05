# Python package name
set(PYTHON_PACKAGE_NAME ${PROJECT_NAME})
# Beware : the real package name is the PROJECT_NAME (for better import)

# Create the global target for building python package
add_custom_target(python_build_package)

###################################
# DEPENDENCIES

# Look for Python3
find_package(Python3 REQUIRED COMPONENTS Interpreter Development.Module)

# Look for SWIG 4
find_package(SWIG 4.0 REQUIRED)
include(${SWIG_USE_FILE})


######################################
# WRAPPER GENERATION & BUILD

# Python package target
set(PYTGT python_build)

# Interface file
set(SRC fibo.i) 
# No need to define %module in the interface file

# Generation folders
if (MSVC) # TODO: Prefer using GENERATOR_IS_MULTI_CONFIG ?
  set(PYTHON_PACKAGE_ROOT_FOLDER        ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>)
else()
  set(PYTHON_PACKAGE_ROOT_FOLDER        ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
endif()
set(PYTHON_PACKAGE_DESTINATION_FOLDER ${PYTHON_PACKAGE_ROOT_FOLDER}/${PYTHON_PACKAGE_NAME})
# Location for SWIG target language code
set(CMAKE_SWIG_OUTDIR                 ${PYTHON_PACKAGE_DESTINATION_FOLDER})
# Location for SWIG wrapper library
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY    ${PYTHON_PACKAGE_DESTINATION_FOLDER}) # Use LIBRARY (gcc)!
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY    ${PYTHON_PACKAGE_DESTINATION_FOLDER}) # Use RUNTIME (msvc)!

# SWIG interface source file
set_source_files_properties(${SRC} PROPERTIES
  CPLUSPLUS ON
  # Swig wrapper will be regenerated if C++ headers are changed
  # https://stackoverflow.com/a/70375654/3952924
  #USE_SWIG_DEPENDENCIES TRUE   # TODO : Incompatible with CMAKE_SWIG_OUTDIR under cmake 3.22 (MSVC)
  # myfibo C++ headers will be found by %import directive
  USE_TARGET_INCLUDE_DIRECTORIES TRUE
  # Python package name will be the name of the installed folder (no module)
  SWIG_MODULE_NAME __init__
)

# Tell to CMake that ${SRC} depends on some other files
# TODO: This only works on GCC because MSVC always recompile swig (don't know why)
set_property(SOURCE ${SRC} PROPERTY
  DEPENDS
    ${PROJECT_SOURCE_DIR}/swig/swig_exp.i
    ${PROJECT_SOURCE_DIR}/swig/swig_inc.i
)

# SWIG flags
set(CMAKE_SWIG_FLAGS -py3 -keyword)
# Note: Cannot use -doxygen feature because all documentation is in C++ body files
# Note: Use -E option for seeing SWIG preprocessor output

# SWIG target (generate wrapper & python script then build [so,pyd] library)
swig_add_library(
  ${PYTGT}
  LANGUAGE   python
  TYPE       SHARED
  SOURCES    ${SRC}
)

# Link to static library
target_link_libraries(${PYTGT} PUBLIC ${PROJECT_NAME}::static)

# Transmit the fact that we are linking to static ${PROJECT_NAME} library
if (MSVC)
  set(COMP_FLAGS "/bigobj -D${PROJECT_NAME_UP}_STATIC_DEFINE")
else()
  set(COMP_FLAGS "-D${PROJECT_NAME_UP}_STATIC_DEFINE")
endif()
# Set some properties on SWIG target
set_target_properties(${PYTGT} PROPERTIES
  # Do not build python package by default
  EXCLUDE_FROM_ALL ON
  # Modify the generated library name
  OUTPUT_NAME ${PROJECT_NAME}
  # Transmit the fact that we are linking to static ${PROJECT_NAME} library
  COMPILE_FLAGS ${COMP_FLAGS}
)

# Find appropriate Python.h
target_include_directories(${PYTGT} PRIVATE ${Python3_INCLUDE_DIRS})

# Link to python's libraries (only for MSVC - Release)
if(MSVC)
  target_link_libraries(${PYTGT} PRIVATE ${Python3_LIBRARIES})
endif()

# Add SWIG target to global python build package dependency
add_dependencies(python_build_package ${PYTGT})


########################################
# PACKAGING (target independent)

# Generate setup.py automatically for each configuration
# First step: replace variables (@VAR@)
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in 
  ${CMAKE_CURRENT_BINARY_DIR}/setup.py.in
  @ONLY
)

# Second step: replace generator expression ($<>)
file(GENERATE
  OUTPUT ${PYTHON_PACKAGE_ROOT_FOLDER}/setup.py
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/setup.py.in
)

# Generate README.md for each configuration
file(GENERATE
  OUTPUT ${PYTHON_PACKAGE_ROOT_FOLDER}/README.md
  INPUT  ${CMAKE_CURRENT_SOURCE_DIR}/README.md
)

######################################
# INSTALLATION

# Add a custom target for python package installation
# TODO: Do also installation each time setup.py.in or README.md is modified
add_custom_target(python_install
  COMMAND ${Python3_EXECUTABLE} -m pip install ${PYTHON_PACKAGE_ROOT_FOLDER}
  COMMENT "Installing python package"
  VERBATIM
)

# Tell cmake that python package must be built before installation
add_dependencies(python_install python_build_package)


