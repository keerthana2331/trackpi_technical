import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/task.dart';
import 'package:trackpi_technical/task_bloc.dart';
import 'package:trackpi_technical/task_event.dart';
import 'package:trackpi_technical/task_state.dart';
import 'package:trackpi_technical/taskpage.dart';  // Import the AddEditTaskPage

class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskBloc = context.watch<TaskBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterDropdown(context, taskBloc),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              bloc: taskBloc,
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  return state.filteredTasks.isEmpty
                      ? _buildEmptyState(state.currentFilter)
                      : _buildTaskList(context, state.filteredTasks);
                } else if (state is TaskError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text("Unknown state"));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditPage(context, taskBloc),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, TaskBloc taskBloc) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<TaskFilter>(
        value: taskBloc.state is TaskLoaded
            ? (taskBloc.state as TaskLoaded).currentFilter
            : TaskFilter.all,
        onChanged: (TaskFilter? newFilter) {
          if (newFilter != null) {
            taskBloc.add(FilterTasks(newFilter));
          }
        },
        items: [
          DropdownMenuItem(
            value: TaskFilter.all,
            child: Text('All Tasks'),
          ),
          DropdownMenuItem(
            value: TaskFilter.completed,
            child: Text('Completed Tasks'),
          ),
          DropdownMenuItem(
            value: TaskFilter.pending,
            child: Text('Pending Tasks'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    String message = 'No tasks found';
    switch (filter) {
      case TaskFilter.completed:
        message = 'No completed tasks';
        break;
      case TaskFilter.pending:
        message = 'No pending tasks';
        break;
      default:
        message = 'No tasks found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
  return ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      final task = tasks[index];
      
      // Limit the description to a certain length, e.g., 50 characters
      String shortDescription = task.description != null && task.description!.length > 50
          ? '${task.description!.substring(0, 50)}...' // Truncate and add "..."
          : task.description ?? 'No Description';

      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: task.isCompleted ? Colors.green : Colors.red,
            child: Text(task.title[0].toUpperCase()),
          ),
          title: Text(task.title),
          subtitle: Text(shortDescription), // Use the shortened description
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToAddEditPage(context, context.read<TaskBloc>(), task: task);
              } else if (value == 'delete') {
                _confirmDelete(context, context.read<TaskBloc>(), task.id!, index);
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

  Future<void> _navigateToAddEditPage(BuildContext context, TaskBloc taskBloc, {Task? task}) async {
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
      taskBloc.add(LoadTasks());
    }
  }

  Future<void> _confirmDelete(BuildContext context, TaskBloc taskBloc, int taskId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      taskBloc.add(DeleteTask(taskId));
    }
  }

  // Add a method to show a dialog box when the user types a long message
  void _showLongMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Long Message"),
          content: Text("Your message is too long: $message"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to monitor the length of the description being typed
  void _handleTyping(BuildContext context, String input) {
    if (input.length > 100) { // Threshold of 100 characters
      _showLongMessageDialog(context, input);
    }
  }
}
