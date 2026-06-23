#!/bin/sh

set -ex

mkdir app
mkdir app/arm64-v8a
mkdir app/armeabi-v7a
mkdir app/x86
mkdir app/x86_64

SYSROOT=$ANDROID_NDK/toolchains/llvm/prebuilt/*/sysroot
RES_DIR=$ANDROID_NDK/toolchains/llvm/prebuilt/*/lib/clang/*

clang -shared -o app/arm64-v8a/libhello.so main.c \
  -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -stdlib=libc \
  -resource-dir $RES_DIR --sysroot $SYSROOT --target=arm64-v8a-linux-android32

