import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../widgets/WeekdayPickerWidget.dart';
import 'AppBar.dart';

class NewTrackCreation extends StatefulWidget {
  const NewTrackCreation({super.key});

  @override
  State<NewTrackCreation> createState() => _NewTrackCreationState();
}

class _NewTrackCreationState extends State<NewTrackCreation> {
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
      appBar: BTAppBar(
        title: "Новая тренировка",
        showBackButton: true,
      ),
      body: BlocConsumer<WorkoutCreationBloc, WorkoutCreationState>(
        listener: (context, state) {
          if (state is WorkoutCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkoutCreationInProgress) {
            return _buildForm(state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildForm(WorkoutCreationInProgress state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название тренировки
          TextField(
            controller: _nameController,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: "Название тренировки",
              hintText: "Например: Утренняя зарядка",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Дни недели
          const Text(
            "Дни тренировки",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const WeekdayPicker(),
          const SizedBox(height: 24),

          // Длительность
          const Text(
            "Длительность тренировки",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.deepPurple),
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

          // Информация о количестве упражнений
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Кнопка "Далее"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _nextStep(state),
              child: const Text(
                'Далее →',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep(WorkoutCreationInProgress state) {
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

    // Переходим к странице упражнений
    Navigator.pushNamed(context, '/exercises_creation');
  }
}
