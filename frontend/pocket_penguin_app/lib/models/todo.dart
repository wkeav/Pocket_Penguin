enum TodoPriority { low, medium, high }

class Todo {
  final int id;
  final String title;
  final bool completed;
  final TodoPriority priority;
  final String? dueDate;
  final int reward;
  final String category;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    this.priority = TodoPriority.medium,
    this.dueDate,
    required this.reward,
    required this.category,
  });

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    TodoPriority? priority,
    String? dueDate,
    int? reward,
    String? category,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reward: reward ?? this.reward,
      category: category ?? this.category,
    );
  }
}

// Sample todos for initial data
class SampleTodos {
  static List<Todo> get todos => [
    Todo(
      id: 1,
      title: 'Grocery shopping',
      completed: false,
      priority: TodoPriority.medium,
      dueDate: 'Today',
      reward: 5,
      category: 'Personal',
    ),
    Todo(
      id: 2,
      title: 'Call dentist for appointment',
      completed: false,
      priority: TodoPriority.high,
      dueDate: 'Tomorrow',
      reward: 8,
      category: 'Health',
    ),
    Todo(
      id: 3,
      title: 'Finish project presentation',
      completed: true,
      priority: TodoPriority.high,
      reward: 15,
      category: 'Work',
    ),
    Todo(
      id: 4,
      title: 'Water the plants',
      completed: false,
      priority: TodoPriority.low,
      reward: 3,
      category: 'Home',
    ),
    Todo(
      id: 5,
      title: 'Plan weekend trip',
      completed: false,
      priority: TodoPriority.medium,
      dueDate: 'This week',
      reward: 10,
      category: 'Personal',
    ),
  ];
}

extension TodoPriorityExtension on TodoPriority {
  String get name {
    switch (this) {
      case TodoPriority.low:
        return 'low';
      case TodoPriority.medium:
        return 'medium';
      case TodoPriority.high:
        return 'high';
    }
  }

  ColorInfo get colorInfo {
    switch (this) {
      case TodoPriority.high:
        return ColorInfo(
          backgroundColor: const Color(0xFFFEF2F2),
          textColor: const Color(0xFF991B1B),
          borderColor: const Color(0xFFFECACA),
        );
      case TodoPriority.medium:
        return ColorInfo(
          backgroundColor: const Color(0xFFFEFCE8),
          textColor: const Color(0xFF92400E),
          borderColor: const Color(0xFFFDE68A),
        );
      case TodoPriority.low:
        return ColorInfo(
          backgroundColor: const Color(0xFFF0FDF4),
          textColor: const Color(0xFF166534),
          borderColor: const Color(0xFFBBF7D0),
        );
    }
  }
}

class ColorInfo {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  ColorInfo({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}