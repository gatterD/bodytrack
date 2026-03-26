import 'package:flutter/material.dart';

import '../../data/models/exercise.dart';

class ExerciseCreationDialog extends StatefulWidget {
  final Exercise? existingExercise;
  final Function(Exercise) onSave;

  const ExerciseCreationDialog({
    Key? key,
    this.existingExercise,
    required this.onSave,
  }) : super(key: key);

  @override
  _ExerciseCreationDialogState createState() => _ExerciseCreationDialogState();
}

class _ExerciseCreationDialogState extends State<ExerciseCreationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ExerciseType _exerciseType;

  // Для бега
  late TextEditingController _distanceController;

  // Для подходов
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingExercise?.name);
    _descriptionController =
        TextEditingController(text: widget.existingExercise?.description);
    _exerciseType = widget.existingExercise?.type ?? ExerciseType.sets;

    _distanceController = TextEditingController(
      text: widget.existingExercise?.distance?.toString() ?? '',
    );
    _setsController = TextEditingController(
      text: widget.existingExercise?.sets?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.existingExercise?.repsPerSet?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.existingExercise?.weight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _distanceController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingExercise == null
                    ? 'Добавить упражнение'
                    : 'Редактировать упражнение',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Название упражнения
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название упражнения *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Описание
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Тип упражнения
              const Text(
                'Тип упражнения',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ExerciseType>(
                segments: const [
                  ButtonSegment(
                    value: ExerciseType.sets,
                    label: Text('Подходы'),
                    icon: Icon(Icons.fitness_center),
                  ),
                  ButtonSegment(
                    value: ExerciseType.running,
                    label: Text('Бег'),
                    icon: Icon(Icons.directions_run),
                  ),
                ],
                selected: {_exerciseType},
                onSelectionChanged: (Set<ExerciseType> newSelection) {
                  setState(() {
                    _exerciseType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Поля в зависимости от типа
              if (_exerciseType == ExerciseType.running) ...[
                TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Дистанция (км) *',
                    border: OutlineInputBorder(),
                    suffixText: 'км',
                  ),
                ),
              ] else ...[
                // Подходы
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Количество подходов *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Повторений *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Вес (кг)',
                    border: OutlineInputBorder(),
                    suffixText: 'кг',
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveExercise,
                      child: const Text('Сохранить'),
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

  void _saveExercise() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Введите название упражнения');
      return;
    }

    Exercise exercise;

    if (_exerciseType == ExerciseType.running) {
      final distance = double.tryParse(_distanceController.text);
      if (distance == null) {
        _showError('Введите дистанцию');
        return;
      }

      exercise = Exercise(
        id: widget.existingExercise?.id ?? DateTime.now().toString(),
        name: name,
        type: ExerciseType.running,
        description: _descriptionController.text.trim(),
        distance: distance,
      );
    } else {
      final sets = int.tryParse(_setsController.text);
      final reps = int.tryParse(_repsController.text);

      if (sets == null || reps == null) {
        _showError('Введите количество подходов и повторений');
        return;
      }

      exercise = Exercise(
        id: widget.existingExercise?.id ?? DateTime.now().toString(),
        name: name,
        type: ExerciseType.sets,
        description: _descriptionController.text.trim(),
        sets: sets,
        repsPerSet: reps,
        weight: double.tryParse(_weightController.text),
      );
    }

    widget.onSave(exercise);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
