package com.zedt.inav.admin

import android.app.admin.DeviceAdminReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

/**
 * Device Admin Receiver for preventing app uninstallation
 */
class InavDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        // Device admin enabled
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        // Device admin disabled
    }

    companion object {
        fun getComponentName(context: Context): ComponentName {
            return ComponentName(context, InavDeviceAdminReceiver::class.java)
        }
    }
}
