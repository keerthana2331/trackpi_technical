import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/task.dart';
import 'package:trackpi_technical/task_bloc.dart';
import 'package:trackpi_technical/task_event.dart';
import 'package:trackpi_technical/task_state.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;

  const AddEditTaskPage({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late Timer _gradientTimer;
  int currentGradientIndex = 0;
  late TaskBloc _taskBloc;
  TaskFilter? _completionStatus = TaskFilter.pending;

  final List<List<Color>> gradientColors = [
    [Colors.teal, Colors.blue],
    [Colors.purple, Colors.pink],
    [Colors.orange, Colors.red],
  ];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task?.title ?? '';
    descriptionController.text = widget.task?.description ?? '';
    _completionStatus = widget.task?.isCompleted == true ? TaskFilter.completed : TaskFilter.pending;
    startGradientAnimation();
    
    // Get TaskBloc instance after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskBloc = context.read<TaskBloc>();
    });
  }

  @override
  void dispose() {
    _gradientTimer.cancel();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void startGradientAnimation() {
    _gradientTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          currentGradientIndex = (currentGradientIndex + 1) % gradientColors.length;
        });
      }
    });
  }

  Future<void> _confirmDelete() async {
    if (!mounted) return;
    
    final bool? confirm = await showDialog<bool>(context: context, builder: (BuildContext context) => AlertDialog(
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
    ));

    if (confirm == true && widget.task != null && mounted) {
      try {
        _taskBloc.add(DeleteTask(widget.task!.id!));
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted successfully')));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting task: ${e.toString()}"))
          );
        }
      }
    }
  }

  void _saveTask() {
    if (!mounted) return;

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a task title")));
      return;
    }

    try {
      final task = Task(
        id: widget.task?.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        isCompleted: _completionStatus == TaskFilter.completed,
      );

      if (widget.task == null) {
        _taskBloc.add(AddTask(task));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added successfully')));
      } else {
        _taskBloc.add(EditTask(task));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated successfully')));
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving task: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: AnimatedContainer(
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors[currentGradientIndex],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      AppBar(
                        title: Text(
                          widget.task == null ? 'Add Task' : 'Edit Task',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        centerTitle: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task == null ? 'Create New Task' : 'Update Task Details',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Task Title',
                                labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                                ),
                                prefixIcon: Icon(Icons.title, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Task Description (Optional)',
                                labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                                ),
                                prefixIcon: Icon(Icons.description, color: Colors.white),
                              ),
                              maxLines: 3,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 24),
                            // Dropdown to select task completion status
                            DropdownButtonFormField<TaskFilter>(
                              value: _completionStatus,
                              onChanged: (TaskFilter? newValue) {
                                setState(() {
                                  _completionStatus = newValue;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Task Status',
                                labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                                ),
                                prefixIcon: Icon(Icons.check_circle, color: Colors.white),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: TaskFilter.pending,
                                  child: Text('Pending', style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: TaskFilter.completed,
                                  child: Text('Completed', style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _saveTask,
                                    icon: Icon(widget.task == null ? Icons.add : Icons.update, size: 20),
                                    label: Text(widget.task == null ? 'Save Task' : 'Update Task', style: const TextStyle(fontSize: 16)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (widget.task != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                                      label: const Text('Cancel', style: TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.task != null)
                              Align(
                                alignment: Alignment.center,
                                child: TextButton.icon(
                                  onPressed: _confirmDelete,
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
