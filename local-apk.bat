rem Variant of "build.bat" but using a "hand crafted" SDK

rem 1. Create a folder and set an environment variable ANDROID_SDK_BASE to point at it

rem 2. Download these files:
rem https://dl.google.com/android/repository/android-ndk-r23-beta4-windows-x86_64.zip
rem https://dl.google.com/android/repository/build-tools_r33.0.3-windows.zip
rem https://dl.google.com/android/repository/platform-33-ext3_r03.zip

rem 3. Create these folders inside ANDROID_SDK_BASE: "platforms" and "build-tools"

rem 4. Extract "android-ndk" inside ANDROID_SDK_BASE (it should create a folder
rem    named "android-ndk-r23-beta4")

rem 5. Extract "build-tools" and "platform" inside their respective subfolders
rem    (each of those ZIP has a subdirectory named "android-13")

rem Your ANDROID_SDK_BASE should look like this:
rem BASE
rem   +-- android-ndk-r23-beta4
rem   |     +-- ...
rem   |     +-- toolchains
rem   |     +-- ...
rem   +-- build-tools
rem   |     +-- android-13
rem   |           +-- ...
rem   |           +-- aapt.exe
rem   |           +-- aapt2.exe
rem   |           +-- ...
rem   +-- platforms
rem         +-- android-13
rem               +-- ...
rem               +-- android.jar 
rem               +-- ...

mkdir app
mkdir app\arm64-v8a
mkdir app\armeabi-v7a
mkdir app\x86
mkdir app\x86_64

set AJARDIR=%ANDROID_SDK_BASE%\platforms\android-13
set BASEDIR=%ANDROID_SDK_BASE%\android-ndk-r23-beta4\toolchains\llvm\prebuilt\windows-x86_64
set RES_DIR=%BASEDIR%\lib64\clang\12.0.5
set SYSROOT=%BASEDIR%\sysroot
set TOOLDIR=%ANDROID_SDK_BASE%\build-tools\android-13

set FLAGS=-shared main.c -Wl,-Bsymbolic -fuse-ld=lld -Wl,--no-undefined -llog -resource-dir %RES_DIR% --sysroot %SYSROOT%

cmd /c %BASEDIR%\bin\aarch64-linux-android31-clang    %FLAGS% -o app\arm64-v8a\libhello.so   --target=arm64-v8a-linux-android31
cmd /c %BASEDIR%\bin\armv7a-linux-androideabi31-clang %FLAGS% -o app\armeabi-v7a\libhello.so --target=armv7a-linux-androideabi31
cmd /c %BASEDIR%\bin\i686-linux-android31-clang       %FLAGS% -o app\x86\libhello.so         --target=i686-linux-android31
cmd /c %BASEDIR%\bin\x86_64-linux-android31-clang     %FLAGS% -o app\x86_64\libhello.so      --target=x86_64-linux-android31

%TOOLDIR%\aapt2 compile res\values\strings.xml -o .
%TOOLDIR%\aapt2 link values_strings.arsc.flat -o app.res.apk --manifest AndroidManifest.xml -I %AJARDIR%\android.jar

cd app
tar -xf ..\app.res.apk
tar -cf ..\app.unaligned.apk --format zip *
cd ..

%TOOLDIR%\zipalign -p -f -v 4 app.unaligned.apk app.apk

rem -=-=-=- NOTE: Signing requires Java for reasons -=-=-=-

rem Obviously you should use real passwords, dnames, etc
keytool -genkeypair -keystore keystore.jks -alias androidkey -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android -dname CN=CA
cmd /c %TOOLDIR%\apksigner sign --in app.apk -ks keystore.jks --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android

tar -tf app.apk

