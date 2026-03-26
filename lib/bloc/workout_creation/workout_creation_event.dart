// lib/bloc/workout_creation/workout_creation_event.dart
part of 'workout_creation_bloc.dart';

abstract class WorkoutCreationEvent extends Equatable {
  const WorkoutCreationEvent();

  @override
  List<Object?> get props => [];
}

// 👈 Добавляем событие инициализации
class InitializeCreation extends WorkoutCreationEvent {}

class UpdateWorkoutName extends WorkoutCreationEvent {
  final String name;

  const UpdateWorkoutName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateWorkoutDays extends WorkoutCreationEvent {
  final Set<int> days;

  const UpdateWorkoutDays(this.days);

  @override
  List<Object?> get props => [days];
}

class UpdateWorkoutDuration extends WorkoutCreationEvent {
  final int duration;

  const UpdateWorkoutDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class AddExercise extends WorkoutCreationEvent {
  final Exercise exercise;

  const AddExercise(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class UpdateExercise extends WorkoutCreationEvent {
  final int index;
  final Exercise exercise;

  const UpdateExercise(this.index, this.exercise);

  @override
  List<Object?> get props => [index, exercise];
}

class RemoveExercise extends WorkoutCreationEvent {
  final int index;

  const RemoveExercise(this.index);

  @override
  List<Object?> get props => [index];
}

class SaveWorkoutTemplate extends WorkoutCreationEvent {}

class ResetCreation extends WorkoutCreationEvent {}
