#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=$PREFIX/lib
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include"
CFLAGS=$EXTRACFLAGS
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=$DESTARCH-linux"
MAKE="make -j`nproc`"

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################

cd $SRC/bzip2

if [ ! -f .extracted ]; then
	rm -rf bzip2-1.0.6
	tar zxvf bzip2-1.0.6.tar.gz
	touch .extracted
fi

cd bzip2-1.0.6

if [ ! -f .patched ]; then
	patch < $PATCHES/bzip2/bzip2.patch
	patch < $PATCHES/bzip2/bzip2_so.patch
	touch .patched
fi

if [ ! -f .built ]; then
	$MAKE
	$MAKE -f Makefile-libbz2_so
	touch .built
fi

if [ ! -f .installed ]; then
	make install PREFIX=$DEST
	touch .installed
fi


######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

cd $SRC/zlib

if [ ! -f .extracted ]; then
	rm -rf zlib-1.2.8
	tar zxvf zlib-1.2.8.tar.gz
	touch .extracted
fi

cd zlib-1.2.8

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CROSS_PREFIX=$DESTARCH-linux- \
	./configure \
	--prefix=$PREFIX
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

cd $SRC/openssl

if [ ! -f .extracted ]; then
	rm -rf openssl-1.0.2f
	tar zxvf openssl-1.0.2f.tar.gz
	touch .extracted
fi

cd openssl-1.0.2f

if [ "$DESTARCH" == "mipsel" ];then
	os=linux-mips32
fi

if [ "$DESTARCH" == "arm" ];then
	os="linux-armv4 -march=armv7-a -mtune=cortex-a9"
fi

if [ ! -f .configured ]; then
	./Configure $os \
	-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 \
	-Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
	--prefix=$PREFIX shared zlib \
	--with-zlib-lib=$DEST/lib \
	--with-zlib-include=$DEST/include
	touch .configured
fi

if [ ! -f .built ]; then
	make CC=$DESTARCH-linux-gcc
	touch .built
fi

if [ ! -f .installed ]; then
	make install CC=$DESTARCH-linux-gcc INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl
	touch .installed
fi

############ ################################################################
# LIBICONV # ################################################################
############ ################################################################

cd $SRC/libiconv

if [ ! -f .extracted ]; then
	rm -rf libiconv-1.14
	tar zxvf libiconv-1.14.tar.gz
	touch .extracted
fi

cd libiconv-1.14

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-static
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# GETTEXT # #################################################################
########### #################################################################

cd $SRC/gettext

if [ ! -f .extracted ]; then
	rm -rf gettext-0.19.7
	tar zxvf gettext-0.19.7.tar.gz
	touch .extracted
fi

cd gettext-0.19.7

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/gettext/spawn.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS="$LDFLAGS -lrt -lpthread" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .edit_sed ]; then
        sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
        $DEST/lib/libintl.la
        touch .edit_sed
fi

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################

cd $SRC/expat

if [ ! -f .extracted ]; then
	rm -rf cd expat-2.1.0
	tar zxvf expat-2.1.0.tar.gz
	touch .extracted
fi

cd expat-2.1.0

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS  \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################

cd $SRC/libffi

if [ ! -f .extracted ]; then
	rm -rf libffi-3.2.1
	tar zxvf libffi-3.2.1.tar.gz
	touch .extracted
fi

cd libffi-3.2.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# NCURSES # #################################################################
########### #################################################################

cd $SRC/ncurses

if [ ! -f .extracted ]; then
	rm -rf ncurses-6.0
	tar zxvf ncurses-6.0.tar.gz
	touch .extracted
fi

cd ncurses-6.0

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-P $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-widec \
	--enable-overwrite \
	--with-normal \
	--with-shared \
	--enable-rpath \
	--with-fallbacks=xterm
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .linked ]; then
	ln -sf libncursesw.a $DEST/lib/libncurses.a
	ln -sf libncursesw.so $DEST/lib/libncurses.so
	ln -sf libncursesw.so.6 $DEST/lib/libncurses.so.6
	ln -sf libncursesw.so.6.0 $DEST/lib/libncurses.so.6.0
	ln -sf libncurses++w.a $DEST/lib/libncurses++.a
	ln -sf libncursesw_g.a $DEST/lib/libncurses_g.a
	ln -sf libncursesw.a $DEST/lib/libcurses.a
	ln -sf libncursesw.so $DEST/lib/libcurses.so
	ln -sf libcurses.so $DEST/lib/libtinfo.so
	touch .linked
fi

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

cd $SRC/libreadline

if [ ! -f .extracted ]; then
	rm -rf readline-6.3
	tar zxvf readline-6.3.tar.gz
	touch .extracted
fi

cd readline-6.3

if [ ! -f .patched ]; then
	patch < $PATCHES/readline/readline.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################

cd $SRC/libgdbm

if [ ! -f .extracted ]; then
	rm -rf gdbm-1.11
	tar zxvf gdbm-1.11.tar.gz
	touch .extracted
fi

cd gdbm-1.11

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# tcl # #####################################################################
####### #####################################################################

cd $SRC/tcl

if [ ! -f .extracted ]; then
	rm -rf cd tcl8.6.4/unix
	tar zxvf tcl8.6.4-src.tar.gz
	touch .extracted
fi

cd tcl8.6.4/unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-threads \
	--enable-shared \
	--enable-symbols \
	ac_cv_func_strtod=yes \
	tcl_cv_strtod_buggy=1
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# bdb # #####################################################################
####### #####################################################################

cd $SRC/bdb

if [ ! -f .extracted ]; then
	rm -rf db-4.7.25
	tar zxvf db-4.7.25.tar.gz
	touch .extracted
fi

cd  db-4.7.25/build_unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../dist/$CONFIGURE \
	--enable-cxx \
	--enable-tcl \
	--enable-compat185 \
	--with-tcl=$DEST/lib
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################

cd $SRC/sqlite

if [ ! -f .extracted ]; then
	rm -rf sqlite-autoconf-3100200
	tar zxvf sqlite-autoconf-3100200.tar.gz
	touch .extracted
fi

cd sqlite-autoconf-3100200

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	make
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# CMAKE # ###################################################################
######### ###################################################################

cd $SRC/cmake

if [ ! -f .extracted ]; then
	rm -rf cmake-3.4.3
	tar zxvf cmake-3.4.3.tar.gz
	touch .extracted
fi

cd cmake-3.4.3

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/cmake/cmake.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_SYSTEM_PREFIX_PATH=$DEST \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CPPFLAGS $CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CPPFLAGS $CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	-DCMAKE_USE_SYSTEM_LIBRARY_ZLIB=TRUE \
	-DCMAKE_USE_SYSTEM_LIBRARY_BZIP2=TRUE \
	-DCMAKE_USE_SYSTEM_LIBRARY_EXPAT=TRUE \
	./
	touch .configured
fi

if [ ! -f .edit_sed ]; then
	sed -i '/cmake_install/s/bin\/cmake/\/usr\/bin\/cmake/g' Makefile
	touch .edit_sed
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################

cd $SRC/python

if [ ! -f .extracted ]; then
	rm -rf Python-2.7.11 python-cmake-buildsystem python-build
	tar zxvf Python-2.7.11.tgz
	tar zxvf python-cmake-buildsystem.tgz
	mkdir python-build
	touch .extracted
fi

cd python-build

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_SYSTEM_PREFIX_PATH=$DEST \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CPPFLAGS $CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CPPFLAGS $CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	-DDOWNLOAD_SOURCES=OFF \
	-DBUILD_SHARED=ON \
	-DBUILD_STATIC=ON \
	../python-cmake-buildsystem
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi
