package com.example.studylock

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.studylock/blocker"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                "checkActiveSession" -> {
                    val prefs = applicationContext.getSharedPreferences("UserPreferences", MODE_PRIVATE)
                    val targetEndTime = prefs.getLong("target_end_time", 0)
                    val currentTime = System.currentTimeMillis()

                    if (targetEndTime > currentTime) {
                        val remainingSeconds = ((targetEndTime - currentTime) / 1000).toInt()
                        result.success(remainingSeconds)
                    } else {
                        // Session expired or doesn't exist, 
                        prefs.edit().putLong("target_end_time", 0).apply()
                        result.success(0)
                    }
                }

                "startBlocking" -> {
                    val packages = call.argument<List<String>>("restrictedPackages") ?: listOf()
                    val durationInMinutes = call.argument<Int>("sessionDuration") ?: 0
                    if (!isAppBlockerEnabled()) {
                        result.error(
                            "ACCESSIBILITY_DISABLED",
                            "Enable StudyLock app blocker in Android Accessibility settings first.",
                            null
                        )
                        return@setMethodCallHandler
                    }
                   
                    val calculatedTime = System.currentTimeMillis() + (durationInMinutes * 60 * 1000)
                    val checkSessionStatus = applicationContext.getSharedPreferences("UserPreferences", MODE_PRIVATE)
                    val sessionEditor = checkSessionStatus.edit()
                    sessionEditor.putStringSet("blocked_packages", packages.toSet()).apply()
                    sessionEditor.putLong("target_end_time", calculatedTime).apply()
                    result.success(true)
                }

                "stopBlocking" -> {
                    val checkSessionStatus = applicationContext.getSharedPreferences("UserPreferences", MODE_PRIVATE)
                    val sessionEditor = checkSessionStatus.edit()
                    sessionEditor.putStringSet("blocked_packages",emptySet<String>()).apply()
                    sessionEditor.putLong("target_end_time", 0).apply()
                    
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