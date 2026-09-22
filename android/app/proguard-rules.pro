# Flutter Wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Google Sign-In & Play Services
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter Secure Storage / Android Keystore
-keep class androidx.security.crypto.** { *; }

# Dio / OkHttp / Retrofit
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Gson / JSON serialization (if used by any library)
-keepattributes SourceFile,LineNumberTable
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Open FilEx — needed to open files from app-specific storage
-keep class com.crazecoder.openfile.** { *; }

# Share Plus — file sharing via Intent
-keep class dev.fluttercommunity.plus.share.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# FileProvider — required for sharing files on Android 7+
-keep class androidx.core.content.FileProvider { *; }

# Flutter Deferred Components & Play Core (not using dynamic delivery)
-dontwarn com.google.android.play.core.**
