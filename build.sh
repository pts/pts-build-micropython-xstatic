#! /bin/bash
# by pts@fazekas.hu at Mon Feb 22 22:02:20 CET 2016

set -ex
rm -rf micropython micropython.upx micropython.src 
git clone --depth 1 https://github.com/micropython/micropython micropython.src
# We need this patch because `xstatic gcc -E -' doesn't find #include files if - is specified.
(cd micropython.src && patch -p0 <<'END') || exit "$1"
--- py/py.mk.orig	2016-02-22 22:04:47.000000000 +0100
+++ py/py.mk	2016-02-22 22:14:25.746064251 +0100
@@ -191,21 +191,21 @@
 MPCONFIGPORT_MK = $(wildcard mpconfigport.mk)
 
 # qstr data
 
 # Adding an order only dependency on $(HEADER_BUILD) causes $(HEADER_BUILD) to get
 # created before we run the script to generate the .h
 # Note: we need to protect the qstr names from the preprocessor, so we wrap
 # the lines in "" and then unwrap after the preprocessor is finished.
 $(HEADER_BUILD)/qstrdefs.generated.h: $(PY_QSTR_DEFS) $(QSTR_DEFS) $(PY_SRC)/makeqstrdata.py mpconfigport.h $(MPCONFIGPORT_MK) $(PY_SRC)/mpconfig.h | $(HEADER_BUILD)
 	$(ECHO) "GEN $@"
-	$(Q)cat $(PY_QSTR_DEFS) $(QSTR_DEFS) | $(SED) 's/^Q(.*)/"&"/' | $(CPP) $(CFLAGS) - | sed 's/^"\(Q(.*)\)"/\1/' > $(HEADER_BUILD)/qstrdefs.preprocessed.h
+	$(Q)cat $(PY_QSTR_DEFS) $(QSTR_DEFS) | $(SED) 's/^Q(.*)/"&"/' >$(HEADER_BUILD)/qstrdefs.in.h && $(CPP) $(CFLAGS) $(HEADER_BUILD)/qstrdefs.in.h | sed 's/^"\(Q(.*)\)"/\1/' > $(HEADER_BUILD)/qstrdefs.preprocessed.h
 	$(Q)$(PYTHON) $(PY_SRC)/makeqstrdata.py $(HEADER_BUILD)/qstrdefs.preprocessed.h > $@
 
 # emitters
 
 $(PY_BUILD)/emitnx64.o: CFLAGS += -DN_X64
 $(PY_BUILD)/emitnx64.o: py/emitnative.c
 	$(call compile_c)
 
 $(PY_BUILD)/emitnx86.o: CFLAGS += -DN_X86
 $(PY_BUILD)/emitnx86.o: py/emitnative.c

END
# -Wno-strict-aliasing is needed by gcc-4.4.
(cd micropython.src/unix && make MICROPY_FORCE_32BIT=1 MICROPY_PY_FFI=0 CROSS_COMPILE='xstatic ' STRIP=strip SIZE=size CWARN="-Wall -Werror -Wpointer-arith -Wuninitialized -Wno-strict-aliasing") || exit "$1"
mv micropython.src/unix/micropython micropython
sstrip.static micropython
cp -a micropython micropython.upx
upx.pts --brute micropython.upx
rm -rf micropython.src
# With gcc-4.8:
#   -rwxr-x--- 1 pts pts 393844 Feb 22 22:16 micropython
#   -rwxr-x--- 1 pts pts 171992 Feb 22 22:16 micropython.upx
# With gcc-4.4:
#   -rwxr-xr-x 1 pts pts 344788 Feb 22 22:24 micropython
#   -rwxr-xr-x 1 pts pts 161568 Feb 22 22:24 micropython.upx
ls -l micropython micropython.upx
: build.sh OK
