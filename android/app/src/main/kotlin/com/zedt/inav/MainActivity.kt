package com.zedt.inav

import android.accessibilityservice.AccessibilityServiceInfo
import android.app.admin.DevicePolicyManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.zedt.inav.services.FocusLockForegroundService
import com.zedt.inav.utils.AccessibilityHelper
import com.zedt.inav.admin.InavDeviceAdminReceiver

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.zedt.inav/focus_lock"
    private val APPS_CHANNEL = "com.zedt.inav/apps"
    private val DEVICE_ADMIN_CHANNEL = "com.zedt.inav/device_admin"
    private val FOREGROUND_SERVICE_CHANNEL = "com.zedt.inav/foreground_service"
    private val USAGE_STATS_CHANNEL = "com.zedt.inav/usage_stats"
    
    private val REQUEST_CODE_ENABLE_ADMIN = 1001
    private var deviceAdminResult: MethodChannel.Result? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Focus lock channel
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
                    if (am == null) {
                        result.success(false)
                    } else {
                        val enabled = am.getEnabledAccessibilityServiceList(
                            AccessibilityServiceInfo.FEEDBACK_ALL_MASK
                        )
                        val isEnabled = enabled.any { info ->
                            info.resolveInfo.serviceInfo.packageName == packageName
                        }
                        result.success(isEnabled)
                    }
                }

                "openAccessibilitySettings" -> {
                    AccessibilityHelper.openAccessibilitySettings(this)
                    result.success(true)
                }

                "hasUsageStatsPermission" -> {
                    val hasPermission = AccessibilityHelper.hasUsageStatsPermission(this)
                    result.success(hasPermission)
                }

                "openUsageAccessSettings" -> {
                    AccessibilityHelper.openUsageAccessSettings(this)
                    result.success(true)
                }

                "showLockOverlay" -> {
                    result.success(true)
                }

                "hideLockOverlay" -> {
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
        
        // Apps channel
        val appsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APPS_CHANNEL)
        appsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
                    val apps = getInstalledApps(includeSystemApps)
                    result.success(apps)
                }
                
                "getAppInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName == null) {
                        result.error("INVALID_ARGUMENT", "packageName is required", null)
                        return@setMethodCallHandler
                    }
                    val appInfo = getAppInfo(packageName)
                    result.success(appInfo)
                }
                
                else -> result.notImplemented()
            }
        }
        
        // Device admin channel
        val deviceAdminChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_ADMIN_CHANNEL)
        deviceAdminChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceAdminEnabled" -> {
                    val isEnabled = isDeviceAdminEnabled()
                    result.success(isEnabled)
                }
                
                "requestDeviceAdmin" -> {
                    deviceAdminResult = result
                    requestDeviceAdminPermission()
                }
                
                "removeDeviceAdmin" -> {
                    val removed = removeDeviceAdmin()
                    result.success(removed)
                }
                
                else -> result.notImplemented()
            }
        }
        
        // Foreground service channel
        val foregroundServiceChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FOREGROUND_SERVICE_CHANNEL)
        foregroundServiceChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    FocusLockForegroundService.start(this)
                    result.success(true)
                }
                
                "stopForegroundService" -> {
                    FocusLockForegroundService.stop(this)
                    result.success(true)
                }
                
                else -> result.notImplemented()
            }
        }

        // Usage stats channel
        val usageStatsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_STATS_CHANNEL)
        usageStatsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    val hasPermission = AccessibilityHelper.hasUsageStatsPermission(this)
                    result.success(hasPermission)
                }
                
                "openUsageAccessSettings" -> {
                    AccessibilityHelper.openUsageAccessSettings(this)
                    result.success(true)
                }
                
                "getCurrentApp" -> {
                    val currentApp = getCurrentForegroundApp()
                    result.success(currentApp)
                }
                
                "getAppUsageTime" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName == null) {
                        result.error("INVALID_ARGUMENT", "packageName is required", null)
                        return@setMethodCallHandler
                    }
                    val usageTime = getAppUsageTimeToday(packageName)
                    result.success(usageTime)
                }
                
                else -> result.notImplemented()
            }
        }
    }
    
    private fun getInstalledApps(includeSystemApps: Boolean): List<Map<String, String>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        val coreOsBlacklist = setOf(
            "com.android.launcher",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.sec.android.app.launcher",
            "com.miui.home",
            "com.oneplus.launcher",
            "com.android.settings",
            "com.android.systemui",
            "com.android.packageinstaller",
            "com.google.android.packageinstaller",
            "com.android.dialer",
            "com.google.android.dialer",
            "com.samsung.android.dialer",
            "com.android.incallui",
            "com.android.server.telecom",
            "com.android.emergency",
            "com.android.phone",
            "com.android.providers.settings"
        )

        return apps
            .filter { app ->
                val packageName = app.packageName

                if (packageName == this.packageName) return@filter false
                if (coreOsBlacklist.contains(packageName)) return@filter false

                val launchIntent = pm.getLaunchIntentForPackage(packageName)
                if (launchIntent == null) return@filter false

                true
            }
            .mapNotNull { app ->
                try {
                    val appName = pm.getApplicationLabel(app).toString()
                    val packageName = app.packageName

                    mapOf(
                        "packageName" to packageName,
                        "appName" to appName
                    )
                } catch (e: Exception) {
                    null
                }
            }
            .sortedBy { it["appName"] }
    }
    
    private fun getAppInfo(packageName: String): Map<String, String>? {
        return try {
            val pm = packageManager
            val app = pm.getApplicationInfo(packageName, 0)
            val appName = pm.getApplicationLabel(app).toString()
            
            mapOf(
                "packageName" to packageName,
                "appName" to appName
            )
        } catch (e: Exception) {
            null
        }
    }
    
    private fun isDeviceAdminEnabled(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponent = InavDeviceAdminReceiver.getComponentName(this)
        return dpm.isAdminActive(adminComponent)
    }
    
    private fun requestDeviceAdminPermission() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponent = InavDeviceAdminReceiver.getComponentName(this)
        
        if (!dpm.isAdminActive(adminComponent)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    "Enable device admin to prevent app uninstallation during focus lock"
                )
            }
            startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN)
        } else {
            deviceAdminResult?.success(true)
            deviceAdminResult = null
        }
    }
    
    private fun removeDeviceAdmin(): Boolean {
        return try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val adminComponent = InavDeviceAdminReceiver.getComponentName(this)
            
            if (dpm.isAdminActive(adminComponent)) {
                dpm.removeActiveAdmin(adminComponent)
            }
            true
        } catch (e: Exception) {
            false
        }
    }
    
    private fun getCurrentForegroundApp(): String? {
        return try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val endTime = System.currentTimeMillis()
            val beginTime = endTime - 1000 * 60 * 2 // Look at last 2 minutes

            val events = usm.queryEvents(beginTime, endTime)
            val event = UsageEvents.Event()
            var lastPackage: String? = null

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                        event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        lastPackage = event.packageName
                    }
                } else {
                    @Suppress("DEPRECATION")
                    if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        lastPackage = event.packageName
                    }
                }
            }
            lastPackage
        } catch (e: Exception) {
            null
        }
    }

    private fun getAppUsageTimeToday(packageName: String): Int {
        return try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val calendar = java.util.Calendar.getInstance()
            calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
            calendar.set(java.util.Calendar.MINUTE, 0)
            calendar.set(java.util.Calendar.SECOND, 0)
            calendar.set(java.util.Calendar.MILLISECOND, 0)
            val startOfDay = calendar.timeInMillis
            val endTime = System.currentTimeMillis()

            val stats = usm.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startOfDay,
                endTime
            )

            var totalTime = 0L
            for (stat in stats) {
                if (stat.packageName == packageName) {
                    totalTime += stat.totalTimeInForeground
                }
            }
            (totalTime / 1000).toInt() // Return seconds
        } catch (e: Exception) {
            0
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_CODE_ENABLE_ADMIN) {
            val isEnabled = isDeviceAdminEnabled()
            deviceAdminResult?.success(isEnabled)
            deviceAdminResult = null
        }
    }
}
