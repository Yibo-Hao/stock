plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    signingConfigs {
        create("release") {
            storeFile = file("zjlp.jks")
            storePassword = "zjlp2025"
            keyAlias = "upload"
            keyPassword = "zjlp2025"
        }
    }
    namespace = "com.stock.zhijin_compass"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stock.zhijin_compass"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // manifestPlaceholders += mapOf(
        //     "JPUSH_PKGNAME" to "com.stock.zhijin_compass",
        //     "JPUSH_APPKEY" to "802fb04d2fc2d3e768b71c7c", // NOTE: JPush 上注册的包名对应的 Appkey.
        //     "JPUSH_CHANNEL" to "developer-default" //暂时填写默认值即可.
        // )
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
