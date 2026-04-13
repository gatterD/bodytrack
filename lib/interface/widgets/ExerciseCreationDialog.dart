// lib/interface/widgets/ExerciseCreationDialog.dart
import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../../core/theme/main-app-theme.dart';

class ExerciseCreationDialog extends StatefulWidget {
  final Exercise? existingExercise;
  final Function(Exercise) onSave;

  const ExerciseCreationDialog({
    super.key,
    this.existingExercise,
    required this.onSave,
  });

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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingExercise == null
                    ? 'Добавить упражнение'
                    : 'Редактировать упражнение',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),

              // Название упражнения
              TextField(
                controller: _nameController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Название упражнения *',
                  hintText: 'Например: Приседания со штангой',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  counterStyle: theme.textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Описание
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Техника выполнения, советы и т.д.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Тип упражнения
              Text(
                'Тип упражнения',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
                // 👈 Правильное использование style
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return theme.colorScheme.primary;
                    }
                    return Colors.grey.shade100;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black87;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Поля в зависимости от типа
              if (_exerciseType == ExerciseType.running) ...[
                TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Дистанция (км) *',
                    hintText: 'Введите дистанцию в километрах',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    suffixText: 'км',
                    suffixStyle: theme.textTheme.labelSmall,
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Количество подходов *',
                          hintText: 'Например: 3',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Повторений *',
                          hintText: 'Например: 10',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Вес (кг)',
                    hintText: 'Необязательно',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    suffixText: 'кг',
                    suffixStyle: theme.textTheme.labelSmall,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveExercise,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
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
      if (distance == null || distance <= 0) {
        _showError('Введите корректную дистанцию');
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

      if (sets == null || sets <= 0 || reps == null || reps <= 0) {
        _showError('Введите корректное количество подходов и повторений');
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
