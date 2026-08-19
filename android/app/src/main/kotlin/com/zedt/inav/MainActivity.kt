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
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.LruCache
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.zedt.inav.services.FocusLockForegroundService
import com.zedt.inav.utils.AccessibilityHelper
import com.zedt.inav.admin.InavDeviceAdminReceiver
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.zedt.inav/focus_lock"
    private val APPS_CHANNEL = "com.zedt.inav/apps"
    private val DEVICE_ADMIN_CHANNEL = "com.zedt.inav/device_admin"
    private val FOREGROUND_SERVICE_CHANNEL = "com.zedt.inav/foreground_service"
    private val USAGE_STATS_CHANNEL = "com.zedt.inav/usage_stats"
    
    private val REQUEST_CODE_ENABLE_ADMIN = 1001
    private var deviceAdminResult: MethodChannel.Result? = null

    // --- Package listing infrastructure (Perplexity-recommended) ---------
    // Package listing + icon rendering is CPU-heavy (drawable→bitmap→PNG for
    // every app). Run on a dedicated single-threaded executor so we never
    // block the main thread or the Flutter UI thread. Post results back via
    // Handler(Looper.getMainLooper()) — MethodChannel.Result must be
    // resolved on main.
    private val appsExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    // 128-entry PNG byte-cache sized for ~48dp launcher icons at ~2-8 KB each
    // (peak ~1 MB, negligible for 2024-flagship class devices).
    private val iconCache = object : LruCache<String, ByteArray>(256) {}

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // GeneratedPluginRegistrant already registered InavLauncherPlugin
        // (via the inav_launcher pubspec plugin declaration). That single
        // plugin handles the cross-engine "open INav" action for both the
        // main engine AND overlay engine.

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

                "openInavApp" -> {
                    val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                    if (launchIntent != null) {
                        startActivity(launchIntent)
                    }
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
        
        // Apps channel — FULL package inventory equivalent to
        // `adb shell pm list packages`. Uses the 2-endpoint pattern from
        // Perplexity research: listApps() returns metadata WITHOUT icons
        // (low allocations, fast — even 500+ apps return in <100 ms), and a
        // separate getAppIcon() renders PNG bytes lazily per visible row.
        val appsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APPS_CHANNEL)
        appsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: true
                    val onlyLaunchable = call.argument<Boolean>("onlyLaunchable") ?: false
                    appsExecutor.execute {
                        try {
                            val apps = getInstalledAppsFull(
                                includeSystemApps = includeSystemApps,
                                onlyLaunchable = onlyLaunchable,
                            )
                            mainHandler.post { result.success(apps) }
                        } catch (t: Throwable) {
                            mainHandler.post {
                                result.error(
                                    "LIST_APPS_FAILED",
                                    t.message ?: t.javaClass.name,
                                    null,
                                )
                            }
                        }
                    }
                }

                "getAppInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName == null) {
                        result.error("INVALID_ARGUMENT", "packageName is required", null)
                        return@setMethodCallHandler
                    }
                    appsExecutor.execute {
                        try {
                            val appInfo = getAppInfoFull(packageName)
                            mainHandler.post { result.success(appInfo) }
                        } catch (t: Throwable) {
                            mainHandler.post {
                                result.error("APP_INFO_FAILED", t.message, null)
                            }
                        }
                    }
                }

                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    val activityName = call.argument<String>("activityName")
                    val sizeDp = (call.argument<Int>("sizeDp") ?: 48).coerceIn(16, 256)
                    if (packageName.isNullOrBlank()) {
                        result.error("BAD_ARGUMENT", "packageName is required", null)
                        return@setMethodCallHandler
                    }
                    appsExecutor.execute {
                        try {
                            val bytes = loadIconBytes(
                                packageName = packageName,
                                activityName = activityName,
                                sizeDp = sizeDp,
                            )
                            mainHandler.post { result.success(bytes) }
                        } catch (e: PackageManager.NameNotFoundException) {
                            mainHandler.post {
                                result.error("NOT_FOUND", packageName, null)
                            }
                        } catch (t: Throwable) {
                            mainHandler.post {
                                result.error("ICON_FAILED", t.message, null)
                            }
                        }
                    }
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

    // ========================================================================
    // Compat helpers — typed flags for Android 13 (Tiramisu / API 33+) with
    // fallback to deprecated Int overloads on older devices.
    // ========================================================================

    private fun getInstalledApplicationsCompat(flags: Long = 0): List<ApplicationInfo> {
        val pm = packageManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(
                PackageManager.ApplicationInfoFlags.of(flags),
            )
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledApplications(flags.toInt())
        }
    }

    private fun queryLauncherActivitiesCompat(
        includeDisabled: Boolean = true,
    ): List<ResolveInfo> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val flags = if (includeDisabled) {
            PackageManager.MATCH_DISABLED_COMPONENTS.toLong()
        } else {
            0L
        }
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(flags),
            )
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(intent, flags.toInt())
        }
    }

    // ========================================================================
    // FULL package inventory (adb shell pm list packages equivalent).
    //
    // * includeSystemApps=true  →  user + system packages (complete list)
    // * includeSystemApps=false →  user-installed packages only, excluding
    //                              anything that shipped with the device
    //                              (FLAG_SYSTEM or FLAG_UPDATED_SYSTEM_APP)
    // * onlyLaunchable=true     →  only packages with a MAIN+LAUNCHER activity
    //                              (i.e. what the user actually sees in their
    //                              home-screen app drawer)
    // ========================================================================

    private fun getInstalledAppsFull(
        includeSystemApps: Boolean,
        onlyLaunchable: Boolean,
    ): List<Map<String, Any?>> {
        val pm = packageManager

        // Resolve all launcher activities once. A package can expose more
        // than one (e.g., Google Docs sometimes lists a separate Sheets
        // entry). Group by package and take the first (deterministic, sorted
        // by label then activity class name) as the canonical representative
        // for the one-row-per-package Dart UI.
        val launcherByPackage: Map<String, List<ResolveInfo>> =
            queryLauncherActivitiesCompat()
                .groupBy { it.activityInfo.packageName }

        val all: List<ApplicationInfo> = getInstalledApplicationsCompat(0)

        return all
            .asSequence()
            // Never show INav itself in its own lock-app list (lock-ception).
            .filter { it.packageName != packageName }
            .filter { app ->
                val isSystem = (app.flags and ApplicationInfo.FLAG_SYSTEM != 0) ||
                    (app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0)
                includeSystemApps || !isSystem
            }
            .filter { app ->
                if (!onlyLaunchable) return@filter true
                launcherByPackage.containsKey(app.packageName)
            }
            .map { appInfo ->
                val launcherList = launcherByPackage[appInfo.packageName]
                val launcher = launcherList
                    ?.sortedWith(
                        compareBy(
                            { it.loadLabel(pm).toString() },
                            { it.activityInfo.name },
                        ),
                    )
                    ?.firstOrNull()

                val label: String = try {
                    launcher?.loadLabel(pm)?.toString()?.takeIf { it.isNotBlank() }
                        ?: appInfo.loadLabel(pm).toString().takeIf { it.isNotBlank() }
                        ?: appInfo.packageName
                } catch (_: Throwable) {
                    appInfo.packageName
                }

                val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0) ||
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0)

                val isSuspended = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
                    (appInfo.flags and ApplicationInfo.FLAG_SUSPENDED != 0)

                mapOf<String, Any?>(
                    "packageName" to appInfo.packageName,
                    "appName" to label,
                    "activityName" to launcher?.activityInfo?.name,
                    "hasLauncherActivity" to (launcher != null),
                    "isEnabled" to appInfo.enabled,
                    "isSuspended" to isSuspended,
                    "isSystemApp" to isSystem,
                    "isUpdatedSystemApp" to
                        (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0),
                )
            }
            .sortedWith(
                compareBy(
                    // Show launchable apps (home screen) FIRST; non-launchable
                    // system packages are typically less interesting.
                    { !(it["hasLauncherActivity"] as Boolean) },
                    // Within that, system-grouped apps (Settings/SystemUI/etc)
                    // come after normal user-installed.
                    { it["isSystemApp"] as Boolean },
                    // Alphabetical by localized display name, ties broken by
                    // package name (deterministic across language changes).
                    { (it["appName"] as String).lowercase() },
                    { it["packageName"] as String },
                ),
            )
            .toList()
    }
    
    private fun getAppInfoFull(packageName: String): Map<String, Any?>? {
        return try {
            val pm = packageManager
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(
                    packageName,
                    PackageManager.ApplicationInfoFlags.of(0),
                )
            } else {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(packageName, 0)
            }
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0) ||
                (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0)
            val isSuspended = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
                (appInfo.flags and ApplicationInfo.FLAG_SUSPENDED != 0)
            val label = appInfo.loadLabel(pm).toString().takeIf { it.isNotBlank() }
                ?: packageName

            mapOf<String, Any?>(
                "packageName" to packageName,
                "appName" to label,
                "hasLauncherActivity" to (pm.getLaunchIntentForPackage(packageName) != null),
                "isEnabled" to appInfo.enabled,
                "isSuspended" to isSuspended,
                "isSystemApp" to isSystem,
                "isUpdatedSystemApp" to
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0),
            )
        } catch (e: Exception) {
            null
        }
    }

    // ========================================================================
    // Lazy icon loader. For packages with a known launcher activity we load
    // via ActivityInfo.loadIcon() (which returns the exact launcher-tray
    // drawable including adaptive icons). For headless packages (no
    // LAUNCHER entry) fall back to ApplicationInfo.loadIcon() — this is the
    // generic package icon, or the default Android "app" icon. Convert any
    // Drawable (vector, adaptive, bitmap) to fixed-size ARGB PNG bytes
    // (StandardMessageCodec decodes ByteArray natively as Uint8List in Dart,
    // so we avoid base64's 33% size penalty and extra encode/decode cost).
    // ========================================================================

    private fun loadIconBytes(
        packageName: String,
        activityName: String?,
        sizeDp: Int,
    ): ByteArray {
        val density = resources.displayMetrics.density
        val sizePx = max(1, (sizeDp * density).roundToInt())

        val cacheKey = "$packageName|${activityName.orEmpty()}|$sizePx"
        iconCache.get(cacheKey)?.let { return it }

        val pm = packageManager
        val drawable: Drawable =
            if (!activityName.isNullOrBlank()) {
                val component = ComponentName(packageName, activityName)
                val activityInfo =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pm.getActivityInfo(
                            component,
                            PackageManager.ComponentInfoFlags.of(
                                PackageManager.MATCH_DISABLED_COMPONENTS.toLong(),
                            ),
                        )
                    } else {
                        @Suppress("DEPRECATION")
                        pm.getActivityInfo(
                            component,
                            PackageManager.MATCH_DISABLED_COMPONENTS,
                        )
                    }
                activityInfo.loadIcon(pm)
            } else {
                val appInfo =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pm.getApplicationInfo(
                            packageName,
                            PackageManager.ApplicationInfoFlags.of(0),
                        )
                    } else {
                        @Suppress("DEPRECATION")
                        pm.getApplicationInfo(packageName, 0)
                    }
                appInfo.loadIcon(pm)
            }

        val bytes = drawableToPng(drawable, sizePx)
        iconCache.put(cacheKey, bytes)
        return bytes
    }

    private fun drawableToPng(drawable: Drawable, sizePx: Int): ByteArray {
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val oldBounds = Rect(drawable.bounds)

        val intrinsicWidth = drawable.intrinsicWidth.takeIf { it > 0 } ?: sizePx
        val intrinsicHeight = drawable.intrinsicHeight.takeIf { it > 0 } ?: sizePx

        val scale = min(
            sizePx.toFloat() / intrinsicWidth,
            sizePx.toFloat() / intrinsicHeight,
        )
        val drawWidth = max(1, (intrinsicWidth * scale).roundToInt())
        val drawHeight = max(1, (intrinsicHeight * scale).roundToInt())
        val left = (sizePx - drawWidth) / 2
        val top = (sizePx - drawHeight) / 2

        try {
            drawable.setBounds(left, top, left + drawWidth, top + drawHeight)
            drawable.draw(canvas)
        } finally {
            drawable.bounds = oldBounds
        }

        return ByteArrayOutputStream().use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            bitmap.recycle()
            stream.toByteArray()
        }
    }

    // ========================================================================
    // Device Admin helpers (ponytail: inline — called only from here, no
    // extra helper class needed for 3 tiny functions).
    // ========================================================================

    private fun isDeviceAdminEnabled(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
            ?: return false
        val comp = InavDeviceAdminReceiver.getComponentName(this)
        return dpm.isAdminActive(comp)
    }

    private fun requestDeviceAdminPermission() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
            ?: return
        val comp = InavDeviceAdminReceiver.getComponentName(this)
        if (dpm.isAdminActive(comp)) {
            deviceAdminResult?.success(true)
            deviceAdminResult = null
            return
        }
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, comp)
            putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                getString(R.string.device_admin_description))
        }
        startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN)
    }

    private fun removeDeviceAdmin(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
            ?: return false
        val comp = InavDeviceAdminReceiver.getComponentName(this)
        return try {
            dpm.removeActiveAdmin(comp)
            true
        } catch (_: SecurityException) {
            false
        }
    }

    // ========================================================================
    // Usage Stats helpers — current foreground app + per-app today usage.
    // Ponytail: Uses the same AppOps guard AccessibilityHelper already uses
    // for UsageStats access; no separate permission check here because
    // callers already gate on hasUsageStatsPermission().
    // ========================================================================

    private fun getCurrentForegroundApp(): String? {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(now - 60_000, now)
        val event = UsageEvents.Event()
        var lastPkg: String? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            ) {
                lastPkg = event.packageName
            }
        }
        return lastPkg
    }

    private fun getAppUsageTimeToday(packageName: String): Long {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return 0L
        val cal = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }
        val start = cal.timeInMillis
        val end = System.currentTimeMillis()
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
        var total = 0L
        for (s in stats) {
            if (s.packageName == packageName) total += s.totalTimeInForeground
        }
        return total
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_ENABLE_ADMIN) {
            val enabled = isDeviceAdminEnabled()
            deviceAdminResult?.success(enabled)
            deviceAdminResult = null
        }
    }

    override fun onDestroy() {
        appsExecutor.shutdown()
        iconCache.evictAll()
        super.onDestroy()
    }
}
