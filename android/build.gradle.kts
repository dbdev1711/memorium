buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Aquesta línia és vital per a la compatibilitat amb el SDK 36
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath(kotlin("gradle-plugin", version = "1.9.22"))
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = layout.buildDirectory.asFile.get()

subprojects {
    project.buildDir = layout.buildDirectory.asFile.get().resolve(project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
