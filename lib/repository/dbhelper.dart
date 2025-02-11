// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trackpi_technical/models/task.dart';

class DBHelper {
  // Singleton pattern to ensure only one instance of the DBHelper
  static final DBHelper instance = DBHelper.internal();
  factory DBHelper() => instance;
  DBHelper.internal();

  // Private variable to hold the database instance
  static Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    // If the database already exists, return it
    if (_database != null) return _database!;
    // Otherwise, initialize and return a new database instance
    _database = await initDatabase();
    return _database!;
  }

  // Initializes the database by defining the path and creating the table
  Future<Database> initDatabase() async {
    // Defining the path for the database (tasks.db)
    String path = join(await getDatabasesPath(), 'tasks.db');
    // Open the database or create it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // SQL query to create a 'tasks' table with columns id, title, description, and isCompleted
        db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }

  // Adds a new task to the database
  Future<int> addTask(Task task) async {
    // Get the reference to the database
    final db = await database;
    // Insert the task into the 'tasks' table and return the result
    return await db.insert('tasks', task.toMap());
  }

  // Fetches all tasks from the database
  Future<List<Task>> getTasks() async {
    // Get the reference to the database
    final db = await database;
    // Query all tasks from the 'tasks' table
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    // Convert the list of maps into a list of Task objects and return it
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Updates an existing task in the database
  Future<int> updateTask(Task task) async {
    // Get the reference to the database
    final db = await database;
    // Update the task in the 'tasks' table where the task id matches
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Deletes a task from the database using the task's ID
  Future<int> deleteTask(int id) async {
    // Get the reference to the database
    final db = await database;
    // Delete the task from the 'tasks' table where the id matches
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetches tasks filtered by completion status (either completed or pending)
  Future<List<Task>> getTasksByCompletionStatus(bool isCompleted) async {
    // Get the reference to the database
    final db = await database;
    // Query tasks from the 'tasks' table filtered by the completion status (1 for completed, 0 for pending)
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [isCompleted ? 1 : 0],
    );
    // Convert the list of maps into a list of Task objects and return it
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
