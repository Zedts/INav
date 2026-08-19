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

    // Redirect native build staging (obj / .so outputs) into the local writable
    // build/ tree for every Android subproject (app + every pub-cache plugin).
    // Uses reflection-only access because the root buildscript classpath does
    // NOT include AGP types — referencing LibraryExtension at compile time
    // would fail script compilation.
    fun redirectBuildStaging(pluginId: String) {
        pluginManager.withPlugin(pluginId) {
            val android = extensions.findByName("android") ?: return@withPlugin
            val getEnb = android.javaClass.methods.firstOrNull { it.name == "getExternalNativeBuild" } ?: return@withPlugin
            val enb = getEnb.invoke(android)
            val getBsd = enb.javaClass.methods.firstOrNull { it.name == "getBuildStagingDirectory" } ?: return@withPlugin
            val bsdProp = getBsd.invoke(enb)
            val set = bsdProp.javaClass.methods.firstOrNull { m -> m.name == "set" && m.parameterCount == 1 } ?: return@withPlugin
            set.invoke(bsdProp, java.io.File(project.layout.buildDirectory.get().asFile, "cxx"))
        }
    }
    redirectBuildStaging("com.android.library")
    redirectBuildStaging("com.android.application")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
