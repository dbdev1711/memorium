# Protegir les classes de Google Play Services / AdMob
-keep public class com.google.android.gms.ads.** { *; }
-keep public class com.google.ads.** { *; }

# Evitar que es bordin atributs necessaris per a la reflexió
-keepattributes *Annotation*, Signature, EnclosingMethod
