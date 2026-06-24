#!/bin/sh

set -ex

mkdir app
mkdir app/arm64-v8a
mkdir app/armeabi-v7a
mkdir app/x86
mkdir app/x86_64

AJARDIR=$ANDROID_SDK_ROOT/platforms/android-36-ext19
BASEDIR=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
RES_DIR=$BASEDIR/lib/clang/18
SYSROOT=$BASEDIR/sysroot
TOOLDIR=$ANDROID_SDK_ROOT/build-tools/37.0.0

FLAGS="-shared main.c -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -llog -resource-dir $RES_DIR --sysroot $SYSROOT"

$BASEDIR/bin/aarch64-linux-android32-clang    $FLAGS -o app/arm64-v8a/libhello.so   --target=arm64-v8a-linux-android32
$BASEDIR/bin/armv7a-linux-androideabi32-clang $FLAGS -o app/armeabi-v7a/libhello.so --target=armv7a-linux-androideabi32
$BASEDIR/bin/i686-linux-android32-clang       $FLAGS -o app/x86/libhello.so         --target=i686-linux-android32
$BASEDIR/bin/x86_64-linux-android32-clang     $FLAGS -o app/x86_64/libhello.so      --target=x86_64-linux-android32

$TOOLDIR/aapt2 compile res/values/strings.xml -o .
$TOOLDIR/aapt2 link values_strings.arsc.flat -o app.res.apk --manifest AndroidManifest.xml -I $AJARDIR/android.jar

cd app
unzip -v ../app.res.apk
zip -v -r ../app.unaligned.apk .
cd -

$TOOLDIR/zipalign -p -f -v 4 app.unaligned.apk app.apk

file app.apk
unzip -t app.apk
