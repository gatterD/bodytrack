// lib/bloc/workouts/workouts_state.dart
part of 'workouts_bloc.dart';

abstract class WorkoutsState extends Equatable {
  const WorkoutsState();

  @override
  List<Object?> get props => [];
}

class WorkoutsInitial extends WorkoutsState {}

class WorkoutsLoading extends WorkoutsState {}

class WorkoutsLoaded extends WorkoutsState {
  final List<WorkoutTemplate> workouts;

  const WorkoutsLoaded(this.workouts);

  @override
  List<Object?> get props => [workouts];
}

class WorkoutsError extends WorkoutsState {
  final String message;

  const WorkoutsError(this.message);

  @override
  List<Object?> get props => [message];
}
