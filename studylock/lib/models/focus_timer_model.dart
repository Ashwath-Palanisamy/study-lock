enum FocusSessionState { idle, focusing, breaking }

class FocusTimerModel {
  final FocusSessionState state;
  final int remainingSeconds;
  final int totalDurationSeconds;

  FocusTimerModel({
    required this.state,
    required this.remainingSeconds,
    required this.totalDurationSeconds,
  });

  FocusTimerModel copyWith({
    FocusSessionState? state,
    int? remainingSeconds,
    int? totalDurationSeconds,
  }) {
    return FocusTimerModel(
      state: state ?? this.state,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    );
  }
}
