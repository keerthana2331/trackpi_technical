// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/bloc/task_event.dart';

// Enum to define the available task filters
enum TaskFilter { all, completed, pending }

// Event class to filter tasks based on the selected filter
class FilterTasks extends TaskEvent {
  final TaskFilter filter;

  // Constructor to initialize the filter
  FilterTasks(this.filter);

  @override
  List<Object> get props =>
      [filter]; // Ensures filter is part of equality comparison
}
