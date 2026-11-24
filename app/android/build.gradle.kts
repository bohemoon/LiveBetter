// 本地默认走国内镜像加速；CI（GitHub Actions 会设置 CI=true）直接用官方仓库，避免镜像不可用导致构建失败。
val useMirrors = System.getenv("CI") == null

allprojects {
    repositories {
        if (useMirrors) {
            maven { url = uri("file:///D:/dev/flutter-engine-repo") }
            maven { url = uri("https://maven.aliyun.com/repository/google") }
            maven { url = uri("https://maven.aliyun.com/repository/central") }
        }
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

// AGP 9.3 lint 在 JDK 17 下分析部分插件源码会崩溃，release 构建统一跳过 lintVital 任务。
subprojects {
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
