import 'package:bodytrack/data/models/exercise.dart';

class WorkoutTemplate {
  final String id;
  final String name;
  final Set<int> days; // дни недели
  final int duration; // длительность в минутах
  final List<Exercise> exercises;
  final DateTime createdAt;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.days,
    required this.duration,
    required this.exercises,
    required this.createdAt,
  });

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    Set<int>? days,
    int? duration,
    List<Exercise>? exercises,
    DateTime? createdAt,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      days: days ?? this.days,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'days': days.toList(),
        'duration': duration,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'],
      name: json['name'],
      days: Set<int>.from(json['days']),
      duration: json['duration'],
      exercises:
          (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
