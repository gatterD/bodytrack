import '../../app/BodyTrack.dart';
import '../../interface/screens/NewTrackCreation.dart';
import '../../interface/screens/ExercisesCreationScreen.dart';
import '../../interface/screens/WorkoutExecutionScreen.dart';

final router = {
  '/': (context) => const BodyTrack(title: 'Body Track'),
  '/new_track': (context) => const NewTrackCreation(),
  '/exercises_creation': (context) => const ExercisesCreationScreen(),
  '/workout_execution': (context) => const WorkoutExecutionScreen(),
};
