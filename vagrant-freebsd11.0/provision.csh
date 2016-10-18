#!/bin/csh

setenv PREFIX /home/vagrant/riscv

pkg install -y bison gmp mpfr mpc git subversion texinfo gmake gawk gsed

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

svn co http://svn.freebsd.org/base/head freebsd-riscv
cd freebsd-riscv

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

git clone https://github.com/freebsd-riscv/riscv-pk
cd riscv-pk
mkdir build && cd build
setenv PREFIX $HOME/riscv
setenv MYOBJDIR "/home/vagrant/obj/riscv/"
setenv CFLAGS "-msoft-float --sysroot=${MYOBJDIR}/tmp"
setenv CXX "c++"
setenv CPP "cpp"
setenv LDFLAGS "-L. -L${MYOBJDIR}/tmp/usr/lib/"
setenv PATH "${PATH}:${PREFIX}/bin"
../configure --prefix=$PREFIX --host=riscv64-unknown-freebsd11.0 --with-payload=path_to_freebsd_kernel
gmake
#Note: unset these ENV variables to proceed to next steps
