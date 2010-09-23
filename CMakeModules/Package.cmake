# Enable printf format macros from <inttypes.h> in C++ code.
ADD_DEFINITIONS (-D__STDC_FORMAT_MACROS)

# Enable 64-bit off_t type to work with big files.
ADD_DEFINITIONS (-D_FILE_OFFSET_BITS=64)

# Enable ignore errors mode in Judy macros.
#ADD_DEFINITIONS (-DJUDYERROR_NOTEST)

SET (LIBDIR lib)
IF (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  SET (LIBDIR lib64)
ENDIF (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")

# Don't know if this is needed with one monolith CMakeLists.txt file.
#SET (CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
#SET (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
#SET (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Make FIND_LIBRARY search for static libs only and make it search inside lib64
# directory in addition to the usual lib one.

#SET (CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
SET (CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_STATIC_LIBRARY_PREFIX})
SET (FIND_LIBRARY_USE_LIB64_PATHS TRUE)
SET (LINK_SEARCH_END_STATIC TRUE)

# Include source tree root, include directory inside it and build tree root,
# which is for files, generated by cmake from templates (e.g. autogenerated
# C/C++ includes).

INCLUDE_DIRECTORIES (${PROJECT_BINARY_DIR})
INCLUDE_DIRECTORIES (${PROJECT_SOURCE_DIR})
#INCLUDE_DIRECTORIES (${PROJECT_SOURCE_DIR}/include)

###############################################################################
# USE_INCLUDE (var inc [FIND_PATH_ARGS ...])
# -----------------------------------------------------------------------------
# Find include [inc] using standard FIND_PATH command and save its dirname into
# variable named [var]. Also include its dirname into project.

MACRO (USE_INCLUDE var inc)
  FIND_PATH (${var} ${inc} ${ARGN})
  IF (${var})
    MESSAGE (STATUS "FOUND ${${var}}/${inc}")  # SHOULD BE BOLD GREEN
    INCLUDE_DIRECTORIES (${${var}})
  ELSE (${var})
    MESSAGE (STATUS "ERROR ${${var}}/${inc}")  # SHOULD BE BOLD RED
  ENDIF (${var})
ENDMACRO (USE_INCLUDE)

# USE_LIBRARY (var lib)
# -----------------------------------------------------------------------------
# Find library [lib] using standard FIND_LIBRARY command and save its path into
# variable named [var].

MACRO (USE_LIBRARY var lib)
  FIND_LIBRARY (${var} ${lib})
  IF (${var})
    MESSAGE (STATUS "FOUND ${${var}}")  # SHOULD BE BOLD GREEN
  ELSE (${var})
    MESSAGE (STATUS "ERROR ${${var}}")  # SHOULD BE BOLD RED
  ENDIF (${var})
ENDMACRO (USE_LIBRARY)

# USE_PACKAGE (var lib inc [FIND_PATH_ARGS ...])
# -----------------------------------------------------------------------------
# Find package using USE_LIBRARY and USE_INCLUDE macros.

MACRO (USE_PACKAGE lib inc)
  USE_LIBRARY (LIB_${lib} ${lib})
  USE_INCLUDE (INC_${lib} ${inc} ${ARGN})
ENDMACRO (USE_PACKAGE)

# USE_SUBPATH (var sub)
# -----------------------------------------------------------------------------
# Find subpath [sub] using standard FIND_PATH command and save its dirname into
# variable named [var].

MACRO (USE_SUBPATH var sub)
  FIND_PATH (${var}_PREFIX ${sub} ONLY_CMAKE_FIND_ROOT_PATH)
  IF (${var}_PREFIX)
    GET_FILENAME_COMPONENT (${var} "${${var}_PREFIX}/${sub}" PATH)
    MESSAGE (STATUS "FOUND ${var}=${${var}}")
  ELSE (${var}_PREFIX)
    MESSAGE (STATUS "ERROR ${var}")
  ENDIF (${var}_PREFIX)
ENDMACRO (USE_SUBPATH)

###############################################################################
# MAKE_PROGRAM (apath)
# -----------------------------------------------------------------------------
# Make program (executable) from source code inside the [apath] subfolder and
# install it.

MACRO (MAKE_PROGRAM apath)
  GET_FILENAME_COMPONENT (${apath}_NAME "${apath}" NAME)
  AUX_SOURCE_DIRECTORY (${apath} SRC_${${apath}_NAME})
  ADD_EXECUTABLE (${${apath}_NAME} ${SRC_${${apath}_NAME}})
  IF (${ARGC} GREATER 1)
    TARGET_LINK_LIBRARIES (${${apath}_NAME} ${ARGN})
  ENDIF (${ARGC} GREATER 1)
  INSTALL (TARGETS ${${apath}_NAME} DESTINATION bin)
ENDMACRO (MAKE_PROGRAM)

# MAKE_LIBRARY (apath <SHARED|STATIC> [LIBRARIES_TO_LINK_WITH [...]])
# -----------------------------------------------------------------------------
# Make library of SHARED or STATIC type from source code inside the [apath]
# subfolder and install it and all header files from the subfolder.

MACRO (MAKE_LIBRARY apath atype)
  GET_FILENAME_COMPONENT (${apath}_NAME "${apath}" NAME)
  AUX_SOURCE_DIRECTORY (${apath} SRC_${${apath}_NAME})
  ADD_LIBRARY (${${apath}_NAME} ${atype} ${SRC_${${apath}_NAME}})
  IF (${ARGC} GREATER 2)
    TARGET_LINK_LIBRARIES (${${apath}_NAME} ${ARGN})
  ENDIF (${ARGC} GREATER 2)
  # TODO SET_TARGET_PROPERTIES (...)
  INSTALL (TARGETS ${${apath}_NAME} DESTINATION ${LIBDIR})
  INSTALL (DIRECTORY ${apath} DESTINATION include FILES_MATCHING PATTERN "*.h")
  INSTALL (DIRECTORY ${apath} DESTINATION include FILES_MATCHING PATTERN "*.hpp")
  INSTALL (DIRECTORY ${apath} DESTINATION include FILES_MATCHING PATTERN "*.tcc")
ENDMACRO (MAKE_LIBRARY)

# MAKE_SHARED (apath [LIBRARIES_TO_LINK_WITH [...]])
# -----------------------------------------------------------------------------
# Make SHARED library with MAKE_LIBRARY macro.

MACRO (MAKE_SHARED apath)
  MAKE_LIBRARY (${apath} SHARED ${ARGN})
ENDMACRO (MAKE_SHARED)

# MAKE_STATIC (apath [LIBRARIES_TO_LINK_WITH [...]])
# -----------------------------------------------------------------------------
# Make STATIC library with MAKE_LIBRARY macro.

MACRO (MAKE_STATIC apath)
  MAKE_LIBRARY (${apath} STATIC ${ARGN})
ENDMACRO (MAKE_STATIC)

###############################################################################
# GET_LOCALTIME (var [format [tmzone]])
# -----------------------------------------------------------------------------
# Print system date and time regarding to specified [format] and [tmzone]. If
# either [format] or [tmzone] is omitted, the default settings for the current
# locale will take the place.
# TODO make variadic.

#MACRO (GET_LOCALTIME var format tmzone)
#  SET_IF_NOT_SET (o_format "${format}")
#  SET_IF_NOT_SET (o_format "%c")
#  SET_IF_NOT_SET (o_tmzone "${tmzone}")
#  SET_IF_NOT_NIL (o_tmzone "-d'now GMT${o_tmzone}'")
#  ADD_CUSTOM_COMMAND (OUTPUT var COMMAND "date +'${o_format}' ${o_tmzone}")
#ENDMACRO (GET_LOCALTIME)

