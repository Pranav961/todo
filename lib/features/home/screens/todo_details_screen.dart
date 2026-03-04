import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_bottom_sheet.dart';

class TodoDetailsScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailsScreen({super.key, required this.todoId});

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TODO':
        return Colors.blue;
      case 'In-Progress':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todoIndex = provider.todos.indexWhere((t) => t.id == todoId);
        if (todoIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('TODO Details')),
            body: const Center(child: Text('TODO not found')),
          );
        }

        final todo = provider.todos[todoIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text('TODO Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => TodoBottomSheet(todo: todo),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    todo.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          todo.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(todo.status)),
                      ),
                      child: Text(
                        todo.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(todo.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: todo.isPlaying
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      _formatTime(todo.remainingTimeInSeconds),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: todo.isPlaying ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      context: context,
                      icon: Icons.play_arrow,
                      label: 'Start',
                      color: Colors.green,
                      isEnabled:
                          !todo.isPlaying &&
                          todo.status != 'Done' &&
                          todo.remainingTimeInSeconds > 0,
                      onPressed: () => provider.playTodo(todo.id),
                    ),
                    _buildControlButton(
                      context: context,
                      icon: Icons.pause,
                      label: 'Pause',
                      color: Colors.orange,
                      isEnabled: todo.isPlaying,
                      onPressed: () => provider.pauseTodo(todo.id),
                    ),
                    _buildControlButton(
                      context: context,
                      icon: Icons.stop,
                      label: 'Stop/Done',
                      color: Colors.red,
                      isEnabled: todo.status != 'Done',
                      onPressed: () => provider.stopTodo(todo.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.black87 : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
