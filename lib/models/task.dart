class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  bool isCompleted;
  final int estimatedSessions; // Estimated Pomodoro sessions (25-min each)
  final int completedSessions; // Completed Pomodoro sessions
  final int focusSeconds;      // Total focused time in seconds

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    this.estimatedSessions = 1,
    this.completedSessions = 0,
    this.focusSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'estimatedSessions': estimatedSessions,
      'completedSessions': completedSessions,
      'focusSeconds': focusSeconds,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      category: json['category'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: (json['priority'] ?? 'Medium') as String,
      isCompleted: json['isCompleted'] as bool,
      estimatedSessions: (json['estimatedSessions'] ?? 1) as int,
      completedSessions: (json['completedSessions'] ?? 0) as int,
      focusSeconds: (json['focusSeconds'] ?? 0) as int,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    int? estimatedSessions,
    int? completedSessions,
    int? focusSeconds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedSessions: estimatedSessions ?? this.estimatedSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      focusSeconds: focusSeconds ?? this.focusSeconds,
    );
  }
}
