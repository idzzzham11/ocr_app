# ML Kit text recognition keep rules
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.mlkit.common.model.** { *; }

# Keep script-specific recognizers (even if unused directly)
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# AndroidX Window & Sidecar API keep rules (required by newer Android foldable devices)
-keep class androidx.window.** { *; }
-dontwarn androidx.window.**

# Flutter method channel and plugin communication
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Optional: keep all Flutter plugin-related classes
-keep class io.flutter.plugins.** { *; }

# Silence obsolete Java warning
-dontwarn java.lang.module.*
