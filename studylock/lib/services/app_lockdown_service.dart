import 'package:flutter/services.dart';

class AppBlockerService {
  // Make sure this matches the channel name defined in MainActivity.kt
  static const platform = MethodChannel('com.example.studylock/blocker');

  static Future<bool> isAccessibilityServiceEnabled() async {
    return await platform.invokeMethod<bool>('isAccessibilityServiceEnabled') ??
        false;
  }

  static Future<void> openAccessibilitySettings() async {
    await platform.invokeMethod<void>('openAccessibilitySettings');
  }

  static Future<void> startBlocking(List<String> restrictedPackages) async {
    await platform.invokeMethod<bool>('startBlocking', {
      'restrictedPackages': restrictedPackages,
    });
  }

  static Future<void> stopBlocking() async {
    await platform.invokeMethod<void>('stopBlocking');
  }
}