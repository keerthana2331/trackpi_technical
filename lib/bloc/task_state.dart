// ignore_for_file: prefer_typing_uninitialized_variables, unreachable_switch_default

import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/bloc/task_filter_bloc.dart';
import 'package:trackpi_technical/models/task.dart';

// Ensure TaskFilter is only defined here if it's not elsewhere
// enum TaskFilter { all, completed, pending }

// Abstract class for representing the base TaskState
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => []; // Default equality comparison
}

// State representing that tasks are being loaded
class TaskLoading extends TaskState {
  const TaskLoading();
}

// State representing that tasks have been successfully loaded
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;

  const TaskLoaded({
    required this.tasks,
    this.currentFilter = TaskFilter.all,
    required List<Task> filteredTasks,
  });

  // Filtered task list based on the current filter
  List<Task> get filteredTasks {
    switch (currentFilter) {
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  }

  // Returns a copy with updated properties
  TaskLoaded copyWith({
    List<Task>? tasks,
    TaskFilter? currentFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
      filteredTasks: [],
    );
  }

  @override
  List<Object?> get props =>
      [tasks, currentFilter]; // Excluded filteredTasks for performance
}

// State representing an error occurred while processing tasks
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// State representing a successful task operation
class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// State representing a task operation in progress
class TaskOperationInProgress extends TaskState {
  const TaskOperationInProgress();
}
