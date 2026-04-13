// lib/models/workout_session.dart
import 'package:equatable/equatable.dart';

import 'exercise.dart';

class WorkoutSession extends Equatable {
  final String id;
  final String workoutTemplateId;
  final String workoutName;
  final DateTime date;
  final List<ExerciseSession> exercises;
  final bool isCompleted;
  final DateTime? completedAt;

  const WorkoutSession({
    required this.id,
    required this.workoutTemplateId,
    required this.workoutName,
    required this.date,
    required this.exercises,
    required this.isCompleted,
    this.completedAt,
  });

  WorkoutSession copyWith({
    String? id,
    String? workoutTemplateId,
    String? workoutName,
    DateTime? date,
    List<ExerciseSession>? exercises,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutTemplateId: workoutTemplateId ?? this.workoutTemplateId,
      workoutName: workoutName ?? this.workoutName,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workoutTemplateId': workoutTemplateId,
        'workoutName': workoutName,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutTemplateId: json['workoutTemplateId'],
      workoutName: json['workoutName'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseSession.fromJson(e))
          .toList(),
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, workoutTemplateId, date, exercises, isCompleted, completedAt];
}

class ExerciseSession extends Equatable {
  final String id;
  final String exerciseId;
  final String name;
  final ExerciseType type;
  final String? description; // 👈 Добавляем описание
  final bool isCompleted;
  final Map<String, dynamic>? result;

  const ExerciseSession({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.type,
    this.description,
    required this.isCompleted,
    this.result,
  });

  ExerciseSession copyWith({
    String? id,
    String? exerciseId,
    String? name,
    ExerciseType? type,
    String? description,
    bool? isCompleted,
    Map<String, dynamic>? result,
  }) {
    return ExerciseSession(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'name': name,
        'type': type.toString(),
        'description': description,
        'isCompleted': isCompleted,
        'result': result,
      };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      id: json['id'],
      exerciseId: json['exerciseId'],
      name: json['name'],
      type: json['type'] == 'ExerciseType.running'
          ? ExerciseType.running
          : ExerciseType.sets,
      description: json['description'],
      isCompleted: json['isCompleted'],
      result: json['result'],
    );
  }

  @override
  List<Object?> get props =>
      [id, exerciseId, name, type, description, isCompleted, result];
}
