// lib/bloc/workout_creation/workout_creation_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/exercise.dart';
import '../../data/models/workout_template.dart';

part 'workout_creation_event.dart';
part 'workout_creation_state.dart';

class WorkoutCreationBloc
    extends Bloc<WorkoutCreationEvent, WorkoutCreationState> {
  static const String _templatesKey = 'workout_templates';
  final _uuid = Uuid();

  WorkoutCreationBloc() : super(WorkoutCreationInitial()) {
    // 👈 Регистрируем все обработчики
    on<InitializeCreation>(_onInitialize);
    on<UpdateWorkoutName>(_onUpdateWorkoutName);
    on<UpdateWorkoutDays>(_onUpdateWorkoutDays);
    on<UpdateWorkoutDuration>(_onUpdateWorkoutDuration);
    on<AddExercise>(_onAddExercise);
    on<UpdateExercise>(_onUpdateExercise);
    on<RemoveExercise>(_onRemoveExercise);
    on<SaveWorkoutTemplate>(_onSaveWorkoutTemplate);
    on<ResetCreation>(_onResetCreation);

    // Автоматическая инициализация при создании BLoC
    add(InitializeCreation());
  }

  // 👈 Добавляем обработчик инициализации
  void _onInitialize(
    InitializeCreation event,
    Emitter<WorkoutCreationState> emit,
  ) {
    emit(WorkoutCreationInProgress(
      WorkoutTemplate(
        id: _uuid.v4(),
        name: '',
        days: {},
        duration: 30,
        exercises: [],
        createdAt: DateTime.now(),
      ),
    ));
  }

  void _onUpdateWorkoutName(
    UpdateWorkoutName event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updated = current.copyWith(name: event.name);
      emit(WorkoutCreationInProgress(updated));
    }
  }

  void _onUpdateWorkoutDays(
    UpdateWorkoutDays event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updated = current.copyWith(days: event.days);
      emit(WorkoutCreationInProgress(updated));
    }
  }

  void _onUpdateWorkoutDuration(
    UpdateWorkoutDuration event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updated = current.copyWith(duration: event.duration);
      emit(WorkoutCreationInProgress(updated));
    }
  }

  void _onAddExercise(
    AddExercise event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updated = current.copyWith(
        exercises: [...current.exercises, event.exercise],
      );
      emit(WorkoutCreationInProgress(updated));
    }
  }

  void _onUpdateExercise(
    UpdateExercise event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updatedExercises = List<Exercise>.from(current.exercises);
      updatedExercises[event.index] = event.exercise;
      final updated = current.copyWith(exercises: updatedExercises);
      emit(WorkoutCreationInProgress(updated));
    }
  }

  void _onRemoveExercise(
    RemoveExercise event,
    Emitter<WorkoutCreationState> emit,
  ) {
    if (state is WorkoutCreationInProgress) {
      final current = (state as WorkoutCreationInProgress).template;
      final updatedExercises = List<Exercise>.from(current.exercises)
        ..removeAt(event.index);
      final updated = current.copyWith(exercises: updatedExercises);
      emit(WorkoutCreationInProgress(updated));
    }
  }

  Future<void> _onSaveWorkoutTemplate(
    SaveWorkoutTemplate event,
    Emitter<WorkoutCreationState> emit,
  ) async {
    if (state is WorkoutCreationInProgress) {
      final template = (state as WorkoutCreationInProgress).template;

      // Валидация
      if (template.name.isEmpty) {
        emit(const WorkoutCreationError('Введите название тренировки'));
        return;
      }
      if (template.days.isEmpty) {
        emit(const WorkoutCreationError('Выберите дни тренировки'));
        return;
      }
      if (template.exercises.isEmpty) {
        emit(const WorkoutCreationError('Добавьте хотя бы одно упражнение'));
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final templatesJson = prefs.getString(_templatesKey);
        List<WorkoutTemplate> templates = [];

        if (templatesJson != null) {
          List<dynamic> decoded = json.decode(templatesJson);
          templates =
              decoded.map((item) => WorkoutTemplate.fromJson(item)).toList();
        }

        templates.add(template);

        await prefs.setString(
          _templatesKey,
          json.encode(templates.map((t) => t.toJson()).toList()),
        );

        emit(WorkoutCreationSuccess(template));
      } catch (e) {
        emit(WorkoutCreationError('Ошибка сохранения: $e'));
      }
    }
  }

  void _onResetCreation(
    ResetCreation event,
    Emitter<WorkoutCreationState> emit,
  ) {
    // Создаем новое состояние
    emit(WorkoutCreationInProgress(
      WorkoutTemplate(
        id: _uuid.v4(),
        name: '',
        days: {},
        duration: 30,
        exercises: [],
        createdAt: DateTime.now(),
      ),
    ));
  }
}
