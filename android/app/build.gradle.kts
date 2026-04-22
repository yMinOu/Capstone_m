import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.example.nihongo"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.nihongo"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("dev") {
            storeFile = file(keystoreProperties["devStoreFile"] as String)
            storePassword = keystoreProperties["devStorePassword"] as String
            keyAlias = keystoreProperties["devKeyAlias"] as String
            keyPassword = keystoreProperties["devKeyPassword"] as String
        }

        create("prod") {
            storeFile = file(keystoreProperties["prodStoreFile"] as String)
            storePassword = keystoreProperties["prodStorePassword"] as String
            keyAlias = keystoreProperties["prodKeyAlias"] as String
            keyPassword = keystoreProperties["prodKeyPassword"] as String
        }
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            signingConfig = signingConfigs.getByName("dev")
        }

        create("prod") {
            dimension = "env"
            signingConfig = signingConfigs.getByName("prod")
        }
    }

    buildTypes {
        debug {
            signingConfig = null
        }

        release {
            signingConfig = null
        }
    }
}

flutter {
    source = "../.."
}