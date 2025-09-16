import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';

class TodoScreen extends StatefulWidget {
  final int fishCoins;
  final Function(int) onFishCoinsChanged;

  const TodoScreen({
    super.key,
    required this.fishCoins,
    required this.onFishCoinsChanged,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = SampleTodos.todos;
  final TextEditingController _newTodoController = TextEditingController();

  void _toggleTodo(int id) {
    setState(() {
      final todoIndex = todos.indexWhere((t) => t.id == id);
      if (todoIndex != -1) {
        final todo = todos[todoIndex];
        final updatedTodo = todo.copyWith(completed: !todo.completed);

        if (!todo.completed && updatedTodo.completed) {
          // Completing a todo - give reward
          widget.onFishCoinsChanged(widget.fishCoins + todo.reward);
        } else if (todo.completed && !updatedTodo.completed) {
          // Uncompleting a todo - remove reward
          widget.onFishCoinsChanged((widget.fishCoins - todo.reward)
              .clamp(0, double.infinity)
              .toInt());
        }

        todos[todoIndex] = updatedTodo;
      }
    });
  }

  void _addTodo() {
    if (_newTodoController.text.trim().isNotEmpty) {
      setState(() {
        todos.add(Todo(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _newTodoController.text.trim(),
          reward: 5,
          category: 'Personal',
        ));
        _newTodoController.clear();
      });
    }
  }

  void _deleteTodo(int id) {
    setState(() {
      todos.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = todos.where((t) => t.completed).length;
    final totalCount = todos.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Stats
          ArcticCard(
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            child: Column(
              children: [
                const Text(
                  'Todo List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount/$totalCount tasks completed',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3730A3),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Remaining',
                        '${totalCount - completedCount}', Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        'Completed', '$completedCount', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add New Todo
          ArcticCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTodoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Todos List
          ...todos.map((todo) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTodoCard(todo),
              )),

          if (todos.isEmpty)
            ArcticCard(
              child: Column(
                children: [
                  const Icon(Icons.pets, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No todos yet! Add your first task above.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Quick Add Templates
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Buy groceries',
                    'Exercise',
                    'Call family',
                    'Clean room',
                  ].map((template) => _buildQuickAddButton(template)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(Todo todo) {
    final colorInfo = todo.priority.colorInfo;

    return ArcticCard(
      backgroundColor: todo.completed ? Colors.grey[50] : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: todo.completed,
            onChanged: (_) => _toggleTodo(todo.id),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: todo.completed
                              ? Colors.grey[500]
                              : Colors.grey[900],
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PenguinBadge(
                      text: '${todo.reward}',
                      icon: Icons.catching_pokemon,
                      backgroundColor: Colors.amber[100],
                      textColor: Colors.amber[800],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => _deleteTodo(todo.id),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[500],
                      iconSize: 16,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    PenguinBadge(
                      text: todo.priority.name,
                      icon: Icons.flag,
                      backgroundColor: colorInfo.backgroundColor,
                      textColor: colorInfo.textColor,
                    ),
                    PenguinBadge(
                      text: todo.category,
                      backgroundColor: Colors.grey[100],
                    ),
                    if (todo.dueDate != null)
                      PenguinBadge(
                        text: todo.dueDate!,
                        icon: Icons.calendar_today,
                        backgroundColor: Colors.blue[50],
                        textColor: Colors.blue[600],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String template) {
    return InkWell(
      onTap: () {
        _newTodoController.text = template;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          template,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue[600],
          ),
        ),
      ),
    );
  }
}
