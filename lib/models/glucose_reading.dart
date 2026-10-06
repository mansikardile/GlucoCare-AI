enum MealContext {
  fasting('Fasting', 'Before any food'),
  beforeBreakfast('Before Breakfast', 'Morning reading'),
  afterBreakfast('After Breakfast', '2 hrs post breakfast'),
  beforeLunch('Before Lunch', 'Pre-afternoon meal'),
  afterLunch('After Lunch', '2 hrs post lunch'),
  beforeDinner('Before Dinner', 'Pre-evening meal'),
  afterDinner('After Dinner', '2 hrs post dinner'),
  bedtime('Bedtime', 'Before sleeping'),
  random('Other', 'Anytime check');

  final String label;
  final String description;
  const MealContext(this.label, this.description);
}

enum GlucoseStatus {
  low('Low', 'Below safe range (<70)'),
  normal('In Range', 'Within your usual range (70-140)'),
  elevated('Slightly High', 'Above baseline (141-180)'),
  high('High', 'High level (>180)');

  final String label;
  final String description;
  const GlucoseStatus(this.label, this.description);
}

class GlucoseReading {
  final String id;
  final double value; // in mg/dL
  final DateTime timestamp;
  final MealContext mealContext;
  final String? note;

  GlucoseReading({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.mealContext,
    this.note,
  });

  GlucoseStatus get status {
    if (value < 70) return GlucoseStatus.low;
    if (value <= 140) return GlucoseStatus.normal;
    if (value <= 180) return GlucoseStatus.elevated;
    return GlucoseStatus.high;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'mealContext': mealContext.name,
    'note': note,
  };

  factory GlucoseReading.fromJson(Map<String, dynamic> json) => GlucoseReading(
    id: json['id'] as String,
    value: (json['value'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    mealContext: MealContext.values.firstWhere(
      (e) => e.name == json['mealContext'],
      orElse: () => MealContext.random,
    ),
    note: json['note'] as String?,
  );
}
