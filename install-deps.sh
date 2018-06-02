#!/bin/bash
brew install make
brew install wget

#GCC dependencies
brew install gmp
brew install mpfr
brew install libmpc

#Grub dependencies
brew install autoconf
brew install automake

#Because of problems with Darwins gcc/g++, let's use GNU gcc to build gcc
brew install gcc
export CXX=/usr/local/bin/g++-8
export CC=/usr/local/bin/gcc-8

#A neat virtual machine
brew install qemu

#Install the rest we build to our own directory
export PREFIX=$HOME/opt/local

#Build binutils and gcc from sources
mkdir -p $PREFIX/src
cd $PREFIX/src
wget ftp://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.gz
wget ftp://ftp.gnu.org/gnu/gcc/gcc-8.1.0/gcc-8.1.0.tar.gz
tar -zxf binutils-2.30.tar.gz
tar -zxf gcc-8.1.0.tar.gz
rm binutils-2.30.tar.gz gcc-8.1.0.tar.gz

mkdir -p $PREFIX/bin

mkdir build-binutils
cd build-binutils
../binutils-2.30/configure --prefix=$PREFIX --target=i686-elf --enable-multilib --disable-nls --disable-werror
gmake
gmake install

export PATH="$PREFIX/bin:$PATH"
cd $PREFIX/src/
mkdir build-gcc
cd build-gcc
../gcc-8.1.0/configure --prefix=$PREFIX --target=i686-elf --enable-multilib --disable-nls --disable-werror --without-headers --enable-languages=c,c++
gmake all-gcc install-gcc
gmake all-target-libgcc install-target-libgcc

##Dependency to grub
cd $PREFIX/src/
wget http://www.agner.org/optimize/objconv.zip
mkdir objconv
cd objconv
unzip ../objconv.zip
unzip sources.zip
bash build.sh
cp objconv $PREFIX/bin/

#Build grub from sources
cd $PREFIX/src/
git clone git://git.savannah.gnu.org/grub.git
cd grub
./autogen.sh --prefix=$PREFIX
cd $PREFIX/src/
mkdir build-grub
cd build-grub
../grub/configure --disable-werror TARGET_CC=i686-elf-gcc TARGET_OBJCOPY=i686-elf-objcopy TARGET_STRIP=i686-elf-strip TARGET_NM=i686-elf-nm TARGET_RANLIB=i686-elf-ranlib --target=i686-elf  --prefix=$PREFIX
make
make install

#Dependency to grub-mkresque
cd $PREFIX/src/
wget https://www.gnu.org/software/xorriso/xorriso-1.4.8.tar.gz
tar -zxf xorriso-1.4.8.tar.gz
rm xorriso-1.4.8.tar.gz
cd xorriso-1.4.8
./configure --prefix=$PREFIX
make
make install