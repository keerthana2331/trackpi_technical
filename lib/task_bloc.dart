import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/dbhelper.dart';
import 'package:trackpi_technical/task_event.dart';
import 'package:trackpi_technical/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DBHelper dbHelper;

  TaskBloc(this.dbHelper) : super(const TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<EditTask>(_onEditTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskStatus);
    on<FilterTasks>(_onFilterTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(const TaskLoading());
      final tasks = await dbHelper.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError("Failed to load tasks: $e"));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.addTask(event.task);
      add(LoadTasks()); // Reload tasks after adding
    } catch (e) {
      emit(TaskError("Failed to add task: $e"));
    }
  }

  Future<void> _onEditTask(EditTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.updateTask(event.task);
      add(LoadTasks()); // Reload tasks after editing
    } catch (e) {
      emit(TaskError("Failed to edit task: $e"));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.deleteTask(event.taskId);
      add(LoadTasks()); // Reload tasks after deleting
    } catch (e) {
      emit(TaskError("Failed to delete task: $e"));
    }
  }

  Future<void> _onToggleTaskStatus(
      ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      final updatedTask =
          event.task.copyWith(isCompleted: !event.task.isCompleted);
      await dbHelper.updateTask(updatedTask);
      add(LoadTasks()); // Reload tasks after toggling status
    } catch (e) {
      emit(TaskError("Failed to update task status: $e"));
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(TaskLoaded(tasks: currentState.tasks, currentFilter: event.filter));
    }
  }
}
