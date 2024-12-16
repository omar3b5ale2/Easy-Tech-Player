
# Preserve Flutter's main entry point
#-keep class io.flutter.** { *; }
#-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.embedding.**

# Keep lifecycle-related classes
-keep public class androidx.lifecycle.** { *; }

# Retain custom model classes
-keepclassmembers class * {
    public <init>(...);
}

# Rules for Firebase (if used)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Rules for Retrofit or Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Avoid warnings for common libraries
-dontwarn org.jetbrains.**
-dontwarn androidx.lifecycle.**
-dontwarn kotlinx.**
-dontwarn javax.annotation.**
#-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
