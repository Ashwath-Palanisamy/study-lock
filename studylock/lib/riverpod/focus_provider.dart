import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:studylock/models/focus_timer_model.dart';
import 'package:studylock/services/lockdown_service.dart';

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
        
        // stop lockdown mode when the session is completed
        LockdownService.stopLockdownMode();

        state = state.copyWith(
          state: FocusSessionState.idle,
          remainingSeconds: 0,
          totalDurationSeconds: 0,
        );
      }
    });
  }

  void startSessionTimer(int minutes) async {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();

    PermissionStatus status = await phoneRequestPermission();

    if (status.isGranted) {
      _phoneStateSubscription = PhoneState.stream.listen((phoneState) {
        if (phoneState.status == PhoneStateStatus.CALL_INCOMING ||
            phoneState.status == PhoneStateStatus.CALL_STARTED) {
          _timer?.cancel();
          state = state.copyWith(state: FocusSessionState.breaking);
        } else if (phoneState.status == PhoneStateStatus.CALL_ENDED ||
            phoneState.status == PhoneStateStatus.NOTHING) {
          // Resume the timer if we were previously focusing/paused and have time left
          if (state.state == FocusSessionState.breaking &&
              state.remainingSeconds > 0) {
            state = state.copyWith(state: FocusSessionState.focusing);
            _resumeTimer();
          }
        }
      });
    }

    LockdownService.startLockdownMode();

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
        
        // Start lockdown mode when the timer starts
        LockdownService.stopLockdownMode();

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
    // Stop lockdown mode when timer resets (Session Cancelled)
    LockdownService.stopLockdownMode();
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