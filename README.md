TrackPi Technical
This is a simple Flutter-based To-Do List application using BLoC for state management and SQLite for local storage.

Getting Started
Follow these steps to set up and run the project on your local machine:

Clone the repository:

git clone <repository_url>

Navigate to the project directory:

cd trackpi_technical

Install dependencies:

Make sure you have Flutter installed on your machine. If not, you can install it from the official Flutter website: https://flutter.dev/docs/get-started/install

Then, run the following command to install the necessary dependencies:

flutter pub get

Run the app:

Make sure a device (physical or emulator) is connected and run:

flutter run
The app should now be running on your device or emulator.

Project Structure
lib/

bloc/: Contains all BLoC files for managing the state of tasks.
repository/: Manages interactions with the SQLite database.
models/: Defines data models like Task and TaskFilter.
screens/: Contains UI files like AddEditTaskPage and HomePage.
assets/: Contains any images or other static files used in the app.
test/: Contains unit tests for BLoC and repository.

Functionality
Add a Task: You can add new tasks with a title, description, and completion status (Pending/Completed).
Edit a Task: Edit an existing task's details.
Delete a Task: Remove a task from the list.
Mark a Task as Completed: Toggle the completion status of a task.
Filter Tasks: Filter tasks based on their completion status (Pending/Completed).