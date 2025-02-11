// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/bloc/task_bloc.dart';
import 'package:trackpi_technical/bloc/task_event.dart';
import 'package:trackpi_technical/bloc/task_filter_bloc.dart' as filterBloc;
import 'package:trackpi_technical/bloc/task_state.dart';
import 'package:trackpi_technical/models/task.dart';
import 'package:trackpi_technical/screens/task_page.dart';

// This widget represents the task list page
class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskBloc =
        context.watch<TaskBloc>(); // Watches the current state of TaskBloc

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          buildFilterDropdown(context, taskBloc), // Builds the filter dropdown
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              // Listen for changes in TaskBloc's state
              bloc: taskBloc,
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Shows loading spinner when state is TaskLoading
                } else if (state is TaskLoaded) {
                  return state.filteredTasks.isEmpty
                      ? buildEmptyState(state.currentFilter as filterBloc
                          .TaskFilter) // Show empty state if there are no tasks
                      : buildTaskList(
                          context,
                          state
                              .filteredTasks); // Show the task list if tasks are available
                } else if (state is TaskError) {
                  return Center(
                      child: Text(state
                          .message)); // Display error message if TaskError state
                }
                return const Center(
                    child: Text(
                        "Unknown state")); // Default fallback if state is unknown
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddEditPage(context,
            taskBloc), // Navigate to Add/Edit task page on button press
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Builds the filter dropdown for task states (All, Completed, Pending)
  Widget buildFilterDropdown(BuildContext context, TaskBloc taskBloc) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<filterBloc.TaskFilter>(
        value: taskBloc.state is TaskLoaded
            ? (taskBloc.state as TaskLoaded).currentFilter
                as filterBloc.TaskFilter? // Get current filter from the state
            : filterBloc.TaskFilter.all as filterBloc
                .TaskFilter?, // Default to "all" if no state is loaded
        onChanged: (filterBloc.TaskFilter? newFilter) {
          if (newFilter != null) {
            context
                .read<TaskBloc>()
                .add(FilterTasks(newFilter)); // Ensure correct event is added
          }
        },

        items: [
          DropdownMenuItem(
            value: filterBloc.TaskFilter.all,
            child: Text('All Tasks',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          DropdownMenuItem(
            value: filterBloc.TaskFilter.completed,
            child: Text('Completed Tasks',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          DropdownMenuItem(
            value: filterBloc.TaskFilter.pending,
            child: Text('Pending Tasks',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Displays a message when no tasks are available
  Widget buildEmptyState(filterBloc.TaskFilter filter) {
    String message = 'No tasks found';
    switch (filter) {
      case filterBloc.TaskFilter.completed:
        message = 'No completed tasks'; // Custom message for completed tasks
        break;
      case filterBloc.TaskFilter.pending:
        message = 'No pending tasks'; // Custom message for pending tasks
        break;
      default:
        message = 'No tasks found'; // Default message for no tasks
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task,
              size: 100, color: Colors.grey), // Icon indicating no tasks
          SizedBox(height: 16),
          Text(message,
              style:
                  TextStyle(fontSize: 18, color: Colors.grey)), // Message text
        ],
      ),
    );
  }

  // Builds the task list view with each task displayed in a card
  Widget buildTaskList(BuildContext context, List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        String shortDescription = task.description != null &&
                task.description!.length > 50
            ? '${task.description!.substring(0, 50)}...' // Shortens description if it's too long
            : task.description ??
                'No Description'; // Fallback text if no description

        return Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: task.isCompleted
                  ? Colors.green
                  : Colors.red, // Green if completed, Red if not
              child: Icon(
                task.isCompleted ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(task.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(shortDescription, style: TextStyle(fontSize: 14)),
            trailing: PopupMenuButton<String>(
              // Options menu for edit and delete actions
              onSelected: (value) {
                if (value == 'edit') {
                  navigateToAddEditPage(context, context.read<TaskBloc>(),
                      task: task); // Navigate to edit task
                } else if (value == 'delete') {
                  confirmDelete(context, context.read<TaskBloc>(), task.id!,
                      index); // Confirm delete task
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigates to the add/edit task page and updates the list if the task is saved
  Future<void> navigateToAddEditPage(BuildContext context, TaskBloc taskBloc,
      {Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: taskBloc,
          child: AddEditTaskPage(task: task),
        ),
      ),
    );

    if (result == true) {
      taskBloc.add(LoadTasks()); // Reload tasks after task is saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task saved successfully")),
      );
    }
  }

  // Confirms the deletion of a task and deletes if confirmed
  Future<void> confirmDelete(
      BuildContext context, TaskBloc taskBloc, int taskId, int index) async {
    final confirm = await showDialog<bool>(
      // Show confirmation dialog
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel deletion
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm deletion
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        taskBloc.add(DeleteTask(taskId)); // Dispatch delete event to TaskBloc
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting task: ${e.toString()}")),
        );
      }
    }
  }
}
