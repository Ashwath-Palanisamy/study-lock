package com.example.studylock

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.telecom.TelecomManager
import android.provider.Telephony
import android.view.accessibility.AccessibilityEvent

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

    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
        }
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!isBlockingEnabled) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Don't trigger if they are already looking at StudyLock
            if (packageName == "com.example.studylock") return

            // An empty restriction list means strict mode: block every user app
            // except the current app, the phone app, and the SMS app.
            if (shouldBlock(packageName)) {
                val blockIntent = packageManager.getLaunchIntentForPackage("com.example.studylock")?.apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP
                    )
                    putExtra("is_blocked_attempt", true)
                }
                if (blockIntent != null) {
                    startActivity(blockIntent)
                }
            }
        }
    }

    private fun shouldBlock(packageName: String): Boolean {
        if (packageName == packageNameForStudyLock() ||
        packageName == homePackageName() ||
        allowedSystemPackages.contains(packageName) ||
        packageName in launcherPackages()
        ) {
            return false
        }

        val defaultDialer = getSystemService(TelecomManager::class.java)?.defaultDialerPackage
        val defaultSms = Telephony.Sms.getDefaultSmsPackage(this)
        if (packageName == defaultDialer || packageName == defaultSms) {
            return false
        }

        return restrictedPackages.isEmpty() || restrictedPackages.contains(packageName)
    }

    private fun packageNameForStudyLock(): String = applicationContext.packageName

    private fun launcherPackages(): Set<String> {
        val launcherIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        return packageManager.queryIntentActivities(
            launcherIntent,
            android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
        )
            .mapNotNull { it.activityInfo?.packageName }
            .toSet() + setOf(
            "com.android.launcher",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.google.android.launcher",
        )
    }

    private fun homePackageName(): String? =
        packageManager.resolveActivity(
            Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            },
            android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
        )?.activityInfo?.packageName

    private val allowedSystemPackages = setOf(
        "android",
        "com.android.systemui",
        "com.android.settings",
    )

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}