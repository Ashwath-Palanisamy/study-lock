import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LockdownService {
  static const platform = MethodChannel('com.example.studylock');

  static Future<void> startLockdownMode() async {
    try {
      await platform.invokeMethod('startLockTask');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
  }

  static Future<void> stopLockdownMode() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
  }
}
