// Import necessary packages and dependencies
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/bloc/task_filter_bloc.dart'
    as filterBloc; // Importing task filter
import 'package:trackpi_technical/bloc/task_state.dart'; // Correct state import
import 'package:trackpi_technical/bloc/task_event.dart'; // Importing task events
import 'package:trackpi_technical/models/task.dart'; // Importing Task model
import 'package:trackpi_technical/repository/dbhelper.dart'; // Database helper for CRUD operations

// Bloc class responsible for managing task states
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DBHelper dbHelper; // Database helper instance

  // Constructor initializing Bloc with event handlers
  TaskBloc(this.dbHelper, {required taskRepository})
      : super(const TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<EditTask>(_onEditTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskStatus);
    on<FilterTasks>(_onFilterTasks); // Filtering tasks based on user selection
  }

  // Function to handle task loading
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(const TaskLoading()); // Emit loading state while fetching data
      final tasks = await dbHelper.getTasks(); // Fetch tasks from database
      emit(TaskLoaded(
          tasks: tasks, filteredTasks: tasks)); // Load tasks successfully
    } catch (e) {
      emit(TaskError(
          "Failed to load tasks: $e")); // Emit error state if fetching fails
    }
  }

  // Function to handle adding a new task
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.addTask(event.task); // Add task to database
      add(LoadTasks()); // Reload tasks after adding
    } catch (e) {
      emit(TaskError("Failed to add task: $e")); // Handle error if adding fails
    }
  }

  // Function to handle editing an existing task
  Future<void> _onEditTask(EditTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.updateTask(event.task); // Update task in database
      add(LoadTasks()); // Reload tasks after editing
    } catch (e) {
      emit(TaskError(
          "Failed to edit task: $e")); // Handle error if updating fails
    }
  }

  // Function to handle deleting a task
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await dbHelper.deleteTask(event.taskId); // Delete task from database
      add(LoadTasks()); // Reload tasks after deletion
    } catch (e) {
      emit(TaskError(
          "Failed to delete task: $e")); // Handle error if deletion fails
    }
  }

  // Function to handle toggling task completion status
  Future<void> _onToggleTaskStatus(
      ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      // Toggle the completion status of the task
      final updatedTask =
          event.task.copyWith(isCompleted: !event.task.isCompleted);
      await dbHelper.updateTask(updatedTask); // Update the task in database
      add(LoadTasks()); // Reload tasks after toggling status
    } catch (e) {
      emit(TaskError(
          "Failed to update task status: $e")); // Handle error if update fails
    }
  }

  // Function to handle filtering tasks based on the selected filter type
  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded; // Get the current loaded state
      final allTasks = currentState.tasks; // All tasks

      // Filter the tasks based on the selected filter
      List<Task> filteredTasks;
      if (event.filter == filterBloc.TaskFilter.all) {
        filteredTasks = allTasks; // Show all tasks
      } else if (event.filter == filterBloc.TaskFilter.completed) {
        filteredTasks = allTasks
            .where((task) => task.isCompleted)
            .toList(); // Show completed tasks
      } else {
        filteredTasks = allTasks
            .where((task) => !task.isCompleted)
            .toList(); // Show pending tasks
      }

      // Emit the new state with the filtered tasks
      emit(TaskLoaded(
        tasks: allTasks, // Keep all tasks in the state
        filteredTasks: filteredTasks, // Update the filtered list
        currentFilter: event.filter, // Store the selected filter
      ));
    }
  }
}
