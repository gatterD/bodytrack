part of 'workout_session_bloc.dart';

abstract class WorkoutSessionEvent extends Equatable {
  const WorkoutSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkout extends WorkoutSessionEvent {
  final WorkoutTemplate template;

  const StartWorkout(this.template);

  @override
  List<Object?> get props => [template];
}

class CompleteExercise extends WorkoutSessionEvent {
  final String exerciseId;
  final Map<String, dynamic>? result;

  const CompleteExercise(this.exerciseId, {this.result});

  @override
  List<Object?> get props => [exerciseId, result];
}

class FinishWorkout extends WorkoutSessionEvent {}

class LoadWorkoutSessions extends WorkoutSessionEvent {}

class GetCompletedDaysForWeek extends WorkoutSessionEvent {
  final DateTime date;

  const GetCompletedDaysForWeek(this.date);

  @override
  List<Object?> get props => [date];
}
