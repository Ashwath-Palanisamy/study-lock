package com.example.studylock

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
                    AppBlockerService.restrictedPackages = packages
                    AppBlockerService.isBlockingEnabled = true
                    result.success(true)
                }
                "stopBlocking" -> {
                    AppBlockerService.isBlockingEnabled = false
                    AppBlockerService.restrictedPackages = listOf()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}