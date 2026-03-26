import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workout_creation/workout_creation_bloc.dart';

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCreationBloc, WorkoutCreationState>(
      builder: (context, state) {
        if (state is WorkoutCreationInProgress) {
          final selectedDays = state.template.days;
          final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final isSelected = selectedDays.contains(index);
              return ChoiceChip(
                label: Text(days[index]),
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
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                pressElevation: 0,
              );
            }),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
