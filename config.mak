BINUTILS_VER = 2.33.1
GCC_VER = 11.2.0
GMP_VER = 6.1.2
ISL_VER = 0.21
LINUX_VER = 5.8.5
MPC_VER = 1.1.0
MPFR_VER = 4.0.2
MUSL_VER = 1.2.5
#
DL_CMD = curl -w"%{stderr}URL: %{url_effective}\\nTime: %{time_total}\\nSize: %{size_download}\\n" --retry 3 -sSfL -C - -o
#
FLAG = -g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error
COMMON_CONFIG += CFLAGS="${FLAG}" CXXFLAGS="${FLAG}" LDFLAGS="-s"
#
COMMON_CONFIG += --disable-nls
COMMON_CONFIG += --with-debug-prefix-map=$(CURDIR)=
#
COMMON_CONFIG += ${ARCH_COMMON_CONFIG}
#
GCC_CONFIG += --enable-languages=c,c++
GCC_CONFIG += --disable-multilib
GCC_CONFIG += --enable-default-pie --enable-static-pie
GCC_CONFIG += --enable-initfini-array
#
BINUTILS_CONFIG += --disable-multilib
#
OUTPUT = /usr/local/musl
