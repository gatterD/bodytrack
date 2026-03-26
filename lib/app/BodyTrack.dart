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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/new_track');
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
      builder: (context, state) {
        if (state is WorkoutSessionsLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
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
                // Заголовок с неделей
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _changeWeek(-1);
                      },
                    ),
                    Text(
                      _getCurrentWeekText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        _changeWeek(1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Дни недели
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayName = _getDayName(index);
                    final date = _getDateForWeekday(index);

                    // Находим завершенные тренировки за этот день
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
      String dayName, String dayNumber, bool isCompleted, int workoutCount) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNumber,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green.shade700 : Colors.black,
            ),
          ),
          if (workoutCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$workoutCount',
                style: TextStyle(
                  fontSize: 10,
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is WorkoutsLoaded) {
          final workouts = state.workouts;

          if (workouts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
            'Нет созданных тренировок',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Нажмите на кнопку + чтобы создать',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/new_track');
            },
            icon: const Icon(Icons.add),
            label: const Text('Создать тренировку'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<WorkoutsBloc>().add(LoadWorkouts());
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showWorkoutDetails(workout);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDaysText(workout.days),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${workout.duration} мин',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: workout.exercises.take(3).map((exercise) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getExerciseShortName(exercise),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (workout.exercises.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ еще ${workout.exercises.length - 3} упражнений',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _startWorkout(workout);
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Начать'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _deleteWorkout(workout.id);
                    },
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workout.name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дни: ${_getDaysText(workout.days)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Длительность: ${workout.duration} минут'),
              const SizedBox(height: 16),
              const Text(
                'Упражнения:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...workout.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${exercise.name}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (exercise.description != null &&
                            exercise.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              exercise.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            _getExerciseDetails(exercise),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.workoutName),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выполнено: ${_formatDateTime(session.completedAt!)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Упражнения:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...session.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
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
                            padding: const EdgeInsets.only(left: 24, top: 4),
                            child: Text(
                              exercise.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (exercise.result != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 4),
                            child: Text(
                              _getExerciseResultText(exercise),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
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
      // Обновляем календарь после завершения тренировки
      context.read<WorkoutSessionBloc>().add(LoadWorkoutSessions());
    });
  }

  void _deleteWorkout(String workoutId) {
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
                const SnackBar(
                  content: Text('Тренировка удалена'),
                  backgroundColor: Colors.orange,
                ),
              );
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

  void _changeWeek(int direction) {
    // TODO: Реализовать переключение недель
    // Пока просто обновляем
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
    } else {
      return '💪 ${exercise.name}';
    }
  }

  String _getExerciseDetails(Exercise exercise) {
    if (exercise.type == ExerciseType.running) {
      return 'Дистанция: ${exercise.distance} км';
    } else {
      String details =
          '${exercise.sets} подходов × ${exercise.repsPerSet} повторений';
      if (exercise.weight != null && exercise.weight! > 0) {
        details += ', вес: ${exercise.weight} кг';
      }
      return details;
    }
  }

  String _getExerciseResultText(ExerciseSession exercise) {
    if (exercise.type == ExerciseType.running && exercise.result != null) {
      final distance = exercise.result!['distance'];
      return 'Результат: ${distance?.toStringAsFixed(1)} км';
    } else if (exercise.type == ExerciseType.sets && exercise.result != null) {
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
