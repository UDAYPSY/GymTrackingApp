class ExerciseModel {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String notes;

  ExerciseModel({
    required this.name,
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = 60,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 12,
      restSeconds: map['restSeconds'] ?? 60,
      notes: map['notes'] ?? '',
    );
  }
}

class WorkoutPlanModel {
  final String id;
  final String title;
  final String category; // 'Muscle Building', 'Fat Loss', 'Strength'
  final String level; // 'Beginner', 'Intermediate', 'Advanced'
  final List<ExerciseModel> exercises;

  WorkoutPlanModel({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.exercises,
  });
}
