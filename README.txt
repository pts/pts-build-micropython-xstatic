pts-build-micropython-xstatic: micropython for Linux i386, statically linked

pts-build-micropython-xstatic is a set of tools for compiling the
micropython binary for Linux i386, statically linked.

Dependencies:

* Linux i386 or Linux x86_64 system
* gcc, tested with gcc-4.4 and gcc-4.8
* strip, size (from GNU Binutils)
* pts-xstatic
* (optional) UPX, installed as upx.pts

How to compile:

1. Install the dependencies.
2. Download pts-build-micropython-xstatic.
3. Run: ./build.sh
4. The results are the micropython and micropython.upx binaries.
