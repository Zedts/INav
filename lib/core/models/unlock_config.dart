/// Unlock method types
enum UnlockMethod {
  waitItOut,
  markPrayed,
  mindfulPause,
  typePhrase,
}

/// Configuration for unlock behavior
class UnlockConfig {
  final UnlockMethod method;
  final int waitDurationSeconds; // For waitItOut
  final int mindfulPauseSeconds; // For mindfulPause
  final String unlockPhrase; // For typePhrase

  const UnlockConfig({
    required this.method,
    this.waitDurationSeconds = 60,
    this.mindfulPauseSeconds = 60,
    this.unlockPhrase = 'Prayer comes first',
  });

  Map<String, dynamic> toJson() => {
        'method': method.name,
        'waitDurationSeconds': waitDurationSeconds,
        'mindfulPauseSeconds': mindfulPauseSeconds,
        'unlockPhrase': unlockPhrase,
      };

  factory UnlockConfig.fromJson(Map<String, dynamic> json) => UnlockConfig(
        method: UnlockMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => UnlockMethod.waitItOut,
        ),
        waitDurationSeconds: json['waitDurationSeconds'] as int? ?? 60,
        mindfulPauseSeconds: json['mindfulPauseSeconds'] as int? ?? 60,
        unlockPhrase:
            json['unlockPhrase'] as String? ?? 'Prayer comes first',
      );

  UnlockConfig copyWith({
    UnlockMethod? method,
    int? waitDurationSeconds,
    int? mindfulPauseSeconds,
    String? unlockPhrase,
  }) =>
      UnlockConfig(
        method: method ?? this.method,
        waitDurationSeconds: waitDurationSeconds ?? this.waitDurationSeconds,
        mindfulPauseSeconds: mindfulPauseSeconds ?? this.mindfulPauseSeconds,
        unlockPhrase: unlockPhrase ?? this.unlockPhrase,
      );
}
