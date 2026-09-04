package com.example.studylock

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.app.ActivityManager
import android.content.Context
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.studylock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine) 

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> 
            when (call.method) {
                "startLockTask" -> {
                    try {
                        startLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Failed to start lock task: ${e.message}", null)
                    }
                }
                "stopLockTask" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Failed to stop lock task: ${e.message}", null)
                    }
                }
                "isLocked" -> {
                    val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val isLocked = activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
                    result.success(isLocked)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}