import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../widgets/WeekdayPickerWidget.dart';
import 'ExercisesCreationScreen.dart';

class WorkoutCreationScreen extends StatefulWidget {
  const WorkoutCreationScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать тренировку'),
        actions: [
          TextButton(
            onPressed: _nextStep,
            child: const Text('Далее'),
          ),
        ],
      ),
      body: BlocBuilder<WorkoutCreationBloc, WorkoutCreationState>(
        builder: (context, state) {
          if (state is WorkoutCreationInProgress) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название тренировки
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название тренировки *',
                      border: OutlineInputBorder(),
                      hintText: 'Например: Утренняя зарядка',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Дни недели
                  const Text(
                    'Дни тренировки *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const WeekdayPicker(),
                  const SizedBox(height: 24),

                  // Длительность
                  const Text(
                    'Длительность',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '$_duration минут',
                            style: const TextStyle(fontSize: 16),
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Информация о упражнениях
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Упражнения',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Добавлено: ${state.template.exercises.length}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
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
          const SnackBar(content: Text('Введите название тренировки')),
        );
        return;
      }
      if (state.template.days.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите дни тренировки')),
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
