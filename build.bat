mkdir app
mkdir app\arm64-v8a
mkdir app\armeabi-v7a
mkdir app\x86
mkdir app\x86_64

set AJARDIR=%ANDROID_SDK_ROOT%\platforms\android-36-ext19
set BASEDIR=%ANDROID_NDK%\toolchains\llvm\prebuilt\windows-x86_64
set RES_DIR=%BASEDIR%\lib\clang\18
set SYSROOT=%BASEDIR%\sysroot
set TOOLDIR=%ANDROID_SDK_ROOT%\build-tools\37.0.0

set FLAGS=-shared main.c -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -llog -resource-dir %RES_DIR% --sysroot %SYSROOT%

cmd /c %BASEDIR%\bin\aarch64-linux-android32-clang    %FLAGS% -o app\arm64-v8a\libhello.so   --target=arm64-v8a-linux-android32
cmd /c %BASEDIR%\bin\armv7a-linux-androideabi32-clang %FLAGS% -o app\armeabi-v7a\libhello.so --target=armv7a-linux-androideabi32
cmd /c %BASEDIR%\bin\i686-linux-android32-clang       %FLAGS% -o app\x86\libhello.so         --target=i686-linux-android32
cmd /c %BASEDIR%\bin\x86_64-linux-android32-clang     %FLAGS% -o app\x86_64\libhello.so      --target=x86_64-linux-android32

%TOOLDIR%\aapt2 compile res\values\strings.xml -o .
%TOOLDIR%\aapt2 link values_strings.arsc.flat -o app.res.apk --manifest AndroidManifest.xml -I %AJARDIR%\android.jar

cd app
tar -xf ..\app.res.apk
tar -cf ..\app.unaligned.apk --format zip *
cd ..

%TOOLDIR%\zipalign -p -f -v 4 app.unaligned.apk app.apk

rem Obviously you should use real passwords, dnames, etc
keytool -genkeypair -keystore keystore.jks -alias androidkey -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android -dname CN=CA
cmd /c %TOOLDIR%\apksigner sign --in app.apk -ks keystore.jks --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android

tar -tf app.apk

