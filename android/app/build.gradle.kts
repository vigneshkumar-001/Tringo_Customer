import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.feni.tringo.tringo_app"
    compileSdk = 36
    // Keep this in sync with the Flutter toolchain (and use an r28+ NDK for 16 KB page-size support).
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.feni.tringo.tringo_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Ensure we ship/load native libraries in the modern, non-legacy way.
    // (AGP 8.5.1+ handles 16 KB zip alignment for uncompressed shared libs.)
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("com.google.android.material:material:1.12.0")
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("io.coil-kt:coil:2.6.0")
}

flutter {
    source = "../.."
}


