// lib/interface/screens/ExercisesCreationScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../../bloc/workouts/workouts_bloc.dart';
import '../../data/models/exercise.dart';
import '../widgets/ExerciseCreationDialog.dart';
import '../../core/theme/main-app-theme.dart';
import 'AppBar.dart';

class ExercisesCreationScreen extends StatelessWidget {
  const ExercisesCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BTAppBar(
        title: "Упражнения",
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => _saveAndFinish(context),
            child: Text(
              'Готово',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<WorkoutCreationBloc, WorkoutCreationState>(
        listener: (context, state) {
          if (state is WorkoutCreationSuccess) {
            context.read<WorkoutsBloc>().add(LoadWorkouts());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Тренировка успешно создана!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            );

            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          if (state is WorkoutCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
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
                    padding: const EdgeInsets.all(AppSpacing.md),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Нет добавленных упражнений',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            exercise.type == ExerciseType.running
                ? Icons.directions_run
                : Icons.fitness_center,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.description != null &&
                exercise.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  exercise.description!,
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              _getExerciseDescription(exercise),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _editExercise(context, index, exercise),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteExercise(context, index),
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
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
    final theme = Theme.of(context);

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
            child: Text(
              'Удалить',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade400,
              ),
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
          SnackBar(
            content: const Text('Добавьте хотя бы одно упражнение'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
        return;
      }

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
