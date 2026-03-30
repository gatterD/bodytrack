// lib/interface/screens/WorkoutExecutionScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_session/workout_session_bloc.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_session.dart';
import '../../core/theme/main-app-theme.dart';
import 'AppBar.dart';

class WorkoutExecutionScreen extends StatelessWidget {
  const WorkoutExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BTAppBar(
        title: '',
        showBackButton: true,
        centerTitle: false,
        customTitle: BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
          builder: (context, state) {
            if (state is WorkoutSessionInProgress) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.session.workoutName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _formatDate(state.session.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }
            return const Text('Тренировка');
          },
        ),
        actions: [
          BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
            builder: (context, state) {
              if (state is WorkoutSessionInProgress) {
                final completedCount =
                    state.session.exercises.where((e) => e.isCompleted).length;
                final totalCount = state.session.exercises.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      '$completedCount/$totalCount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          if (state is WorkoutSessionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Поздравляем! Тренировка завершена! 🎉'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is WorkoutSessionError) {
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
          if (state is WorkoutSessionInProgress) {
            return _buildWorkoutContent(context, state.session);
          }
          if (state is WorkoutSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, WorkoutSession session) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: session.exercises.length,
            itemBuilder: (context, index) {
              final exercise = session.exercises[index];
              return _buildExerciseCard(context, exercise, session);
            },
          ),
        ),
        _buildFinishButton(context, session),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ExerciseSession exercise,
    WorkoutSession session,
  ) {
    final theme = Theme.of(context);
    final isCompleted = exercise.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isCompleted ? Colors.green.shade50 : theme.cardTheme.color,
      child: InkWell(
        onTap: isCompleted
            ? null
            : () => _showExerciseDialog(context, exercise, session),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade100
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  exercise.type == ExerciseType.running
                      ? Icons.directions_run
                      : Icons.fitness_center,
                  color: isCompleted ? Colors.green : theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? Colors.green.shade700
                            : Colors.black87,
                      ),
                    ),
                    if (exercise.description != null &&
                        exercise.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          exercise.description!,
                          style: theme.textTheme.labelMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (isCompleted && exercise.result != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          _getResultText(exercise),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 28,
                )
              else
                Icon(
                  Icons.play_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context, WorkoutSession session) {
    final theme = Theme.of(context);
    final allCompleted = session.exercises.every((e) => e.isCompleted);

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
        child: ElevatedButton(
          onPressed: allCompleted
              ? () => context.read<WorkoutSessionBloc>().add(FinishWorkout())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allCompleted ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
          child: Text(
            'Завершить тренировку',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showExerciseDialog(
    BuildContext context,
    ExerciseSession exercise,
    WorkoutSession session,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Map<String, dynamic> result = {};

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.titleLarge,
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      exercise.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (exercise.type == ExerciseType.running) ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Дистанция (км)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      hintText: 'Введите пройденную дистанцию',
                    ),
                    onChanged: (value) {
                      result['distance'] = double.tryParse(value);
                    },
                  ),
                ] else ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Выполнено подходов',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      hintText: 'Сколько подходов сделали?',
                    ),
                    onChanged: (value) {
                      result['completedSets'] = int.tryParse(value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Максимальный вес (кг)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      hintText: 'Введите использованный вес',
                    ),
                    onChanged: (value) {
                      result['maxWeight'] = double.tryParse(value);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Заметки',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    hintText: 'Дополнительные заметки о выполнении',
                  ),
                  onChanged: (value) {
                    result['notes'] = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<WorkoutSessionBloc>().add(
                        CompleteExercise(exercise.id, result: result),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Выполнено'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getResultText(ExerciseSession exercise) {
    if (exercise.type == ExerciseType.running && exercise.result != null) {
      final distance = exercise.result!['distance'];
      return '🏃 Дистанция: ${distance?.toStringAsFixed(1)} км';
    } else if (exercise.type == ExerciseType.sets && exercise.result != null) {
      final sets = exercise.result!['completedSets'];
      final weight = exercise.result!['maxWeight'];
      return '💪 Выполнено: $sets подходов${weight != null ? ', вес: $weight кг' : ''}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
