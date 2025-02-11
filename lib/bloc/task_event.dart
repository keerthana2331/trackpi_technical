import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/bloc/task_filter_bloc.dart';
// Ensure the import is from task_state.dart

// Event classes remain the same...

import 'package:trackpi_technical/models/task.dart';

// Base abstract class for Task events, extending Equatable to support value comparison
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to load tasks from the database
class LoadTasks extends TaskEvent {}

// Event to add a new task to the database
class AddTask extends TaskEvent {
  final Task task; // The task object to be added

  AddTask(this.task);

  @override
  List<Object> get props =>
      [task]; // Ensure that the task is part of equality comparison
}

// Event to edit an existing task in the database
class EditTask extends TaskEvent {
  final Task task; // The task object to be edited

  EditTask(this.task);

  @override
  List<Object> get props =>
      [task]; // Ensure that the task is part of equality comparison
}

// Event to delete a task from the database
class DeleteTask extends TaskEvent {
  final int taskId; // The ID of the task to be deleted

  DeleteTask(this.taskId);

  @override
  List<Object> get props =>
      [taskId]; // Ensure that task ID is part of equality comparison
}

// Event to filter tasks based on the selected filter (e.g., pending or completed tasks)
class FilterTasks extends TaskEvent {
  final TaskFilter
      filter; // The filter applied (e.g., all, completed, or pending)

  FilterTasks(this.filter);

  @override
  List<Object> get props =>
      [filter]; // Ensure that the filter is part of equality comparison
}

// Event to reset the task filter, usually to show all tasks
class ResetTaskFilter extends TaskEvent {}

// Event to toggle the completion status of a task (from completed to pending or vice versa)
class ToggleTaskCompletion extends TaskEvent {
  final Task task; // The task whose completion status is toggled
  final bool
      isCompleted; // The new completion status (true for completed, false for pending)

  ToggleTaskCompletion({
    required this.task,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [
        task,
        isCompleted
      ]; // Ensure that both task and completion status are part of equality comparison
}

// Event to show all tasks, typically used for resetting the filtered list
class ShowAllTasks extends TaskEvent {}
