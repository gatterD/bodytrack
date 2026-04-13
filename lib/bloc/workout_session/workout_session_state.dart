// lib/bloc/workout_session/workout_session_state.dart
part of 'workout_session_bloc.dart';

abstract class WorkoutSessionState extends Equatable {
  const WorkoutSessionState();

  @override
  List<Object?> get props => [];
}

class WorkoutSessionInitial extends WorkoutSessionState {}

class WorkoutSessionLoading extends WorkoutSessionState {}

class WorkoutSessionInProgress extends WorkoutSessionState {
  final WorkoutSession session;

  const WorkoutSessionInProgress(this.session);

  @override
  List<Object?> get props => [session];
}

class WorkoutSessionCompleted extends WorkoutSessionState {
  final WorkoutSession session;

  const WorkoutSessionCompleted(this.session);

  @override
  List<Object?> get props => [session];
}

class WorkoutSessionsLoaded extends WorkoutSessionState {
  final List<WorkoutSession> sessions;
  final Set<DateTime> completedDays;

  const WorkoutSessionsLoaded(this.sessions, {required this.completedDays});

  @override
  List<Object?> get props => [sessions, completedDays];
}

class WorkoutSessionError extends WorkoutSessionState {
  final String message;

  const WorkoutSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
