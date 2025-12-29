import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; 
  static Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    }
    throw Exception('Failed to load todos');
  }

  static Future<void> addTodo(Map<String, dynamic> todoData) async {
    await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todoData),
    );
  }
}
