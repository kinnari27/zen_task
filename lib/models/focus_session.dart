class FocusSession {
  final String id;
  final String? taskId;       // Nullable if not linked to a specific task
  final String taskTitle;     // Focus descriptor (e.g. "Mindful Breathing" or task title)
  final String category;      // Focus category ('Mind', 'Work', etc.)
  final int durationSeconds;  // Focused seconds
  final DateTime timestamp;

  FocusSession({
    required this.id,
    this.taskId,
    required this.taskTitle,
    required this.category,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'category': category,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      taskTitle: json['taskTitle'] as String,
      category: json['category'] as String,
      durationSeconds: json['durationSeconds'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
