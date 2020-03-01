# Compile Freetype and Harfbuzz 

Freetype and Harfbuzz have a cyclic dependency which makes it a
bit more work when you want to use these libraries as an External
Project with CMake.

This repository contains an example on how you can build Freetype
and HarfBuzz with support for each other. First we compile Freetype
without HarfBuzz support, then we compile HarfBuzz with Freetype
support and then we recompile Freetype again with HarfBuzz support.

I've tested this on Arch Linux, GCC 9.2.1 and on Windows 10 with
Visual Studio Community 2019.

## Usage on Linux

    git clone git@github.com:roxlu/cmake-freetype-harfbuzz.git
    cd cmake-freetype-harfbuzz
    ./build.sh
    
## Usage on Windows

Open a "x64 Native Tools Command Prompt for VS 2019" and execute:
  
    git clone git@github.com:roxlu/cmake-freetype-harfbuzz.git
    cd cmake-freetype-harfbuzz
    ./build.bat
    
