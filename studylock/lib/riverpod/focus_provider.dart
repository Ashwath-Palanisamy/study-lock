import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:studylock/models/focus_timer_model.dart';
import 'package:studylock/services/app_lockdown_service.dart';

class FocusProvider extends Notifier<FocusTimerModel> {
  Timer? _timer;
  StreamSubscription<PhoneState>? _phoneStateSubscription;

  Future<PermissionStatus> phoneRequestPermission() async {
    PermissionStatus permission = await Permission.phone.request();
    return permission;
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        HapticFeedback.successNotification();
      } else {
        timer.cancel();
        HapticFeedback.heavyImpact();
        
        // Stop blocking when the session is completed
        AppBlockerService.stopBlocking();

        state = state.copyWith(
          state: FocusSessionState.idle,
          remainingSeconds: 0,
          totalDurationSeconds: 0,
        );
      }
    });
  }

  void startSessionTimer(int minutes, {List<String> restrictedPackages = const []}) async {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();

    //  Check Android Accessibility Service permission first (Strict Enforcement)
    bool isAccessibilityEnabled = await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    
    if (!isAccessibilityEnabled) {
      // Prompt user to enable accessibility permission
      await FlutterAccessibilityService.requestAccessibilityPermission();
      
      // Abort session startup until permission is granted
      return;
    }

    // Check and request phone permissions
    PermissionStatus status = await phoneRequestPermission();

    if (status.isGranted) {
      _phoneStateSubscription = PhoneState.stream.listen((phoneState) {
        if (phoneState.status == PhoneStateStatus.CALL_INCOMING ||
            phoneState.status == PhoneStateStatus.CALL_STARTED) {
          _timer?.cancel();
          state = state.copyWith(state: FocusSessionState.breaking);
        } else if (phoneState.status == PhoneStateStatus.CALL_ENDED ||
            phoneState.status == PhoneStateStatus.NOTHING) {
          if (state.state == FocusSessionState.breaking &&
              state.remainingSeconds > 0) {
            state = state.copyWith(state: FocusSessionState.focusing);
            _resumeTimer();
          }
        }
      });
    }

    // Define essential allowed apps (Phone, SMS, and StudyLock itself)
    final List<String> safeSystemPackages = [
      'com.example.studylock',         // StudyLock 
      'com.android.server.telecom',    // Core Phone Call UI
      'com.google.android.dialer',     // Google Phone App
      'com.android.dialer',            // Default Android Dialer
      'com.google.android.apps.messaging', // Google Messages
      'com.android.mms',               // Default SMS App
    ];

    // Filter out safe system apps just in case they were accidentally included
    final finalRestrictedList = restrictedPackages
        .where((pkg) => !safeSystemPackages.contains(pkg))
        .toList();

    // pass the cleaned restricted apps list to the native app blocker service
    AppBlockerService.startBlocking(finalRestrictedList);

    int totalSeconds = minutes * 60;
    state = state.copyWith(
      state: FocusSessionState.focusing,
      remainingSeconds: totalSeconds,
      totalDurationSeconds: totalSeconds,
    );
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        HapticFeedback.successNotification();
      } else {
        timer.cancel();
        HapticFeedback.heavyImpact();
        
        // Stop blocking when the session hits zero
        AppBlockerService.stopBlocking();

        state = state.copyWith(
          state: FocusSessionState.idle,
          remainingSeconds: 0, 
          totalDurationSeconds: 0,
        );
      }
    });
  }

  void resetSessionTimer() {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();
    state = state.copyWith(
      state: FocusSessionState.idle,
      remainingSeconds: 0,
      totalDurationSeconds: 0,
    );
    // Stop blocking when timer resets (Session Cancelled)
    AppBlockerService.stopBlocking();
  }

  @override
  build() {
    return FocusTimerModel(
      state: FocusSessionState.idle,
      remainingSeconds: 0,
      totalDurationSeconds: 0,
    );
  }
}

final focusProvider = NotifierProvider<FocusProvider, FocusTimerModel>(() {
  return FocusProvider();
});