import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';
import 'package:todo/services/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todos = [];
  Timer? _timer;
  String _searchQuery = '';
  StreamSubscription? _subscription;

  List<TodoModel> get todos {
    if (_searchQuery.isEmpty) return _todos;
    return _todos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  TodoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _loadTodos();
    });
    _startTimer();
  }

  void _loadTodos() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _todos = [];
      notifyListeners();
      return;
    }

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('todos')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          _todos = snapshot.docs
              .map((doc) => TodoModel.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool hasChanges = false;
      final now = DateTime.now();

      for (int i = 0; i < _todos.length; i++) {
        var todo = _todos[i];
        if (todo.isPlaying && todo.lastStartTime != null) {
          final diff = now.difference(todo.lastStartTime!).inSeconds;
          if (diff >= 1) {
            final newRemaining = todo.remainingTimeInSeconds - diff;

            if (newRemaining <= 0) {
              _todos[i] = todo.copyWith(
                status: "Done",
                remainingTimeInSeconds: 0,
                isPlaying: false,
                lastStartTime: null,
              );
              _updateToFirestore(_todos[i]);
              NotificationService().showNotification(
                id: _todos[i].id.hashCode,
                title: 'Todo Completed',
                body: '${_todos[i].title} is now Done!',
              );
            } else {
              _todos[i] = todo.copyWith(
                remainingTimeInSeconds: newRemaining,
                lastStartTime: todo.lastStartTime!.add(Duration(seconds: diff)),
              );
            }
            hasChanges = true;
          }
        }
      }

      if (hasChanges) {
        notifyListeners();
      }
    });
  }

  Future<void> _updateToFirestore(TodoModel todo) async {
    await FirebaseFirestore.instance
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap());
  }

  void searchTodos(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTodo(
    String title,
    String description,
    int totalTimeInSeconds,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('todos').doc();

    final todo = TodoModel(
      id: docRef.id,
      userId: user.uid,
      title: title,
      description: description,
      status: "TODO",
      totalTimeInSeconds: totalTimeInSeconds,
      remainingTimeInSeconds: totalTimeInSeconds,
      isPlaying: false,
    );

    await docRef.set(todo.toMap());
  }

  Future<void> updateTodoData(
    String id,
    String title,
    String description,
    int totalTimeInSeconds,
  ) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _todos[index];
      final todo = old.copyWith(
        title: title,
        description: description,
        totalTimeInSeconds: totalTimeInSeconds,
        remainingTimeInSeconds: totalTimeInSeconds,
        status: "TODO",
        isPlaying: false,
      );
      await _updateToFirestore(todo);
    }
  }

  Future<void> deleteTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
  }

  Future<void> playTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      var todo = _todos[index];
      if (todo.status == 'Done') return;

      todo = todo.copyWith(
        isPlaying: true,
        status: "In-Progress",
        lastStartTime: DateTime.now(),
      );
      await _updateToFirestore(todo);
      NotificationService().showNotification(
        id: todo.id.hashCode,
        title: 'Todo Started',
        body: '${todo.title} is now In-Progress!',
      );
    }
  }

  Future<void> pauseTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final now = DateTime.now();
      var todo = _todos[index];

      if (todo.isPlaying && todo.lastStartTime != null) {
        final diff = now.difference(todo.lastStartTime!).inSeconds;
        int newRemaining = todo.remainingTimeInSeconds - diff;
        if (newRemaining < 0) newRemaining = 0;

        todo = todo.copyWith(
          isPlaying: false,
          remainingTimeInSeconds: newRemaining,
          status: "In-Progress",
          lastStartTime: null,
        );
      } else {
        todo = todo.copyWith(isPlaying: false, status: "In-Progress");
      }

      await _updateToFirestore(todo);
      NotificationService().showNotification(
        id: todo.id.hashCode,
        title: 'Todo Paused',
        body: '${todo.title} is paused.',
      );
    }
  }

  Future<void> stopTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      var todo = _todos[index];
      todo = todo.copyWith(
        isPlaying: false,
        status: "Done",
        remainingTimeInSeconds: 0,
        lastStartTime: null,
      );
      await _updateToFirestore(todo);
      NotificationService().showNotification(
        id: todo.id.hashCode,
        title: 'Todo Stopped & Done',
        body: '${todo.title} has been marked as Done.',
      );
    }
  }

  void reloadAfterAuth() {
    _loadTodos();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
