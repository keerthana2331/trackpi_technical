// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpi_technical/bloc/task_bloc.dart';
import 'package:trackpi_technical/bloc/task_event.dart';
import 'package:trackpi_technical/repository/dbhelper.dart';
import 'package:trackpi_technical/screens/task_list.dart';

void main() {
  // Ensures that widget bindings are initialized before the app runs
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create an instance of the DBHelper to access the local database
  final DBHelper databaseHelper = DBHelper.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      // Creating the TaskBloc with the DBHelper and taskRepository as null
      create: (context) =>
          TaskBloc(databaseHelper, taskRepository: null)..add(LoadTasks()),

      child: MaterialApp(
        // App title that appears in the app bar
        title: 'Task Manager',

        // Hide the debug banner at the top right of the app
        debugShowCheckedModeBanner: false,

        // Define the overall theme of the app
        theme: ThemeData(
          // Set primary swatch color to teal
          primarySwatch: Colors.teal,

          // Ensure adaptive density based on the platform
          visualDensity: VisualDensity.adaptivePlatformDensity,

          // Set custom text theme using Google Fonts (Montserrat)
          textTheme: GoogleFonts.montserratTextTheme(),
        ),

        // The home screen of the app is the TaskListPage widget
        home: TaskListPage(),
      ),
    );
  }
}
