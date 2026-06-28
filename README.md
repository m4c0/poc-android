# poc-android

Building an Android APK without Android Studio, Gradle or CMake

This is an interesting repository to explore if you want to understand how it
all works under the hood. Or if you want to add Android support to your custom
build tool.

Everything you need to know is in the `build.sh` file.

If you want the text version, keep reading.

Android APKs are just ZIP files. If you messed around Java and its JAR files,
then this should not be a surprise.

The act of "signing" an APK (required to publish via stores) is, again, very
similar to Java: given a keystore created by Java's `keytool`, you can use
Android's `apksigner` on an unsigned APK, which will get a files added in a
subfolder named `META-INF` in said APK.

For performance reasons, you should align entries in that ZIP/APK using
Android's `zipalign`. This should happen before signing.

The easiest way to create one of those ZIP/APKs is with Android's `aapt2`. That
tool can be used to compile resources and create unsigned/unaligned APKs.

The manifest you pass to `aapt2` describes the app - including UIs if you are
into that. For an NDK-only app, you can use android's NativeActivity and wire
to its JNIs (like `ANativeActivity_onCreate` in the `main.c` file). Then you
include the `android.jar` provided with the SDK.

The C code is trivial. It requires a compiled versioon for each of Android's
supported architectures, with its `.so` stored in specific paths.

These dynamic libraries should be added to the APK before aligning/signing. The
easiest way I know is unzipping the APK created by `aapt2` then re-zipping with
those libraries included. Then align/sign and done.

## Future ideas

* Download what's needed instead of using SDK's classical paths. [This
  page][1] seems to contains hotlinks to what we need

[1]: https://androidsdkmanager.azurewebsites.net/tools

