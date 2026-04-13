// lib/bloc/workout_session/workout_session_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/workout_session.dart';
import '../../data/models/workout_template.dart';

part 'workout_session_event.dart';
part 'workout_session_state.dart';

class WorkoutSessionBloc
    extends Bloc<WorkoutSessionEvent, WorkoutSessionState> {
  static const String _sessionsKey = 'workout_sessions';
  final _uuid = Uuid();

  WorkoutSessionBloc() : super(WorkoutSessionInitial()) {
    on<StartWorkout>(_onStartWorkout);
    on<CompleteExercise>(_onCompleteExercise);
    on<FinishWorkout>(_onFinishWorkout);
    on<LoadWorkoutSessions>(_onLoadWorkoutSessions);
    on<GetCompletedDaysForWeek>(_onGetCompletedDaysForWeek);
  }

  void _onStartWorkout(
    StartWorkout event,
    Emitter<WorkoutSessionState> emit,
  ) {
    final exercises = event.template.exercises.map((exercise) {
      return ExerciseSession(
        id: _uuid.v4(),
        exerciseId: exercise.id,
        name: exercise.name,
        type: exercise.type,
        description: exercise.description,
        isCompleted: false,
      );
    }).toList();

    final session = WorkoutSession(
      id: _uuid.v4(),
      workoutTemplateId: event.template.id,
      workoutName: event.template.name,
      date: DateTime.now(),
      exercises: exercises,
      isCompleted: false,
    );

    emit(WorkoutSessionInProgress(session));
  }

  void _onCompleteExercise(
    CompleteExercise event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state is WorkoutSessionInProgress) {
      final currentSession = (state as WorkoutSessionInProgress).session;
      final updatedExercises = currentSession.exercises.map((exercise) {
        if (exercise.id == event.exerciseId) {
          return exercise.copyWith(
            isCompleted: true,
            result: event.result,
          );
        }
        return exercise;
      }).toList();

      final updatedSession = currentSession.copyWith(
        exercises: updatedExercises,
      );

      emit(WorkoutSessionInProgress(updatedSession));
    }
  }

  Future<void> _onFinishWorkout(
    FinishWorkout event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    if (state is WorkoutSessionInProgress) {
      final session = (state as WorkoutSessionInProgress).session;

      // Проверяем, все ли упражнения выполнены
      final allCompleted = session.exercises.every((e) => e.isCompleted);

      if (!allCompleted) {
        emit(const WorkoutSessionError('Выполните все упражнения'));
        return;
      }

      final completedSession = session.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      await _saveSession(completedSession);
      emit(WorkoutSessionCompleted(completedSession));
    }
  }

  Future<void> _onLoadWorkoutSessions(
    LoadWorkoutSessions event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(WorkoutSessionLoading());
    try {
      final sessions = await _loadSessions();
      final completedDays = sessions
          .where((s) => s.isCompleted && s.completedAt != null)
          .map((s) => DateTime(
              s.completedAt!.year, s.completedAt!.month, s.completedAt!.day))
          .toSet();

      emit(WorkoutSessionsLoaded(sessions, completedDays: completedDays));
    } catch (e) {
      emit(WorkoutSessionError('Ошибка загрузки: $e'));
    }
  }

  void _onGetCompletedDaysForWeek(
    GetCompletedDaysForWeek event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state is WorkoutSessionsLoaded) {
      final currentState = state as WorkoutSessionsLoaded;
      final startOfWeek = _getStartOfWeek(event.date);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final completedDaysInWeek = currentState.completedDays
          .where((day) => day.isAfter(startOfWeek) && day.isBefore(endOfWeek))
          .toSet();

      emit(WorkoutSessionsLoaded(
        currentState.sessions,
        completedDays: completedDaysInWeek,
      ));
    }
  }

  Future<List<WorkoutSession>> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);

    if (sessionsJson != null) {
      List<dynamic> decoded = json.decode(sessionsJson);
      return decoded.map((item) => WorkoutSession.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> _saveSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await _loadSessions();
    sessions.add(session);

    await prefs.setString(
      _sessionsKey,
      json.encode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    final startOfWeek = DateTime(date.year, date.month, date.day);
    return startOfWeek.subtract(Duration(days: startOfWeek.weekday - 1));
  }
}
