#!/usr/bin/env bash

######################################################################
# Torch install
#
# This script installs Torch7, and a few extra packages
# (penlight, optim, parallel, image).
# 
# The install is done via Luarocks, which enables package
# versions. This is the recommended method to deploy Torch,
# torch-pkg is being deprecated.
#
#    Once this script has been run once, you should be able to run
#    extra luarocks commands, and in particular install new packages:
#    $ luarocks install json
#    $ torch
#    > require 'json'
#
######################################################################
{

# Prefix:
PREFIX=${PREFIX-/usr/local}
echo "Installing Torch into: $PREFIX"

if [[ `uname` == 'Linux' ]]; then
    export CMAKE_LIBRARY_PATH=/opt/OpenBLAS/include:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH
fi

# Build and install Torch7
cd /tmp
git clone https://github.com/torch/luajit-rocks.git
cd luajit-rocks
mkdir build; cd build
git checkout master; git pull
rm -f CMakeCache.txt
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
make
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
make install || sudo -E make install
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
# check if we are on mac and fix RPATH for local install
path_to_install_name_tool=$(which install_name_tool)
if [ -x "$path_to_install_name_tool" ] 
then
   install_name_tool -id ${PREFIX}/lib/libluajit.dylib ${PREFIX}/lib/libluajit.dylib
fi

# Statuses:
sundown=ok
cwrap=ok
paths=ok
torch=ok
nn=ok
dok=ok
gnuplot=ok
qtlua=ok
qttorch=ok
lfs=ok
penlight=ok
sys=ok
xlua=ok
image=ok
optim=ok
cjson=ok
trepl=ok

path_to_nvcc=$(which nvcc)
if [ -x "$path_to_nvcc" ]
then  
    cutorch=ok
    cunn=ok
fi

# Install base packages:
$PREFIX/bin/luarocks install sundown       ||  sudo -E $PREFIX/bin/luarocks install sundown
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install cwrap         ||  sudo -E $PREFIX/bin/luarocks install cwrap  
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install paths         ||  sudo -E $PREFIX/bin/luarocks install paths  
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install torch         ||  sudo -E $PREFIX/bin/luarocks install torch  
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install nn            ||  sudo -E $PREFIX/bin/luarocks install nn     
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install dok           ||  sudo -E $PREFIX/bin/luarocks install dok    
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install gnuplot       ||  sudo -E $PREFIX/bin/luarocks install gnuplot
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
[ -n "$cutorch" ] && \
($PREFIX/bin/luarocks install cutorch      ||  sudo -E $PREFIX/bin/luarocks install cutorch        ||   cutorch=failed )
[ -n "$cunn" ] && \
($PREFIX/bin/luarocks install cunn         ||  sudo -E $PREFIX/bin/luarocks install cunn           ||   cunn=failed )

$PREFIX/bin/luarocks install qtlua         ||  sudo -E $PREFIX/bin/luarocks install qtlua  
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install qttorch       ||  sudo -E $PREFIX/bin/luarocks install qttorch
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install luafilesystem ||  sudo -E $PREFIX/bin/luarocks install luafilesystem
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install penlight      ||  sudo -E $PREFIX/bin/luarocks install penlight 
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install sys           ||  sudo -E $PREFIX/bin/luarocks install sys      
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install xlua          ||  sudo -E $PREFIX/bin/luarocks install xlua     
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install image         ||  sudo -E $PREFIX/bin/luarocks install image    
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install optim         ||  sudo -E $PREFIX/bin/luarocks install optim    
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install lua-cjson     ||  sudo -E $PREFIX/bin/luarocks install lua-cjson
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi
$PREFIX/bin/luarocks install trepl         ||  sudo -E $PREFIX/bin/luarocks install trepl    
RET=$?; if [ $RET -ne 0 ]; then echo "Error. Exiting."; exit $RET; fi

# Done.
echo ""
echo "=> Torch7 has been installed successfully"
echo ""
echo "  + Extra packages have been installed as well:"
echo "     $ luarocks list"
echo ""
echo "  + To install more packages, do:"
echo "     $ luarocks search --all"
echo "     $ luarocks install PKG_NAME"
echo ""
echo "  + Note: on MacOS, it's a good idea to install GCC 5 to enable OpenMP."
echo "     You can do this by with brew"
echo "      $ brew install gcc --without-multilib"
echo "     type the following lines before running the installation script"
echo "      export CC=gcc-5"
echo "      export CXX=g++-5"
echo "     For installing cunn, you will need instead the default AppleClang compiler,"
echo "     which means you should open a new terminal (with unexported CC and CXX) and"
echo "      luarocks install cunn"
echo ""
echo "  + packages installed:"
echo "    - sundown   : " $sundown
echo "    - cwrap     : " $cwrap
echo "    - paths     : " $paths
echo "    - torch     : " $torch
echo "    - nn        : " $nn
echo "    - dok       : " $dok
echo "    - gnuplot   : " $gnuplot
[ -n "$cutorch" ] && echo "    - cutorch   : " $cutorch
[ -n "$cunn" ]    && echo "    - cunn      : " $cunn
echo "    - qtlua     : " $qtlua
echo "    - qttorch   : " $qttorch
echo "    - lfs       : " $lfs
echo "    - penlight  : " $penlight
echo "    - sys       : " $sys
echo "    - xlua      : " $xlua
echo "    - image     : " $image
echo "    - optim     : " $optim
echo "    - cjson     : " $cjson
echo "    - trepl     : " $trepl
echo ""

}
