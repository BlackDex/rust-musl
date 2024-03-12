#!/bin/sh -e
# shellcheck disable=all

DEFAULT_XGCCARGS="--disable-nls --enable-default-pie --enable-static-pie --enable-default-ssp"

case $1 in
x86_64-unknown-linux-musl )
    ADDITIONAL=true
    XARCH=x86-64
    LARCH=x86_64
    MARCH=$LARCH
    XGCCARGS="--with-arch=$XARCH --with-tune=generic ${DEFAULT_XGCCARGS}"
    XPURE64=$XARCH
    XTARGET=x86_64-unknown-linux-musl
    ;;
aarch64-unknown-linux-musl )
    ADDITIONAL=true
    XARCH=aarch64
    LARCH=arm64
    MARCH=$XARCH
    XGCCARGS="--with-arch=armv8-a --with-abi=lp64 --enable-fix-cortex-a53-835769 --enable-fix-cortex-a53-843419 ${DEFAULT_XGCCARGS}"
    XPURE64=$XARCH
    XTARGET=aarch64-unknown-linux-musl
    ;;
armv7-unknown-linux-musleabihf )
    ADDITIONAL=true
    XARCH=armv7-a
    LARCH=arm
    MARCH=$LARCH
    XGCCARGS="--with-arch=$XARCH --with-float=hard --with-mode=thumb --with-fpu=vfp ${DEFAULT_XGCCARGS}"
    XPURE64=""
    XTARGET=armv7-unknown-linux-musleabihf
    ;;
arm-unknown-linux-musleabi )
    ADDITIONAL=true
    XARCH=armv6
    LARCH=arm
    MARCH=$LARCH
    XGCCARGS="--with-arch=$XARCH --with-float=soft --with-mode=arm ${DEFAULT_XGCCARGS}"
    XPURE64=""
    XTARGET=arm-unknown-linux-musleabi
    ;;
* )
    ADDITIONAL=false
    ;;
esac
