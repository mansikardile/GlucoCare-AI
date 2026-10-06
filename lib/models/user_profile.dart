class UserProfile {
  final String id;
  final String name;
  final int age;
  final String diabetesType;
  final String dietaryPreference;
  final String caregiverName;
  final String caregiverRelation;
  final String caregiverPhone;
  final bool caregiverAlertsEnabled;
  final double targetMinGlucose;
  final double targetMaxGlucose;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.diabetesType,
    required this.dietaryPreference,
    required this.caregiverName,
    required this.caregiverRelation,
    required this.caregiverPhone,
    this.caregiverAlertsEnabled = true,
    this.targetMinGlucose = 90.0,
    this.targetMaxGlucose = 140.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'diabetesType': diabetesType,
    'dietaryPreference': dietaryPreference,
    'caregiverName': caregiverName,
    'caregiverRelation': caregiverRelation,
    'caregiverPhone': caregiverPhone,
    'caregiverAlertsEnabled': caregiverAlertsEnabled,
    'targetMinGlucose': targetMinGlucose,
    'targetMaxGlucose': targetMaxGlucose,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String? ?? 'user_1',
    name: json['name'] as String? ?? 'Rajesh Sharma',
    age: json['age'] as int? ?? 67,
    diabetesType: json['diabetesType'] as String? ?? 'Type 2 Diabetes',
    dietaryPreference: json['dietaryPreference'] as String? ?? 'Vegetarian',
    caregiverName: json['caregiverName'] as String? ?? 'Priya Sharma',
    caregiverRelation: json['caregiverRelation'] as String? ?? 'Daughter',
    caregiverPhone: json['caregiverPhone'] as String? ?? '+91 98765 43210',
    caregiverAlertsEnabled: json['caregiverAlertsEnabled'] as bool? ?? true,
    targetMinGlucose: (json['targetMinGlucose'] as num?)?.toDouble() ?? 90.0,
    targetMaxGlucose: (json['targetMaxGlucose'] as num?)?.toDouble() ?? 140.0,
  );

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? diabetesType,
    String? dietaryPreference,
    String? caregiverName,
    String? caregiverRelation,
    String? caregiverPhone,
    bool? caregiverAlertsEnabled,
    double? targetMinGlucose,
    double? targetMaxGlucose,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      diabetesType: diabetesType ?? this.diabetesType,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverRelation: caregiverRelation ?? this.caregiverRelation,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      caregiverAlertsEnabled: caregiverAlertsEnabled ?? this.caregiverAlertsEnabled,
      targetMinGlucose: targetMinGlucose ?? this.targetMinGlucose,
      targetMaxGlucose: targetMaxGlucose ?? this.targetMaxGlucose,
    );
  }
}
