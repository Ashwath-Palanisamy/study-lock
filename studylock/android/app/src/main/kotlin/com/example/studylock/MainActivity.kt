package com.example.studylock

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.studylock/blocker"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBlocking" -> {
                    val packages = call.argument<List<String>>("restrictedPackages") ?: listOf()
                    if (!isAppBlockerEnabled()) {
                        result.error(
                            "ACCESSIBILITY_DISABLED",
                            "Enable StudyLock app blocker in Android Accessibility settings first.",
                            null
                        )
                        return@setMethodCallHandler
                    }
                    AppBlockerService.restrictedPackages = packages
                    AppBlockerService.isBlockingEnabled = true
                    result.success(true)
                }
                "stopBlocking" -> {
                    AppBlockerService.isBlockingEnabled = false
                    AppBlockerService.restrictedPackages = listOf()
                    result.success(true)
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAppBlockerEnabled())
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAppBlockerEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val expected = ComponentName(this, AppBlockerService::class.java).flattenToString()
        return enabledServices.split(':').any { it.equals(expected, ignoreCase = true) }
    }
}