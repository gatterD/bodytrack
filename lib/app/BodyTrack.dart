// lib/interface/screens/BodyTrack.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/exercise.dart';
import '../data/models/workout_session.dart';
import '../data/models/workout_template.dart';
import '../interface/screens/AppBar.dart';
import '../interface/screens/WorkoutExecutionScreen.dart';
import '../../bloc/workouts/workouts_bloc.dart';
import '../../bloc/workout_session/workout_session_bloc.dart';
import '../../core/theme/main-app-theme.dart';

class BodyTrack extends StatefulWidget {
  const BodyTrack({super.key, required this.title});

  final String title;

  @override
  State<BodyTrack> createState() => _BodyTrackState();
}

class _BodyTrackState extends State<BodyTrack> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<WorkoutsBloc>().add(LoadWorkouts());
    context.read<WorkoutSessionBloc>().add(LoadWorkoutSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BTAppBar(title: widget.title),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: _buildWorkoutsList(),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<WorkoutsBloc, WorkoutsState>(
        builder: (context, state) {
          if (state is WorkoutsLoaded && state.workouts.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () async {
                final result =
                    await Navigator.of(context).pushNamed('/new_track');
                if (result == true) {
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCalendar() {
    final theme = Theme.of(context);

    return BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
      builder: (context, state) {
        if (state is WorkoutSessionsLoaded) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeWeek(-1),
                    ),
                    Text(
                      _getCurrentWeekText(),
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeWeek(1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayName = _getDayName(index);
                    final date = _getDateForWeekday(index);

                    final completedSessions = state.sessions
                        .where((session) =>
                            session.isCompleted &&
                            session.completedAt != null &&
                            session.completedAt!.year == date.year &&
                            session.completedAt!.month == date.month &&
                            session.completedAt!.day == date.day)
                        .toList();

                    final isCompleted = completedSessions.isNotEmpty;

                    return GestureDetector(
                      onTap: () {
                        if (completedSessions.isNotEmpty) {
                          _showCompletedWorkouts(completedSessions);
                        }
                      },
                      child: _buildDayCell(
                        dayName,
                        date.day.toString(),
                        isCompleted,
                        completedSessions.length,
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDayCell(
    String dayName,
    String dayNumber,
    bool isCompleted,
    int workoutCount,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 45,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dayNumber,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isCompleted ? Colors.green.shade700 : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (workoutCount > 0)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Text(
                '$workoutCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList() {
    return BlocBuilder<WorkoutsBloc, WorkoutsState>(
      builder: (context, state) {
        if (state is WorkoutsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WorkoutsLoaded) {
          final workouts = state.workouts;

          if (workouts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _buildWorkoutCard(workout);
            },
          );
        }

        if (state is WorkoutsError) {
          return _buildErrorState(state.message);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyState() {
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
            'Нет созданных тренировок',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Нажмите на кнопку + чтобы создать',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/new_track'),
            icon: const Icon(Icons.add),
            label: const Text('Создать тренировку'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

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
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => context.read<WorkoutsBloc>().add(LoadWorkouts()),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => _showWorkoutDetails(workout),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _getDaysText(workout.days),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Text(
                      '${workout.duration} мин',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: workout.exercises.take(3).map((exercise) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Text(
                      _getExerciseShortName(exercise),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
              if (workout.exercises.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    '+ еще ${workout.exercises.length - 3} упражнений',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _startWorkout(workout),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Начать'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => _deleteWorkout(workout.id),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetails(WorkoutTemplate workout) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workout.name, style: theme.textTheme.titleLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дни: ${_getDaysText(workout.days)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Длительность: ${workout.duration} минут'),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Упражнения:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...workout.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${exercise.name}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (exercise.description != null &&
                            exercise.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppSpacing.md, top: AppSpacing.xs),
                            child: Text(
                              exercise.description!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: AppSpacing.md, top: AppSpacing.xs),
                          child: Text(
                            _getExerciseDetails(exercise),
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startWorkout(workout);
            },
            child: const Text('Начать тренировку'),
          ),
        ],
      ),
    );
  }

  void _showCompletedWorkouts(List<WorkoutSession> workouts) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выполненные тренировки'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(workout.workoutName),
                subtitle: Text(
                  'Выполнено: ${_formatTime(workout.completedAt!)}',
                  style: theme.textTheme.labelMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showWorkoutDetailsFromSession(workout);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetailsFromSession(WorkoutSession session) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.workoutName, style: theme.textTheme.titleLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выполнено: ${_formatDateTime(session.completedAt!)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Упражнения:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...session.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              exercise.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: exercise.isCompleted
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: exercise.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (exercise.description != null &&
                            exercise.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppSpacing.lg, top: AppSpacing.xs),
                            child: Text(
                              exercise.description!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        if (exercise.result != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppSpacing.lg, top: AppSpacing.xs),
                            child: Text(
                              _getExerciseResultText(exercise),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _startWorkout(WorkoutTemplate workout) {
    context.read<WorkoutSessionBloc>().add(StartWorkout(workout));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkoutExecutionScreen(),
      ),
    ).then((_) {
      context.read<WorkoutSessionBloc>().add(LoadWorkoutSessions());
    });
  }

  void _deleteWorkout(String workoutId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тренировку'),
        content: const Text('Вы уверены, что хотите удалить эту тренировку?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutsBloc>().add(DeleteWorkout(workoutId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Тренировка удалена'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text(
              'Удалить',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _changeWeek(int direction) {
    context.read<WorkoutSessionBloc>().add(LoadWorkoutSessions());
  }

  String _getDaysText(Set<int> days) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    if (days.isEmpty) return 'Не выбраны';
    if (days.length == 7) return 'Каждый день';
    return days.map((d) => dayNames[d]).join(', ');
  }

  String _getDayName(int index) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[index];
  }

  DateTime _getDateForWeekday(int weekday) {
    final now = DateTime.now();
    final currentWeekday = now.weekday - 1;
    final difference = weekday - currentWeekday;
    return now.add(Duration(days: difference));
  }

  String _getCurrentWeekText() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.day}.${startOfWeek.month} - ${endOfWeek.day}.${endOfWeek.month}';
  }

  String _getExerciseShortName(Exercise exercise) {
    if (exercise.type == ExerciseType.running) {
      return '🏃 ${exercise.name}';
    }
    return '💪 ${exercise.name}';
  }

  String _getExerciseDetails(Exercise exercise) {
    if (exercise.type == ExerciseType.running) {
      return 'Дистанция: ${exercise.distance} км';
    }
    String details =
        '${exercise.sets} подходов × ${exercise.repsPerSet} повторений';
    if (exercise.weight != null && exercise.weight! > 0) {
      details += ', вес: ${exercise.weight} кг';
    }
    return details;
  }

  String _getExerciseResultText(ExerciseSession exercise) {
    if (exercise.type == ExerciseType.running && exercise.result != null) {
      final distance = exercise.result!['distance'];
      return 'Результат: ${distance?.toStringAsFixed(1)} км';
    }
    if (exercise.type == ExerciseType.sets && exercise.result != null) {
      final sets = exercise.result!['completedSets'];
      final weight = exercise.result!['maxWeight'];
      return 'Результат: $sets подходов${weight != null ? ', вес: $weight кг' : ''}';
    }
    return '';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
