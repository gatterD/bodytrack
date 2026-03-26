import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_session/workout_session_bloc.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_session.dart';

class WorkoutExecutionScreen extends StatelessWidget {
  const WorkoutExecutionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
          builder: (context, state) {
            if (state is WorkoutSessionInProgress) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.session.workoutName),
                  Text(
                    _formatDate(state.session.date),
                    style: const TextStyle(fontSize: 12),
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
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      '$completedCount/$totalCount',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
              const SnackBar(
                content: Text('Поздравляем! Тренировка завершена! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is WorkoutSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
          return const Center(child: Text('Ошибка загрузки'));
        },
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, WorkoutSession session) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
    final isCompleted = exercise.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted ? Colors.green.shade50 : Colors.white,
      child: InkWell(
        onTap: isCompleted
            ? null
            : () => _showExerciseDialog(context, exercise, session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.shade100
                          : Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      exercise.type == ExerciseType.running
                          ? Icons.directions_run
                          : Icons.fitness_center,
                      color: isCompleted ? Colors.green : Colors.deepPurple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.black,
                          ),
                        ),
                        // 👈 Отображаем описание, если есть
                        if (exercise.description != null &&
                            exercise.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              exercise.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (isCompleted && exercise.result != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _getResultText(exercise),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
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
                      color: Colors.deepPurple,
                      size: 28,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context, WorkoutSession session) {
    final allCompleted = session.exercises.every((e) => e.isCompleted);

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
        child: ElevatedButton(
          onPressed: allCompleted
              ? () {
                  context.read<WorkoutSessionBloc>().add(FinishWorkout());
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allCompleted ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Завершить тренировку',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Map<String, dynamic> result = {};

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      exercise.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
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
                    decoration: const InputDecoration(
                      labelText: 'Дистанция (км)',
                      border: OutlineInputBorder(),
                      hintText: 'Введите пройденную дистанцию',
                    ),
                    onChanged: (value) {
                      result['distance'] = double.tryParse(value);
                    },
                  ),
                ] else ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Выполнено подходов',
                      border: OutlineInputBorder(),
                      hintText: 'Сколько подходов сделали?',
                    ),
                    onChanged: (value) {
                      result['completedSets'] = int.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Максимальный вес (кг)',
                      border: OutlineInputBorder(),
                      hintText: 'Введите использованный вес',
                    ),
                    onChanged: (value) {
                      result['maxWeight'] = double.tryParse(value);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Заметки',
                    border: OutlineInputBorder(),
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
