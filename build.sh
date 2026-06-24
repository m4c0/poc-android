#!/bin/sh

set -ex

mkdir app
mkdir app/arm64-v8a
mkdir app/armeabi-v7a
mkdir app/x86
mkdir app/x86_64

BASEDIR=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
RES_DIR=$BASEDIR/lib/clang/18
SYSROOT=$BASEDIR/sysroot

FLAGS="-shared main.c -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -llog -resource-dir $RES_DIR --sysroot $SYSROOT"

$BASEDIR/bin/aarch64-linux-android32-clang    $FLAGS -o app/arm64-v8a/libhello.so   --target=arm64-v8a-linux-android32
$BASEDIR/bin/armv7a-linux-androideabi32-clang $FLAGS -o app/armeabi-v7a/libhello.so --target=armv7a-linux-androideabi32
$BASEDIR/bin/i686-linux-android32-clang       $FLAGS -o app/x86/libhello.so         --target=i686-linux-android32
$BASEDIR/bin/x86_64-linux-android32-clang     $FLAGS -o app/x86_64/libhello.so      --target=x86_64-linux-android32
