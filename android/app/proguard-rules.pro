# Flutter related rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep Parcelable implementations (needed for some plugins)
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep all classes annotated with @Keep
-keep @androidx.annotation.Keep class * { *; }

# Optional: Keep Firebase / Google Play Services classes if you use them
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
