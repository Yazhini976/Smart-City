allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid = { proj: Project ->
        val android = proj.extensions.findByName("android")
        if (android != null) {
            try {
                val method = android::class.java.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(android, 36)
            } catch (e: Exception) {
                try {
                    val method = android::class.java.getMethod("compileSdkVersion", String::class.java)
                    method.invoke(android, "android-36")
                } catch (ex: Exception) {
                    try {
                        val method = android::class.java.getMethod("setCompileSdk", java.lang.Integer::class.java)
                        method.invoke(android, 36)
                    } catch (e2: Exception) {
                        // ignore
                    }
                }
            }
        }
    }

    if (project.state.executed) {
        configureAndroid(project)
    } else {
        project.afterEvaluate {
            configureAndroid(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
