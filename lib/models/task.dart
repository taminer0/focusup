enum TaskPriority { high, medium, low, special }

class Task {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime start;
  final DateTime? end;
  final TaskPriority priority;
  final bool isDone;
  final bool hasTime;
  final List<int> repeatDays;
  final String? externalId; // id sự kiện bên Google Calendar
  final String source; // 'local' hoặc 'google'

  const Task({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.description,
    this.location,
    this.priority = TaskPriority.medium,
    this.isDone = false,
    this.hasTime = true,
    this.repeatDays = const [],
    this.externalId,
    this.source = 'local',
  });

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String get timeRange {
    if (!hasTime) return 'Cả ngày';
    return end == null ? _hm(start) : '${_hm(start)} - ${_hm(end!)}';
  }

  String get dateLabel {
    final wd = start.weekday == 7 ? 'CN' : 'Thứ ${start.weekday + 1}';
    return '$wd, ${start.day}/${start.month}';
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'].toString(),
    title: json['title'] as String,
    description: json['description'] as String?,
    location: json['location'] as String?,
    start: DateTime.parse(json['start_time'] as String).toLocal(),
    end: json['end_time'] == null
        ? null
        : DateTime.parse(json['end_time'] as String).toLocal(),
    priority: TaskPriority.values.byName(json['priority'] as String),
    isDone: (json['is_done'] ?? false) as bool,
    hasTime: (json['has_time'] ?? true) as bool,
    repeatDays: List<int>.from(json['repeat_days'] ?? const []),
    externalId: json['external_id'] as String?,
    source: (json['source'] ?? 'local') as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'start_time': start.toUtc().toIso8601String(),
    'end_time': end?.toUtc().toIso8601String(),
    'priority': priority.name,
    'is_done': isDone,
    'has_time': hasTime,
    'repeat_days': repeatDays,
    'external_id': externalId,
    'source': source,
  };

  Task copyWith({
    String? title,
    String? description,
    String? location,
    DateTime? start,
    DateTime? end,
    TaskPriority? priority,
    bool? isDone,
    bool? hasTime,
    List<int>? repeatDays,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        start: start ?? this.start,
        end: end ?? this.end,
        priority: priority ?? this.priority,
        isDone: isDone ?? this.isDone,
        hasTime: hasTime ?? this.hasTime,
        repeatDays: repeatDays ?? this.repeatDays,
        externalId: externalId,
        source: source,
      );
}