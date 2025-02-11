import 'package:equatable/equatable.dart';
import 'package:trackpi_technical/task_event.dart';

enum TaskFilter { all, completed, pending }

class FilterTasks extends TaskEvent {
  final TaskFilter filter;

  FilterTasks(this.filter);

  @override
  List<Object> get props => [filter];
}
