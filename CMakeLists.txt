cmake_minimum_required(VERSION 3.15)
project(freetype-with-harfbuzz)

include(ExternalProject)

if (FALSE)
  
  # Step 1: Build FreeType w/o Harfbuzz
  # -------------------------------------------------------
  
  list(APPEND freetype_without_harfbuzz_byproduct
    <INSTALL_DIR>/lib/libfreetype.a
    )
  
  ExternalProject_Add(
    freetype_without_harfbuzz
    # URL https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
    # URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
    URL http://test.localhost/freetype-2.9.tar.gz
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DWITH_HarfBuzz=Off
      -DWITH_BZip2=Off
      -DWITH_ZLIB=Off
      -DWITH_PNG=Off
   # -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true
    
    BUILD_BYPRODUCTS ${freetype_without_harfbuzz_byproduct}
    )
  
  ExternalProject_Get_Property(freetype_without_harfbuzz install_dir)
  set(freetype_without_harfbuzz_dir ${install_dir})
  
  # Step 2: Build Harfbuzz with FreeType
  # -------------------------------------------------------
  
  ExternalProject_Add(
    harfbuzz
    DEPENDS freetype_without_harfbuzz
    # URL https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-2.6.4.tar.xz
    URL http://test.localhost/harfbuzz-2.6.4.tar.xz
    CONFIGURE_COMMAND FREETYPE_CFLAGS="-I${freetype_without_harfbuzz_dir}/include/freetype2/" FREETYPE_LIBS="${freetype_without_harfbuzz_dir}/lib/libfreetype.a" <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-static=yes --enable-shared=no
    )
  
  ExternalProject_Get_Property(harfbuzz install_dir)
  set(harfbuzz_dir ${install_dir})
  
  # Step 3: Build FreeType with Harfbuzz
  # -------------------------------------------------------
  ExternalProject_Add(
    freetype_with_harfbuzz
    DEPENDS harfbuzz
    URL http://test.localhost/freetype-2.9.tar.gz
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DCMAKE_MODULE_PATH="${CMAKE_MODULE_PATH} ${harfbuzz_dir}"
      -DWITH_HarfBuzz=On
      -DWITH_BZip2=Off
      -DWITH_ZLIB=Off
      -DWITH_PNG=Off
    BUILD_BYPRODUCTS ${freetype_without_harfbuzz_byproduct} # @todo remote the without part.
    )

  add_executable(test test.cpp)
  add_dependencies(test freetype_without_harfbuzz harfbuzz freetype_with_harfbuzz)
  install(TARGETS test DESTINATION bin)

endif()

if (FALSE)

  # Step 1: Build FreeType w/o Harfbuzz
  # -------------------------------------------------------
  
  list(APPEND freetype_without_harfbuzz_byproduct
    <INSTALL_DIR>/lib/freetype.lib
    )
  
  ExternalProject_Add(
    freetype_without_harfbuzz
    # URL https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
    # URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
    URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DWITH_HarfBuzz=Off
    -DWITH_BZip2=Off
    -DWITH_ZLIB=Off
    -DWITH_PNG=Off
    
    BUILD_BYPRODUCTS ${freetype_without_harfbuzz_byproduct}
    )
  
  ExternalProject_Get_Property(freetype_without_harfbuzz install_dir)
  set(freetype_without_harfbuzz_dir ${install_dir})

  # Step 2: Build Harfbuzz with FreeType
  # -------------------------------------------------------

  # @todo link dir different debug/relesae libs.
  ExternalProject_Add(
    harfbuzz
    DEPENDS freetype_without_harfbuzz
    # URL https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-2.6.4.tar.xz
    URL http://test.arch2080.rox.lu/harfbuzz-2.6.4.tar.xz
    # CONFIGURE_COMMAND FREETYPE_CFLAGS="-I${freetype_without_harfbuzz_dir}/include/freetype2/" FREETYPE_LIBS="${freetype_without_harfbuzz_dir}/lib/freetype.lib" <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-static=yes --enable-shared=no
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_PREFIX_PATH=${freetype_without_harfbuzz_dir}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DHB_HAVE_FREETYPE=On
    )
  
  ExternalProject_Get_Property(harfbuzz install_dir)
  set(harfbuzz_dir ${install_dir})

  # Step 3: Build FreeType with Harfbuzz
  # -------------------------------------------------------
  ExternalProject_Add(
    freetype_with_harfbuzz
    DEPENDS harfbuzz
    URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_PREFIX_PATH="${harfbuzz_dir}"
    -DCMAKE_MODULE_PATH="${harfbuzz_dir}"
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DWITH_harfbuzz=On
    -DWITH_BZip2=Off
    -DWITH_ZLIB=Off
    -DWITH_PNG=Off
    BUILD_BYPRODUCTS ${freetype_without_harfbuzz_byproduct} # @todo remote the without part.
    )

  # -------------------------------------------------------
  
  add_executable(test test.cpp)
  add_dependencies(test freetype_without_harfbuzz harfbuzz freetype_with_harfbuzz)
  install(TARGETS test DESTINATION bin)

  # -------------------------------------------------------
  
endif()



if (TRUE)

  # dumpbin /headers freetype.lib | findstr /i "metrics"
  
  # Set the name of the "byproduct" which is necessary when
  # using the Ninja generator.
  if (WIN32)
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      set(freetype_lib_name freetype.lib)
    else()
      set(freetype_lib_name freetyped.lib)
    endif()
  else()
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      set(freetype_lib_name libfreetype.a)
    else()
      set(freetype_lib_name libfreetype.a)
    endif()
  endif()
  
  
  # Step 1: Build FreeType w/o Harfbuzz
  # -------------------------------------------------------
  
  list(APPEND freetype_byproduct
    <INSTALL_DIR>/lib/${freetype_lib_name}
    )

  if (TRUE)
    ExternalProject_Add(
      freetype_without_harfbuzz
      # URL https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
      # URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
      URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
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

    list(APPEND deps freetype_without_harfbuzz)
  endif()

  # Step 2: Build Harfbuzz with FreeType
  # -------------------------------------------------------

  if (TRUE)
    # @todo link dir different debug/relesae libs.
    ExternalProject_Add(
      harfbuzz
      DEPENDS freetype_without_harfbuzz
      # URL https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-2.6.4.tar.xz
      URL http://test.arch2080.rox.lu/harfbuzz-2.6.4.tar.xz
      CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DCMAKE_PREFIX_PATH=${freetype_without_harfbuzz_dir}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DHB_HAVE_FREETYPE=On
      )
    
    ExternalProject_Get_Property(harfbuzz install_dir)
    set(harfbuzz_dir ${install_dir})

    list(APPEND deps harfbuzz)
    
  endif()

  # Step 3: Build FreeType with Harfbuzz
  # -------------------------------------------------------

  if (TRUE)
    message("HARFBUZZ DIR:  ${harfbuzz_dir}")
    
    ExternalProject_Add(
      freetype_with_harfbuzz
      DEPENDS harfbuzz
      URL http://test.arch2080.rox.lu/freetype-2.9.tar.gz
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
    
  endif()
  # -------------------------------------------------------
  
  add_executable(test test.cpp)
  add_dependencies(test ${deps})
  install(TARGETS test DESTINATION bin)

  # -------------------------------------------------------

endif()




