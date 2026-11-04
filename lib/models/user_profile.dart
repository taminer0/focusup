class UserProfile {
  final String id;
  final String name;
  final String email;
  final int taskCount;
  final int streak;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.taskCount = 0,
    this.streak = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'].toString(),
    name: json['name'] as String,
    email: json['email'] as String,
    taskCount: (json['task_count'] ?? 0) as int,
    streak: (json['streak'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'task_count': taskCount,
    'streak': streak,
  };
}