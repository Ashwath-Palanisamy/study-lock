import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppBlockerService {
  // Make sure this matches the channel name defined in MainActivity.kt
  static const platform = MethodChannel('com.example.studylock/blocker');

  static Future<void> startBlocking(List<String> restrictedPackages) async {
    try {
      await platform.invokeMethod('startBlocking', {
        'restrictedPackages': restrictedPackages,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting app blocker: $e');
      }
    }
  }

  static Future<void> stopBlocking() async {
    try {
      await platform.invokeMethod('stopBlocking');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping app blocker: $e');
      }
    }
  }
}