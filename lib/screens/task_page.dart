// ignore_for_file: use_super_parameters, unused_local_variable, must_be_immutable, unnecessary_cast

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/bloc/task_bloc.dart';
import 'package:trackpi_technical/bloc/task_event.dart';
import 'package:trackpi_technical/bloc/task_filter_bloc.dart' as filter_bloc;
import 'package:trackpi_technical/bloc/task_state.dart' hide TaskFilter;
import 'package:trackpi_technical/models/task.dart';

class AddEditTaskPage extends StatelessWidget {
  final Task? task; // The task object, can be null if adding a new task
  final TextEditingController
      titleController; // Controller for task title input
  final TextEditingController
      descriptionController; // Controller for task description input
  filter_bloc.TaskFilter?
      completionStatus; // Completion status of the task (Pending or Completed)

  // Constructor that initializes controllers and sets completion status based on the existing task
  AddEditTaskPage({Key? key, this.task})
      : titleController = TextEditingController(text: task?.title ?? ''),
        descriptionController =
            TextEditingController(text: task?.description ?? ''),
        completionStatus = task?.isCompleted == true
            ? filter_bloc.TaskFilter.completed as filter_bloc.TaskFilter?
            : filter_bloc.TaskFilter.pending as filter_bloc.TaskFilter?,
        super(key: key);

  // Function to show a confirmation dialog before deleting a task
  Future<void> confirmDelete(BuildContext context, Task task) async {
    final taskBloc = context.read<TaskBloc>(); // Accessing the TaskBloc
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              taskBloc
                  .add(DeleteTask(task.id!)); // Dispatching delete task event
              Navigator.pop(context, true); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Task deleted successfully')), // Show confirmation message
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)), // Delete button
          ),
        ],
      ),
    );
  }

  // Function to save the task (either add a new task or update an existing one)
  void saveTask(BuildContext context) {
    final taskBloc =
        context.read<TaskBloc>(); // Accessing TaskBloc to dispatch events
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please enter a task title")), // Show an error message if title is empty
      );
      return;
    }

    // Create a new task object with the current values from the form
    final newTask = Task(
      id: task?.id, // Retain the existing task id if editing
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      isCompleted: completionStatus ==
          filter_bloc.TaskFilter.completed, // Set the completion status
    );

    // If task is null, we are adding a new task, otherwise updating an existing one
    if (task == null) {
      taskBloc.add(AddTask(newTask)); // Dispatch event to add a new task
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Task added successfully')), // Success message
      );
    } else {
      taskBloc
          .add(EditTask(newTask)); // Dispatch event to edit an existing task
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Task updated successfully')), // Success message
      );
    }
    Navigator.pop(context, true); // Pop the screen after saving the task
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      // Rebuilds the widget based on the current TaskState
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Dismiss keyboard when tapping outside
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.blue], // Gradient background
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // AppBar with title based on whether task is new or being edited
                    AppBar(
                      title: Text(task == null ? 'Add Task' : 'Edit Task'),
                      centerTitle: true,
                      backgroundColor: Colors
                          .transparent, // Transparent background for the app bar
                      elevation: 0, // Remove shadow
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(
                            context), // Navigate back to previous screen
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Input field for task title
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                    labelText: 'Task Title'),
                              ),
                              const SizedBox(height: 16),
                              // Input field for task description
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                    labelText: 'Task Description (Optional)'),
                                maxLines:
                                    3, // Allow multi-line input for description
                              ),
                              const SizedBox(height: 24),
                              // Dropdown for task completion status (Pending or Completed)
                              DropdownButtonFormField<filter_bloc.TaskFilter>(
                                value: completionStatus,
                                onChanged: (filter_bloc.TaskFilter? newValue) {
                                  // Update completion status if the dropdown value changes
                                  completionStatus =
                                      newValue as filter_bloc.TaskFilter?;
                                },
                                items: [
                                  DropdownMenuItem(
                                      value: filter_bloc.TaskFilter.pending,
                                      child: Text('Pending')),
                                  DropdownMenuItem(
                                      value: filter_bloc.TaskFilter.completed,
                                      child: Text('Completed')),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Row with Save/Update and Cancel buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => saveTask(
                                          context), // Save task when clicked
                                      child: Text(task == null
                                          ? 'Save Task'
                                          : 'Update Task'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Show Cancel button only if editing an existing task
                                  if (task != null)
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(
                                            context), // Cancel and go back
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                ],
                              ),
                              // Show the Delete Task button only if editing an existing task
                              if (task != null)
                                TextButton(
                                  onPressed: () => confirmDelete(context,
                                      task!), // Show delete confirmation dialog
                                  child: const Text('Delete Task',
                                      style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
