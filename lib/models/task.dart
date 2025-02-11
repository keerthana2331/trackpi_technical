// Task class to represent a task object with properties like id, title, description, and completion status
class Task {
  final int?
      id; // Unique identifier for the task (optional, used for updating and deleting)
  final String title; // Title of the task (required)
  final String? description; // Description of the task (optional)
  final bool isCompleted; // Completion status of the task (default is false)

  // Constructor for initializing a Task object
  Task({
    this.id, // Optional id (can be null if the task is newly created)
    required this.title, // Required title for the task
    this.description, // Optional description
    this.isCompleted = false, // Default to false (task is not completed)
  });

  // copyWith method to create a copy of a Task with updated properties
  Task copyWith({
    int? id, // New id value (optional)
    String? title, // New title value (optional)
    String? description, // New description value (optional)
    bool? isCompleted, // New completion status (optional)
  }) {
    return Task(
      id: id ?? this.id, // If id is not provided, retain the current id
      title: title ??
          this.title, // If title is not provided, retain the current title
      description: description ??
          this.description, // If description is not provided, retain the current description
      isCompleted: isCompleted ??
          this.isCompleted, // If isCompleted is not provided, retain the current status
    );
  }

  // Method to convert the Task object into a Map (for storing in the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Map id to the corresponding column in the database
      'title': title, // Map title to the corresponding column in the database
      'description':
          description, // Map description to the corresponding column in the database
      'isCompleted': isCompleted
          ? 1
          : 0, // Convert isCompleted to integer (1 for true, 0 for false)
    };
  }

  // Factory constructor to create a Task object from a Map (for retrieving from the database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'], // Extract id from the map
      title: map['title'], // Extract title from the map
      description: map['description'], // Extract description from the map
      isCompleted: map['isCompleted'] ==
          1, // Convert isCompleted from integer (1 or 0) to boolean
    );
  }
}
