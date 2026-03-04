class TodoModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final int totalTimeInSeconds;
  final int remainingTimeInSeconds;
  final bool isPlaying;
  final DateTime? lastStartTime;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.totalTimeInSeconds,
    required this.remainingTimeInSeconds,
    required this.isPlaying,
    this.lastStartTime,
  });

  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    int? totalTimeInSeconds,
    int? remainingTimeInSeconds,
    bool? isPlaying,
    DateTime? lastStartTime,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
      remainingTimeInSeconds:
          remainingTimeInSeconds ?? this.remainingTimeInSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      lastStartTime: lastStartTime ?? this.lastStartTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
      'totalTimeInSeconds': totalTimeInSeconds,
      'remainingTimeInSeconds': remainingTimeInSeconds,
      'isPlaying': isPlaying,
      'lastStartTime': lastStartTime?.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map, String docId) {
    return TodoModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'TODO',
      totalTimeInSeconds: map['totalTimeInSeconds'] ?? 0,
      remainingTimeInSeconds: map['remainingTimeInSeconds'] ?? 0,
      isPlaying: map['isPlaying'] == true,
      lastStartTime: map['lastStartTime'] != null
          ? DateTime.tryParse(map['lastStartTime'])
          : null,
    );
  }
}
