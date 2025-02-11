// ignore_for_file: prefer_typing_uninitialized_variables, unreachable_switch_default

import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/task.dart';

enum TaskFilter { all, completed, pending }

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;

  const TaskLoaded({
    required this.tasks,
    this.currentFilter = TaskFilter.all,
  });

  /// Getter to filter tasks based on the current filter
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

  /// Creates a new instance with updated values while keeping the rest unchanged
  TaskLoaded copyWith({
    List<Task>? tasks,
    TaskFilter? currentFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [tasks, currentFilter, filteredTasks];
}

class TaskError extends TaskState {
  final String message;
  
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationInProgress extends TaskState {
  const TaskOperationInProgress();
}
