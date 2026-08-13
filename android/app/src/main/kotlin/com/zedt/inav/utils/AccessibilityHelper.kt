package com.zedt.inav.utils

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.view.accessibility.AccessibilityManager

/**
 * Helper class for accessibility service operations
 */
object AccessibilityHelper {
    
    /**
     * Check if our accessibility service is enabled
     */
    fun isAccessibilityServiceEnabled(context: Context, serviceClass: Class<*>): Boolean {
        val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
            ?: return false
        
        val enabledServices = am.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK
        )
        
        val expectedComponentName = "${context.packageName}/${serviceClass.canonicalName}"
        
        return enabledServices.any { service ->
            service.id == expectedComponentName
        }
    }
    
    /**
     * Open accessibility settings page
     */
    fun openAccessibilitySettings(context: Context) {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }
    
    /**
     * Check if PACKAGE_USAGE_STATS permission is granted
     */
    fun hasUsageStatsPermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? android.app.AppOpsManager
            ?: return false
        
        val mode = appOps.checkOpNoThrow(
            android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }
    
    /**
     * Open usage access settings page
     */
    fun openUsageAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }
}
