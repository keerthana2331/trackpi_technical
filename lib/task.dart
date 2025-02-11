// task.dart - Update Task model
class Task {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted; // Add this field

  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false, // Default to false
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // Convert to integer for SQLite
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1, // Convert from integer
    );
  }
}