import java.util.Properties

// 1. Llegir el fitxer key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "db.memorium.memorium"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // 2. Configurar la signatura
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "db.memorium.memorium"
        // Forcem minSdk a 21 per evitar el VerifyError en dispositius antics amb AdMob
        minSdk = 21 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Activem MultiDex per gestionar aplicacions amb moltes llibreries (com AdMob)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // Optimització i protecció de codi
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Apliquem el fitxer proguard-rules.pro que has creat
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), 
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Afegim la dependència de MultiDex per a suport en versions antigues d'Android
    implementation("androidx.multidex:multidex:2.0.1")
}
