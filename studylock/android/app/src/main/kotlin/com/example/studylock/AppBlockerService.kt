package com.example.studylock

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent

class AppBlockerService : AccessibilityService() {

    companion object {
        var isBlockingEnabled = false
        var restrictedPackages: List<String> = listOf()
        var instance: AppBlockerService? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!isBlockingEnabled) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Don't trigger if they are already looking at StudyLock
            if (packageName == "com.example.studylock") return

            // If a restricted app is launched, bring StudyLock to the front with a block flag
            if (restrictedPackages.contains(packageName)) {
                val blockIntent = packageManager.getLaunchIntentForPackage("com.example.studylock")?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra("is_blocked_attempt", true)
                }
                if (blockIntent != null) {
                    startActivity(blockIntent)
                }
            }
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}