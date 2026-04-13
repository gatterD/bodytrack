// lib/interface/widgets/WeekdayPickerWidget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';
import '../../core/theme/main-app-theme.dart';

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<WorkoutCreationBloc, WorkoutCreationState>(
      builder: (context, state) {
        if (state is WorkoutCreationInProgress) {
          final selectedDays = state.template.days;
          final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: List.generate(7, (index) {
              final isSelected = selectedDays.contains(index);
              return ChoiceChip(
                label: Text(
                  days[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  Set<int> newDays = Set.from(selectedDays);
                  if (selected) {
                    newDays.add(index);
                  } else {
                    newDays.remove(index);
                  }
                  context.read<WorkoutCreationBloc>().add(
                        UpdateWorkoutDays(newDays),
                      );
                },
                selectedColor: theme.colorScheme.primary,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                ),
                elevation: 0,
                pressElevation: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
