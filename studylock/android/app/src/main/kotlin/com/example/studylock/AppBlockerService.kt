package com.example.studylock

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.telecom.TelecomManager
import android.provider.Telephony
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log
import android.graphics.Rect

class AppBlockerService : AccessibilityService() {

    companion object {
        var instance: AppBlockerService? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        serviceInfo = serviceInfo.apply {
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
        }
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!isSessionStillActive()) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            event.eventType == AccessibilityEvent.TYPE_WINDOWS_CHANGED
        ) {

            // Loop through all active windows currently drawn on the screen
            for (window in windows) {
                // Application and overlay windows can both represent the blocked surface.
                Log.d("AppBlocker", "Window type: ${window.type}")
                if (isBlockableWindow(window)) {
                    val rootNode = window.root ?: continue
                    try {
                        val packageName = rootNode.packageName?.toString() ?: continue
                        Log.d("AppBlocker", "Window type: ${window.type}, ${packageName}")

                        // Don't trigger if it's StudyLock itself
                        if (packageName == "com.example.studylock") continue

                        if (shouldBlock(packageName)) {
                            clickFloatingWindowDismissButton(rootNode)

                            val blockIntent = packageManager.getLaunchIntentForPackage("com.example.studylock")?.apply {
                                addFlags(
                                    Intent.FLAG_ACTIVITY_NEW_TASK or
                                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                            Intent.FLAG_ACTIVITY_CLEAR_TOP
                                )
                                putExtra("is_blocked_attempt", true)
                            }
                            if (blockIntent != null) {
                                if (shouldUseHomeFallback(window)) {
                                    performGlobalAction(GLOBAL_ACTION_HOME)
                                }
                                startActivity(blockIntent)
                            }
                            return // Stop checking once a blocked app or overlay is handled
                        }
                    } finally {
                        rootNode.recycle()
                    }
                }
            }
        }
    }

    private fun isBlockableWindow(window: android.view.accessibility.AccessibilityWindowInfo): Boolean {
        return window.type == android.view.accessibility.AccessibilityWindowInfo.TYPE_APPLICATION ||
                window.type == android.view.accessibility.AccessibilityWindowInfo.TYPE_ACCESSIBILITY_OVERLAY ||
                window.type == android.view.WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
    }

    private fun shouldUseHomeFallback(
        window: android.view.accessibility.AccessibilityWindowInfo,
    ): Boolean {
        if (isPersistentOverlay(window)) return true
        return isFloatingApplicationWindow(window)
    }

    private fun isPersistentOverlay(
        window: android.view.accessibility.AccessibilityWindowInfo,
    ): Boolean {
        return window.type == android.view.accessibility.AccessibilityWindowInfo.TYPE_ACCESSIBILITY_OVERLAY ||
                window.type == android.view.WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
    }

    private fun isFloatingApplicationWindow(
        window: android.view.accessibility.AccessibilityWindowInfo,
    ): Boolean {
        if (window.type != android.view.accessibility.AccessibilityWindowInfo.TYPE_APPLICATION) {
            return false
        }
        if (window.isInPictureInPictureMode) return true

        val bounds = Rect()
        window.getBoundsInScreen(bounds)
        val displayMetrics = resources.displayMetrics
        val displayWidth = displayMetrics.widthPixels
        val displayHeight = displayMetrics.heightPixels
        if (bounds.isEmpty || displayWidth <= 0 || displayHeight <= 0) return false

        // A true freeform container is inset from every display edge. Full-screen
        // and split-screen windows touch at least one edge of the display.
        val minimumInset = (displayMetrics.density * 24f).toInt()
        return bounds.left >= minimumInset &&
                bounds.top >= minimumInset &&
                displayWidth - bounds.right >= minimumInset &&
                displayHeight - bounds.bottom >= minimumInset
    }

    private fun clickFloatingWindowDismissButton(rootNode: AccessibilityNodeInfo): Boolean {
        val containerBounds = Rect()
        rootNode.getBoundsInScreen(containerBounds)
        return clickFloatingWindowDismissButton(rootNode, containerBounds)
    }

    private fun clickFloatingWindowDismissButton(
        node: AccessibilityNodeInfo,
        containerBounds: Rect,
    ): Boolean {
        if (isDismissNode(node, containerBounds) &&
            node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
        ) {
            return true
        }

        for (index in 0 until node.childCount) {
            val childNode = node.getChild(index) ?: continue
            try {
                if (clickFloatingWindowDismissButton(childNode, containerBounds)) {
                    return true
                }
            } finally {
                childNode.recycle()
            }
        }

        return false
    }

    private fun isDismissNode(node: AccessibilityNodeInfo, containerBounds: Rect): Boolean {
        val dismissKeywords = listOf("close", "dismiss", "exit")
        val description = node.contentDescription?.toString()?.lowercase().orEmpty()
        val text = node.text?.toString()?.lowercase().orEmpty()
        val hasDismissKeyword = dismissKeywords.any { keyword ->
            description.contains(keyword) || text.contains(keyword)
        }

        if (hasDismissKeyword) {
            return node.isClickable
        }

        if (!node.isClickable) return false

        val className = node.className?.toString().orEmpty()
        val isButtonOrImage = className.endsWith("Button") ||
                className.endsWith("ImageButton") ||
                className.endsWith("ImageView")
        if (!isButtonOrImage) return false

        val nodeBounds = Rect()
        node.getBoundsInScreen(nodeBounds)
        val headerBottom = containerBounds.top +
            (containerBounds.height() * 0.25f).toInt()
        return nodeBounds.top <= headerBottom && nodeBounds.bottom <= headerBottom
    }

    private fun isSessionStillActive(): Boolean {
        val storageFile = applicationContext.getSharedPreferences("UserPreferences", MODE_PRIVATE)
        val targetEndTime = storageFile.getLong("target_end_time", 0)
        val currentTime = System.currentTimeMillis()
        return currentTime < targetEndTime
    }

    private fun shouldBlock(packageName: String): Boolean {

        val packageSharedPreferences = applicationContext.getSharedPreferences("UserPreferences", MODE_PRIVATE)
        val packagesList =
            packageSharedPreferences.getStringSet("blocked_packages", emptySet<String>()) ?: emptySet<String>()

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

        return packagesList.isEmpty() || packagesList.contains(packageName)
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