import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/services/firebase_service.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: GymManagerApp(),
    ),
  );
}

class GymManagerApp extends StatelessWidget {
  const GymManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
