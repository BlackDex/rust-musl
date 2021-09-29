# Shared config between 64bit and 32bit
GCC_VER = 10.3.0
#
DL_CMD = curl -w"%{stderr}URL: %{url_effective}\\nTime: %{time_total}\\nSize: %{size_download}\\n" --retry 3 -sSfL -C - -o
#
FLAG = -g0 -Os -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error
COMMON_CONFIG += CFLAGS="${FLAG}" CXXFLAGS="${FLAG}" LDFLAGS="-s"
#
COMMON_CONFIG += --disable-nls
COMMON_CONFIG += --with-debug-prefix-map=$(CURDIR)=
#
GCC_CONFIG += --enable-languages=c,c++
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-multilib
GCC_CONFIG += --enable-default-pie --enable-static-pie
#
COMMON_CONFIG += ${ARCH_COMMON_CONFIG}
