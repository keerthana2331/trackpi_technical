// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/dbhelper.dart';
import 'package:trackpi_technical/task_bloc.dart';
import 'package:trackpi_technical/task_event.dart';
import 'package:trackpi_technical/tasklist.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DBHelper databaseHelper = DBHelper.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (context) => TaskBloc(databaseHelper)..add(LoadTasks()),
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.montserratTextTheme(),
        ),
        home: TaskListPage(),
        // Add your routes here if needed
        // routes: {
        //   '/add-task': (context) => AddEditTaskPage(),
        //   '/edit-task': (context) => AddEditTaskPage(isEditing: true),
        // },
      ),
    );
  }
}