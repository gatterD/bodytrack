// lib/interface/screens/WorkoutCreationScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../widgets/WeekdayPickerWidget.dart';
import 'AppBar.dart';
import 'ExercisesCreationScreen.dart';
import '../../core/theme/main-app-theme.dart';

class WorkoutCreationScreen extends StatefulWidget {
  const WorkoutCreationScreen({super.key});

  @override
  _WorkoutCreationScreenState createState() => _WorkoutCreationScreenState();
}

class _WorkoutCreationScreenState extends State<WorkoutCreationScreen> {
  final _nameController = TextEditingController();
  int _duration = 30;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    context.read<WorkoutCreationBloc>().add(
          UpdateWorkoutName(_nameController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BTAppBar(
        title: 'Создать тренировку',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _nextStep,
            child: Text(
              'Далее',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<WorkoutCreationBloc, WorkoutCreationState>(
        builder: (context, state) {
          if (state is WorkoutCreationInProgress) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название тренировки
                  TextField(
                    controller: _nameController,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Название тренировки *',
                      hintText: 'Например: Утренняя зарядка',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      counterStyle: theme.textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Дни недели
                  Text(
                    'Дни тренировки *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const WeekdayPicker(),
                  const SizedBox(height: AppSpacing.lg),

                  // Длительность
                  Text(
                    'Длительность',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            '$_duration минут',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_duration > 15) {
                              setState(() {
                                _duration -= 5;
                              });
                              context.read<WorkoutCreationBloc>().add(
                                    UpdateWorkoutDuration(_duration),
                                  );
                            }
                          },
                          color: theme.colorScheme.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_duration < 120) {
                              setState(() {
                                _duration += 5;
                              });
                              context.read<WorkoutCreationBloc>().add(
                                    UpdateWorkoutDuration(_duration),
                                  );
                            }
                          },
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Информация о упражнениях
                  InkWell(
                    onTap: _nextStep,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Упражнения',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Добавлено: ${state.template.exercises.length}',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _nextStep() {
    final state = context.read<WorkoutCreationBloc>().state;

    if (state is WorkoutCreationInProgress) {
      if (state.template.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Введите название тренировки'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
        return;
      }

      if (state.template.days.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Выберите дни тренировки'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ExercisesCreationScreen(),
        ),
      );
    }
  }
}
