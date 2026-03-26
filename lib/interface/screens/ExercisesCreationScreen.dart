import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../../bloc/workouts/workouts_bloc.dart';
import '../../data/models/exercise.dart';
import '../widgets/ExerciseCreationDialog.dart';
import 'AppBar.dart';

class ExercisesCreationScreen extends StatelessWidget {
  const ExercisesCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BTAppBar(
        title: "Упражнения",
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => _saveAndFinish(context),
            child: const Text(
              'Готово',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: BlocConsumer<WorkoutCreationBloc, WorkoutCreationState>(
        listener: (context, state) {
          if (state is WorkoutCreationSuccess) {
            // Обновляем список тренировок
            context.read<WorkoutsBloc>().add(LoadWorkouts());

            // Показываем сообщение об успехе
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Тренировка успешно создана!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Возвращаемся на главную страницу
            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          if (state is WorkoutCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkoutCreationInProgress) {
            final exercises = state.template.exercises;

            if (exercises.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _buildExerciseCard(
                        context,
                        exercise,
                        index,
                      );
                    },
                  ),
                ),
                _buildAddButton(context),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет добавленных упражнений',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addExercise(context),
            icon: const Icon(Icons.add),
            label: const Text('Добавить упражнение'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(
            exercise.type == ExerciseType.running
                ? Icons.directions_run
                : Icons.fitness_center,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.description != null &&
                exercise.description!.isNotEmpty)
              Text(
                exercise.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _getExerciseDescription(exercise),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editExercise(context, index, exercise),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteExercise(context, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => _addExercise(context),
          icon: const Icon(Icons.add),
          label: const Text('Добавить упражнение'),
        ),
      ),
    );
  }

  void _addExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExerciseCreationDialog(
        onSave: (exercise) {
          context.read<WorkoutCreationBloc>().add(AddExercise(exercise));
        },
      ),
    );
  }

  void _editExercise(BuildContext context, int index, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => ExerciseCreationDialog(
        existingExercise: exercise,
        onSave: (updatedExercise) {
          context.read<WorkoutCreationBloc>().add(
                UpdateExercise(index, updatedExercise),
              );
        },
      ),
    );
  }

  void _deleteExercise(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить упражнение'),
        content: const Text('Вы уверены, что хотите удалить это упражнение?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutCreationBloc>().add(RemoveExercise(index));
              Navigator.pop(context);
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndFinish(BuildContext context) {
    final state = context.read<WorkoutCreationBloc>().state;
    if (state is WorkoutCreationInProgress) {
      if (state.template.exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте хотя бы одно упражнение')),
        );
        return;
      }

      // Сохраняем тренировку
      context.read<WorkoutCreationBloc>().add(SaveWorkoutTemplate());
    }
  }

  String _getExerciseDescription(Exercise exercise) {
    if (exercise.type == ExerciseType.running) {
      return '🏃 Дистанция: ${exercise.distance} км';
    } else {
      String desc =
          '💪 ${exercise.sets} подходов × ${exercise.repsPerSet} повторений';
      if (exercise.weight != null && exercise.weight! > 0) {
        desc += ', вес: ${exercise.weight} кг';
      }
      return desc;
    }
  }
}
