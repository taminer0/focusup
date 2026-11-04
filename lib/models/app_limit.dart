import 'dart:math' as math;

class AppLimit {
  final String id;
  final String packageName;
  final String name;
  final int sessionLimitMinutes; // giới hạn cho MỘT lần dùng
  final int sessionUsedSeconds; // đã dùng trong phiên hiện tại
  final bool enabled;

  const AppLimit({
    required this.id,
    required this.packageName,
    required this.name,
    required this.sessionLimitMinutes,
    this.sessionUsedSeconds = 0,
    this.enabled = true,
  });

  int get _limitSeconds => sessionLimitMinutes * 60;

  int get remainingSeconds => math.max(0, _limitSeconds - sessionUsedSeconds);

  double get progress => _limitSeconds == 0
      ? 0
      : (sessionUsedSeconds / _limitSeconds).clamp(0.0, 1.0);

  bool get isExceeded => sessionUsedSeconds >= _limitSeconds;

  factory AppLimit.fromJson(Map<String, dynamic> json) => AppLimit(
    id: json['id'].toString(),
    packageName: json['package_name'] as String,
    name: json['name'] as String,
    sessionLimitMinutes: json['session_limit_minutes'] as int,
    sessionUsedSeconds: (json['session_used_seconds'] ?? 0) as int,
    enabled: (json['enabled'] ?? true) as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'package_name': packageName,
    'name': name,
    'session_limit_minutes': sessionLimitMinutes,
    'session_used_seconds': sessionUsedSeconds,
    'enabled': enabled,
  };

  AppLimit copyWith({
    int? sessionLimitMinutes,
    int? sessionUsedSeconds,
    bool? enabled,
  }) =>
      AppLimit(
        id: id,
        packageName: packageName,
        name: name,
        sessionLimitMinutes: sessionLimitMinutes ?? this.sessionLimitMinutes,
        sessionUsedSeconds: sessionUsedSeconds ?? this.sessionUsedSeconds,
        enabled: enabled ?? this.enabled,
      );
}