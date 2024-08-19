import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  bool isDone;
  
  Task({required this.title, this.isDone = false});
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.add(Task(title: title));
    notifyListeners();
  }

  void updateTask(int index, String title) {
    _tasks[index].title = title;
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].isDone = !_tasks[index].isDone;
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.orange,
          hintColor: Colors.yellow,
          // ignore: deprecated_member_use
          backgroundColor: Colors.orange[50],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
          ),
        ),
        home: const TaskScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: const Column(
        children: [
          Expanded(child: TaskList()),
          TaskInput(),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isDone ? Colors.grey : Colors.black,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () {
              _showEditDialog(context, index);
            },
          ),
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => taskProvider.toggleTask(index),
            checkColor: Colors.orange,
            activeColor: Colors.yellow,
          ),
          onLongPress: () {
            taskProvider.deleteTask(index);
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final TextEditingController controller =
        TextEditingController(text: taskProvider.tasks[index].title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task', style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.orange)),
              onPressed: () {
                taskProvider.updateTask(index, controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class TaskInput extends StatelessWidget {
  const TaskInput({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter a task',
                hintStyle: const TextStyle(color: Colors.black54),
                fillColor: Colors.orange[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false)
                    .addTask(controller.text);
                controller.clear();
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
