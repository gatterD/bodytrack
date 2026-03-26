enum ExerciseType {
  running,
  sets,
}

class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final String? description;

  // Для бега
  final double? distance; // в километрах

  // Для подходов
  final int? sets; // количество подходов
  final int? repsPerSet; // повторений за подход
  final double? weight; // вес в кг

  Exercise({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.distance,
    this.sets,
    this.repsPerSet,
    this.weight,
  });

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseType? type,
    String? description,
    double? distance,
    int? sets,
    int? repsPerSet,
    double? weight,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      sets: sets ?? this.sets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString(),
        'description': description,
        'distance': distance,
        'sets': sets,
        'repsPerSet': repsPerSet,
        'weight': weight,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'ExerciseType.running'
          ? ExerciseType.running
          : ExerciseType.sets,
      description: json['description'],
      distance: json['distance']?.toDouble(),
      sets: json['sets'],
      repsPerSet: json['repsPerSet'],
      weight: json['weight']?.toDouble(),
    );
  }
}
