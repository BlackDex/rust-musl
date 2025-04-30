GNU_SITE = https://ftp.gnu.org/gnu
#
BINUTILS_VER = 2.33.1
GCC_VER = 14.2.0
GMP_VER = 6.1.2
ISL_VER = 0.21
LINUX_VER = 5.8.5
MPC_VER = 1.1.0
MPFR_VER = 4.0.2
MUSL_VER = 1.2.5
#
DL_CMD = curl -w"%{stderr}URL: %{url_effective}\\nTime: %{time_total}\\nSize: %{size_download}\\n" --retry 5 --retry-all-errors -sSfL -C - -o
#
FLAG = -g0 -Os
FLAG += -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels
FLAG += -ffunction-sections -fdata-sections -Wno-error -Wl,-gc-sections -s
#
COMMON_CONFIG += CFLAGS="${FLAG}" CXXFLAGS="${FLAG}" LDFLAGS="-s"
#
COMMON_CONFIG += --disable-nls
COMMON_CONFIG += --enable-relro
COMMON_CONFIG += --disable-rpath
COMMON_CONFIG += --disable-multilib
COMMON_CONFIG += --enable-initfini-array
COMMON_CONFIG += --disable-linker-build-id
COMMON_CONFIG += --enable-host-pie
COMMON_CONFIG += --with-debug-prefix-map=$(CURDIR)=
#
COMMON_CONFIG += ${ARCH_COMMON_CONFIG}
#
GCC_CONFIG += --enable-languages=c,c++
GCC_CONFIG += --enable-link-serialization=1
GCC_CONFIG += --enable-clocale=generic
GCC_CONFIG += --enable-default-ssp
GCC_CONFIG += --enable-tls
GCC_CONFIG += --disable-libsanitizer
GCC_CONFIG += --disable-cet
GCC_CONFIG += --disable-symvers
GCC_CONFIG += --disable-gnu-unique-object
GCC_CONFIG += --enable-default-pie --enable-static-pie
#
BINUTILS_CONFIG += --enable-new-dtags
BINUTILS_CONFIG += --disable-default-execstack
BINUTILS_CONFIG += --enable-deterministic-archives
#
OUTPUT = /usr/local/musl
