import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/core/utils/formatters.dart';
import 'package:gym_manager/features/members/repositories/member_repository.dart';
import 'package:gym_manager/features/workouts/models/workout_model.dart';

class WorkoutPlannerScreen extends ConsumerStatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  ConsumerState<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends ConsumerState<WorkoutPlannerScreen> {
  final List<WorkoutPlanModel> _masterPlans = [
    WorkoutPlanModel(
      id: 'p1',
      title: 'Push Day (Chest, Shoulders & Triceps)',
      category: 'Muscle Building',
      level: 'Intermediate',
      exercises: [
        ExerciseModel(name: 'Barbell Bench Press', sets: 4, reps: 10, restSeconds: 90),
        ExerciseModel(name: 'Incline Dumbbell Press', sets: 3, reps: 12, restSeconds: 60),
        ExerciseModel(name: 'Overhead Dumbbell Shoulder Press', sets: 3, reps: 10, restSeconds: 75),
        ExerciseModel(name: 'Cable Lateral Raises', sets: 4, reps: 15, restSeconds: 45),
        ExerciseModel(name: 'Triceps Rope Pushdown', sets: 3, reps: 12, restSeconds: 45),
      ],
    ),
    WorkoutPlanModel(
      id: 'p2',
      title: 'Pull Day (Back & Biceps)',
      category: 'Muscle Building',
      level: 'Intermediate',
      exercises: [
        ExerciseModel(name: 'Lat Pulldown', sets: 4, reps: 12, restSeconds: 75),
        ExerciseModel(name: 'Seated Cable Row', sets: 3, reps: 10, restSeconds: 60),
        ExerciseModel(name: 'Barbell Bent Over Row', sets: 3, reps: 8, restSeconds: 90),
        ExerciseModel(name: 'Barbell Bicep Curl', sets: 3, reps: 12, restSeconds: 60),
        ExerciseModel(name: 'Hammer Curls', sets: 3, reps: 12, restSeconds: 45),
      ],
    ),
    WorkoutPlanModel(
      id: 'p3',
      title: 'Leg Day (Quads, Hamstrings & Calves)',
      category: 'Strength',
      level: 'Intermediate',
      exercises: [
        ExerciseModel(name: 'Barbell Back Squats', sets: 4, reps: 8, restSeconds: 120),
        ExerciseModel(name: 'Leg Press', sets: 3, reps: 12, restSeconds: 90),
        ExerciseModel(name: 'Romanian Deadlifts', sets: 3, reps: 10, restSeconds: 90),
        ExerciseModel(name: 'Leg Extensions', sets: 3, reps: 15, restSeconds: 45),
        ExerciseModel(name: 'Standing Calf Raises', sets: 4, reps: 15, restSeconds: 45),
      ],
    ),
    WorkoutPlanModel(
      id: 'p4',
      title: 'Full Body Circuit (Fat Loss & Conditioning)',
      category: 'Fat Loss',
      level: 'Beginner',
      exercises: [
        ExerciseModel(name: 'Goblet Squats', sets: 3, reps: 15, restSeconds: 45),
        ExerciseModel(name: 'Push-ups', sets: 3, reps: 12, restSeconds: 45),
        ExerciseModel(name: 'Kettlebell Swings', sets: 4, reps: 20, restSeconds: 45),
        ExerciseModel(name: 'Plank Hold', sets: 3, reps: 45, restSeconds: 30, notes: '45 seconds'),
      ],
    ),
  ];

  void _sharePlan(WorkoutPlanModel plan) {
    final membersAsync = ref.read(membersStreamProvider);
    final members = membersAsync.value ?? [];

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members found to share with.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Share "${plan.title}"'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (ctx, i) {
              final m = members[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withAlpha(40),
                  child: Text(m.name[0], style: const TextStyle(color: AppTheme.primary)),
                ),
                title: Text(m.name),
                subtitle: Text(m.phone),
                trailing: const Icon(Icons.send, color: AppTheme.success),
                onTap: () {
                  Navigator.pop(ctx);
                  final buffer = StringBuffer();
                  buffer.writeln('💪 *GymManager Workout Plan: ${plan.title}*');
                  buffer.writeln('Category: ${plan.category} (${plan.level})');
                  buffer.writeln('------------------------------------');
                  for (var i = 0; i < plan.exercises.length; i++) {
                    final ex = plan.exercises[i];
                    buffer.writeln(
                      '${i + 1}. *${ex.name}*: ${ex.sets} sets x ${ex.reps} reps (Rest: ${ex.restSeconds}s)',
                    );
                  }
                  buffer.writeln('------------------------------------');
                  buffer.writeln('Stay consistent and stay hydrated! 🏋️');

                  Formatters.openWhatsApp(
                    phone: m.phone,
                    message: buffer.toString(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Routine Master'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _masterPlans.length,
        itemBuilder: (ctx, i) {
          final plan = _masterPlans[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
              ),
              title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${plan.category} • ${plan.level} • ${plan.exercises.length} Exercises',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share, color: AppTheme.success),
                tooltip: 'Send to Member on WhatsApp',
                onPressed: () => _sharePlan(plan),
              ),
              children: [
                const Divider(),
                ...plan.exercises.map((ex) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.check, size: 16, color: AppTheme.secondary),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      '${ex.sets} sets × ${ex.reps} reps',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _sharePlan(plan),
                      icon: const Icon(Icons.send, color: AppTheme.success),
                      label: const Text('Assign & Send via WhatsApp'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
