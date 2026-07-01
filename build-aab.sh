#!/bin/sh

set -ex

mkdir app
mkdir app/lib
mkdir app/lib/arm64-v8a
mkdir app/lib/armeabi-v7a
mkdir app/lib/x86
mkdir app/lib/x86_64
mkdir app/manifest

AJARDIR=$ANDROID_SDK_ROOT/platforms/android-36-ext19
BASEDIR=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
RES_DIR=$BASEDIR/lib/clang/18
SYSROOT=$BASEDIR/sysroot
TOOLDIR=$ANDROID_SDK_ROOT/build-tools/37.0.0

FLAGS="-shared main.c -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -llog -resource-dir $RES_DIR --sysroot $SYSROOT"

$BASEDIR/bin/aarch64-linux-android32-clang    $FLAGS -o app/lib/arm64-v8a/libhello.so   --target=arm64-v8a-linux-android32
$BASEDIR/bin/armv7a-linux-androideabi32-clang $FLAGS -o app/lib/armeabi-v7a/libhello.so --target=armv7a-linux-androideabi32
$BASEDIR/bin/i686-linux-android32-clang       $FLAGS -o app/lib/x86/libhello.so         --target=i686-linux-android32
$BASEDIR/bin/x86_64-linux-android32-clang     $FLAGS -o app/lib/x86_64/libhello.so      --target=x86_64-linux-android32

$TOOLDIR/aapt2 compile res/values/strings.xml -o .
$TOOLDIR/aapt2 link --proto-format values_strings.arsc.flat -o res.zip --manifest AndroidManifest.xml -I $AJARDIR/android.jar

cd app
unzip ../res.zip
mv AndroidManifest.xml manifest/
zip -v -r ../base.zip *
cd ..

java -jar bundletool.jar build-bundle --modules=base.zip --output=app.aab

# Obviously you should use real passwords, dnames, etc
keytool -genkeypair -keystore keystore.jks -alias androidkey -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android -dname CN=CA
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore keystore.jks -storepass android -keypass android app.aab androidkey

jar tf app.aab
