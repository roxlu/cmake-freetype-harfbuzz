cmake_minimum_required(VERSION 3.15)
project(freetype-with-harfbuzz)
include(ExternalProject)

# dumpbin /headers freetype.lib | findstr /i "metrics"

# Set the name of the "byproduct" which is necessary when using
# the Ninja generator and External Project dependencies.
# -------------------------------------------------------

if (WIN32)
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(freetype_lib_name freetyped.lib)
  else()
    set(freetype_lib_name freetype.lib)
  endif()
else()
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(freetype_lib_name libfreetyped.a)
  else()
    set(freetype_lib_name libfreetype.a)
  endif()
endif()

# Step 1: Build FreeType w/o Harfbuzz
# -------------------------------------------------------

list(APPEND freetype_byproduct
  <INSTALL_DIR>/lib/${freetype_lib_name}
  )

ExternalProject_Add(
  freetype_without_harfbuzz
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
  CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DWITH_HarfBuzz=Off
  -DWITH_BZip2=Off
  -DWITH_ZLIB=Off
  -DWITH_PNG=Off
  BUILD_BYPRODUCTS ${freetype_byproduct}
  )

ExternalProject_Get_Property(freetype_without_harfbuzz install_dir)
set(freetype_without_harfbuzz_dir ${install_dir})

# Step 2: Build Harfbuzz with FreeType
# -------------------------------------------------------

# When I use the CMake build solution for HarfBuzz I run into
# an regarding some symbols. The autotools build process
# works fine, so that's what I'm using on Linux.

if (WIN32)

  ExternalProject_Add(
    harfbuzz
    DEPENDS freetype_without_harfbuzz
    URL https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-2.6.4.tar.xz
    URL http://test.arch2080.rox.lu/harfbuzz-2.6.4.tar.xz
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_PREFIX_PATH=${freetype_without_harfbuzz_dir}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DHB_HAVE_FREETYPE=On
    )
  
else()
  
  ExternalProject_Add(
    harfbuzz
    DEPENDS freetype_without_harfbuzz
    URL https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-2.6.4.tar.xz
    CONFIGURE_COMMAND FREETYPE_CFLAGS="-I${freetype_without_harfbuzz_dir}/include/freetype2/" FREETYPE_LIBS="${freetype_without_harfbuzz_dir}/lib/${freetype_lib_name}" <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-static=yes --enable-shared=no
    )

endif()

ExternalProject_Get_Property(harfbuzz install_dir)
set(harfbuzz_dir ${install_dir})

# Step 3: Build FreeType with Harfbuzz
# -------------------------------------------------------

ExternalProject_Add(
  freetype_with_harfbuzz
  DEPENDS harfbuzz
  URL https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
  PATCH_COMMAND git apply --ignore-space-change --ignore-whitespace "${CMAKE_CURRENT_LIST_DIR}/freetype-harfbuzz-windows-fix.patch"
  CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  -DCMAKE_PREFIX_PATH=${harfbuzz_dir}
  -DCMAKE_MODULE_PATH=${harfbuzz_dir}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DWITH_BZip2=Off
  -DWITH_ZLIB=Off
  -DWITH_PNG=Off
  BUILD_BYPRODUCTS ${freetype_byproduct}
  )

list(APPEND deps freetype_with_harfbuzz)

# -------------------------------------------------------

add_executable(test test.cpp)
add_dependencies(test ${deps})
install(TARGETS test DESTINATION bin)

# -------------------------------------------------------





