package com.zedt.inav.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.zedt.inav.services.FocusLockForegroundService

/**
 * Boot receiver to restart Focus Lock service after device reboot
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Check if Focus Lock was enabled before reboot
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val masterEnabled = prefs.getBoolean("flutter.focus_lock_master_enabled", false)
            
            if (masterEnabled) {
                // Restart foreground service
                FocusLockForegroundService.start(context)
            }
        }
    }
}
