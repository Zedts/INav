package com.zedt.inav

import android.app.Application

/**
 * Application class — instantiated by Android for every process in the app
 * (main process + any background services). Future shared MethodChannel
 * registrations / app-wide singletons go here.
 */
class InavApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        appContext = this
    }

    companion object {
        lateinit var appContext: Application
            private set
    }
}
