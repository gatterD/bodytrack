part of 'workout_creation_bloc.dart';

abstract class WorkoutCreationState extends Equatable {
  const WorkoutCreationState();

  @override
  List<Object?> get props => [];
}

class WorkoutCreationInitial extends WorkoutCreationState {}

class WorkoutCreationInProgress extends WorkoutCreationState {
  final WorkoutTemplate template;

  const WorkoutCreationInProgress(this.template);

  @override
  List<Object?> get props => [template];
}

class WorkoutCreationSuccess extends WorkoutCreationState {
  final WorkoutTemplate template;

  const WorkoutCreationSuccess(this.template);

  @override
  List<Object?> get props => [template];
}

class WorkoutCreationError extends WorkoutCreationState {
  final String message;

  const WorkoutCreationError(this.message);

  @override
  List<Object?> get props => [message];
}
