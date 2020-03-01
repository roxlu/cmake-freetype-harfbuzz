@echo off

set d=%cd%
set bd=%cd%/build
set id=%cd$/installed

if not exist %bd% (
  mkdir "%bd%"
)

cd "%bd%"

cmake -G "Ninja" ^
      -DCMAKE_BUILD_TYPE="Release" ^
      -DCMAKE_INSTALL_PREFIX="${id}" ^
      ..

if errorlevel 1 (
  goto :error
)
 
ninja

if errorlevel 1 (
  goto :error
)

goto :success

:error
echo "Failed."

:success
cd %d%
