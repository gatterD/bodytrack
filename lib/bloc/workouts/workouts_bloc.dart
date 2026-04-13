// lib/bloc/workouts/workouts_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/workout_template.dart';

part 'workouts_event.dart';
part 'workouts_state.dart';

class WorkoutsBloc extends Bloc<WorkoutsEvent, WorkoutsState> {
  static const String _templatesKey = 'workout_templates';

  WorkoutsBloc() : super(WorkoutsInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<AddWorkout>(_onAddWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(WorkoutsLoading());
    try {
      final workouts = await _loadWorkouts();
      emit(WorkoutsLoaded(workouts));
    } catch (e) {
      emit(WorkoutsError('Ошибка загрузки тренировок: $e'));
    }
  }

  Future<void> _onAddWorkout(
    AddWorkout event,
    Emitter<WorkoutsState> emit,
  ) async {
    if (state is WorkoutsLoaded) {
      final currentState = state as WorkoutsLoaded;
      final updatedWorkouts = List<WorkoutTemplate>.from(currentState.workouts)
        ..add(event.workout);

      await _saveWorkouts(updatedWorkouts);
      emit(WorkoutsLoaded(updatedWorkouts));
    } else {
      // Если состояние не загружено, просто сохраняем
      final workouts = await _loadWorkouts();
      workouts.add(event.workout);
      await _saveWorkouts(workouts);
      emit(WorkoutsLoaded(workouts));
    }
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkout event,
    Emitter<WorkoutsState> emit,
  ) async {
    if (state is WorkoutsLoaded) {
      final currentState = state as WorkoutsLoaded;
      final updatedWorkouts = currentState.workouts
          .where((workout) => workout.id != event.workoutId)
          .toList();

      await _saveWorkouts(updatedWorkouts);
      emit(WorkoutsLoaded(updatedWorkouts));
    }
  }

  Future<List<WorkoutTemplate>> _loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_templatesKey);

    if (templatesJson != null) {
      List<dynamic> decoded = json.decode(templatesJson);
      return decoded.map((item) => WorkoutTemplate.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> _saveWorkouts(List<WorkoutTemplate> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _templatesKey,
      json.encode(workouts.map((t) => t.toJson()).toList()),
    );
  }
}
