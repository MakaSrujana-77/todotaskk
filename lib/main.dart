// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      home: const TodoPage(),
    );
  }
}

ThemeData _lightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF84D2C8),
      brightness: Brightness.light,
      primary: const Color(0xFF84D2C8),
      secondary: const Color(0xFFF8B195),
      tertiary: const Color(0xFFA8E6CF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF84D2C8),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF84D2C8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

// ✅ Todo MODEL (matches your MongoDB backend)
class Todo {
  final String id;
  final String title;
  final String description;
  final bool isPrimary;
  final bool isDone;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isPrimary = false,
    this.isDone = false,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // ✅ YOUR IP 169.254.179.106 ADDED HERE!
  static const String baseUrl = 'http://192.168.1.7:5000';

  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ FAB click → GET all todos (YOUR IP)
  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/todos'));
    

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _todos.clear();
          _todos.addAll(jsonList.map((json) => Todo.fromJson(json)));
        });
      } else {
        _showError('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Add button → POST new todo (YOUR IP)
  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': text,
          'description': 'Task added from Flutter app',
          'isPrimary': false,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _controller.clear();
        await _loadTodos(); // Refresh list
      } else {
        _showError('Failed to add: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Add error: $e');
    }
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      // Local UI toggle (add PUT endpoint later for backend sync)
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((t) => t.id == todo.id);
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Gradient input container
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF84D2C8).withOpacity(0.1),
                  const Color(0xFFA8E6CF).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF84D2C8).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    onSubmitted: (_) => _addTodo(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          // Todo list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_download_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks from API',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap refresh button to load todos from server',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: ValueKey(todo.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade600,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (_) => _deleteTodo(todo),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: todo.isDone
                                      ? Colors.grey.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Transform.scale(
                                    scale: 0.9,
                                    child: Checkbox(
                                      value: todo.isDone,
                                      onChanged: (_) => _toggleTodo(todo),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      activeColor: const Color(0xFF84D2C8),
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    todo.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: todo.isDone
                                          ? FontWeight.w400
                                          : FontWeight.w500,
                                      decoration: todo.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: todo.isDone
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      todo.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () => _deleteTodo(todo),
                                  ),
                                  onTap: () => _toggleTodo(todo),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // ✅ FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTodos,
        backgroundColor: const Color(0xFF84D2C8),
        foregroundColor: Colors.white,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh, size: 24),
        tooltip: 'Load todos from API',
      ),
    );
  }
}
