import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/task.dart';
import 'package:trackpi_technical/task_state.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class EditTask extends TaskEvent {
  final Task task;
  EditTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int taskId;
  DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class FilterTasks extends TaskEvent {
  final TaskFilter filter;
  FilterTasks(this.filter);

  @override
  List<Object> get props => [filter];
}

class ResetTaskFilter extends TaskEvent {}

class ToggleTaskCompletion extends TaskEvent {
  final Task task;
  final bool isCompleted;
  
  ToggleTaskCompletion({
    required this.task,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [task, isCompleted];
}

class ShowAllTasks extends TaskEvent {}
