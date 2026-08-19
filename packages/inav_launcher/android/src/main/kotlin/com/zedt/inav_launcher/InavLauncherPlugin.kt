package com.zedt.inav_launcher

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Opens the host app's MainActivity from ANY FlutterEngine (main app engine
 * OR overlay isolate engine spawned by flutter_accessibility_service).
 *
 * Uses Application-level Context + FLAG_ACTIVITY_NEW_TASK so this works even
 * when called from a system-overlay window where there is NO foreground
 * Activity (url_launcher_android throws PlatformException(NO_ACTIVITY) in
 * that case).
 *
 * Auto-registered on EVERY FlutterEngine created in the process because:
 *   (a) inav_launcher is listed as a flutter_plugin in its pubspec.yaml, AND
 *   (b) every FlutterEngine in the app runs `GeneratedPluginRegistrant`.
 */
class InavLauncherPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        const val CHANNEL = "com.zedt.inav_launcher"
        const val METHOD_OPEN_INAV = "openInavApp"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != METHOD_OPEN_INAV) {
            result.notImplemented()
            return
        }
        try {
            val packageName = context.packageName
            val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
            val intent = launchIntent?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            } ?: Intent().apply {
                setClassName(packageName, "$packageName.MainActivity")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            context.startActivity(intent)
            result.success(true)
        } catch (t: Throwable) {
            result.error("OPEN_FAILED", t.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
