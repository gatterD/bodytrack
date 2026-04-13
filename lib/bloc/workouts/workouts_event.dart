part of 'workouts_bloc.dart';

abstract class WorkoutsEvent extends Equatable {
  const WorkoutsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutsEvent {}

class AddWorkout extends WorkoutsEvent {
  final WorkoutTemplate workout;

  const AddWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

class DeleteWorkout extends WorkoutsEvent {
  final String workoutId;

  const DeleteWorkout(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}
