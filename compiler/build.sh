apt-get install -y \
	curl nasm build-essential bison flex libgmp3-dev \
	libmpc-dev libmpfr-dev texinfo

mkdir -p src && cd src

echo Downloading binutils-2.30...

curl -s https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.gz \
	--output binutils-2.30.tar.gz

echo binutils-2.30 downloaded
echo unarchive binutils-2.30

tar -xf binutils-2.30.tar.gz

echo Downloading gcc-8.1.0...

curl -s https://ftp.gnu.org/gnu/gcc/gcc-8.1.0/gcc-8.1.0.tar.gz \
	--output gcc-8.1.0.tar.gz

echo gcc-8.1.0 downloaded
echo unarchive gcc-8.1.0

tar -xf gcc-8.1.0.tar.gz

export PREFIX="/usr/local/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

echo Building binutils

mkdir build-binutils
cd build-binutils
../binutils-2.30/configure --target=$TARGET --prefix="$PREFIX" \
	--with-sysroot --disable-nls --disable-werror
make
make install

which -- $TARGET-as || echo $TARGET-as is not in the PATH

cd ..

mkdir build-gcc
cd build-gcc
../gcc-8.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls \
	--enable-languages=c --without-headers

make -j$((`nproc`+1)) all-gcc
make -j$((`nproc`+1)) all-target-libgcc
make install-gcc
make install-target-libgcc

$TARGET-gcc --version

