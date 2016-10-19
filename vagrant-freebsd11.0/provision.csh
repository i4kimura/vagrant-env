#!/bin/csh

setenv PREFIX /home/vagrant/riscv

sudo pkg install -y bison gmp mpfr mpc git subversion texinfo gmake gawk gsed

###################
# Build Toolchain #
###################

git clone https://github.com/freebsd-riscv/riscv-gnu-toolchain riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive
./configure --prefix=$PREFIX
gmake freebsd

#################
# Build FreeBSD #
#################

cd /home/vagrant/
svn co http://svn.freebsd.org/base/head freebsd-riscv
cd freebsd-riscv

setenv WITHOUT_SHAREDOCS yes
setenv MAKEOBJDIRPREFIX /home/vagrant/obj/
setenv CROSS_BINUTILS_PREFIX $PREFIX/bin/riscv64-unknown-freebsd11.0-
setenv STRIPBIN ${CROSS_BINUTILS_PREFIX}strip
setenv XCC ${CROSS_BINUTILS_PREFIX}gcc
setenv XCXX ${CROSS_BINUTILS_PREFIX}c++
setenv XCPP ${CROSS_BINUTILS_PREFIX}cpp

setenv X_COMPILER_TYPE gcc
setenv WITHOUT_FORMAT_EXTENSIONS yes
setenv WITHOUT_NTP yes

make TARGET_ARCH=riscv64 buildworld
make TARGET_ARCH=riscv64 KERNCONF=SPIKE buildkernel # for Spike
# make TARGET_ARCH=riscv64 KERNCONF=QEMU buildkernel # for QEMU

###########################
# Build 32mb rootfs image #
###########################

setenv DESTDIR /home/vagrant/riscv-world
make TARGET_ARCH=riscv64 -DNO_ROOT -DWITHOUT_TESTS DESTDIR=$DESTDIR installworld
make TARGET_ARCH=riscv64 -DNO_ROOT -DWITHOUT_TESTS DESTDIR=$DESTDIR distribution
fetch https://raw.githubusercontent.com/bukinr/riscv-tools/master/image/basic.files
tools/tools/makeroot/makeroot.sh -s 32m -f basic.files riscv.img $DESTDIR


#############
# Build bbl #
#############

cd /home/vagrant/
git clone https://github.com/freebsd-riscv/riscv-pk
cd riscv-pk
mkdir build && cd build
setenv PREFIX $HOME/riscv
setenv MYOBJDIR "/home/vagrant/obj/riscv.riscv64/home/vagrant/freebsd-riscv/"
setenv CFLAGS "-msoft-float --sysroot=${MYOBJDIR}/tmp"
setenv CXX "c++"
setenv CPP "cpp"
setenv LDFLAGS "-L. -L${MYOBJDIR}/tmp/usr/lib/"
setenv PATH "${PATH}:${PREFIX}/bin"
../configure --prefix=$PREFIX --host=riscv64-unknown-freebsd11.0 --with-payload=/home/vagrant/riscv-world
gmake
#Note: unset these ENV variables to proceed to next steps

#########################
# Build Spike simulator #
#########################
unset PREFIX
unset MYOBJDIR
unset CFLAGS
unset CXX
unset CPP
unset LDFLAGS

cd /home/vagrant
# Use clang on FreeBSD
setenv CXX c++
setenv PREFIX $HOME/riscv
git clone https://github.com/freebsd-riscv/riscv-fesvr
cd riscv-fesvr
mkdir build && cd build
../configure --prefix=$PREFIX
gmake install
git clone https://github.com/freebsd-riscv/riscv-isa-sim
cd riscv-isa-sim
mkdir build && cd build
setenv CFLAGS "-x c++-header"  ## trying to insert
../configure --prefix=$PREFIX --with-fesvr=$PREFIX
gmake install
#TODO: failed to compile, stick "-x c++-header" in the problematic command line
