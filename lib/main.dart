import 'package:bodytrack/core/routers/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/main-app-theme.dart';
import 'bloc/workout_creation/workout_creation_bloc.dart';
import 'bloc/workouts/workouts_bloc.dart';
import 'bloc/workout_session/workout_session_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const BodyTrackApp());
}

class BodyTrackApp extends StatelessWidget {
  const BodyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkoutCreationBloc()),
        BlocProvider(create: (_) => WorkoutsBloc()..add(LoadWorkouts())),
        BlocProvider(
            create: (_) => WorkoutSessionBloc()..add(LoadWorkoutSessions())),
      ],
      child: MaterialApp(
        title: 'BodyTrack',
        theme: main_theme,
        routes: router,
        initialRoute: '/',
      ),
    );
  }
}
