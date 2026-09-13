import 'package:flutter/services.dart';

class AppBlockerService {
  
  static const platform = MethodChannel('com.example.studylock/blocker');

  static Future<bool> isAccessibilityServiceEnabled() async {
    return await platform.invokeMethod<bool>('isAccessibilityServiceEnabled') ??
        false;
  }

  static Future<void> openAccessibilitySettings() async {
    await platform.invokeMethod<void>('openAccessibilitySettings');
  }

  static Future<int> checkActiveSession() async {
    final remainingSeconds = await platform.invokeMethod<int>('checkActiveSession');
    return remainingSeconds ?? 0;
  }

  static Future<void> startBlocking(
    List<String> restrictedPackages,
    int sessionDuration,
    List<String> safeSystemPackages,
  ) async {
    await platform.invokeMethod<bool>('startBlocking', {
      'restrictedPackages': restrictedPackages,
      'safeSystemPackages': safeSystemPackages, 
      'sessionDuration': sessionDuration,
    });
  }

  static Future<void> stopBlocking() async {
    await platform.invokeMethod<void>('stopBlocking');
  }
}