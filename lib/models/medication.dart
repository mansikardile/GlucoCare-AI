enum TimeOfDaySlot {
  morning('Morning', '8:00 AM - 10:00 AM', '🌅'),
  afternoon('Afternoon', '1:00 PM - 2:30 PM', '☀️'),
  evening('Evening', '7:30 PM - 9:00 PM', '🌆'),
  bedtime('Night', '10:00 PM - 11:00 PM', '🌙');

  final String title;
  final String window;
  final String icon;
  const TimeOfDaySlot(this.title, this.window, this.icon);
}

enum MedicationStatus {
  pending('Pending', 'Not taken yet'),
  taken('Taken', 'Completed on time'),
  missed('Missed', 'Missed scheduled window'),
  snoozed('Later', 'Postponed for 30m');

  final String label;
  final String subtitle;
  const MedicationStatus(this.label, this.subtitle);
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final TimeOfDaySlot slot;
  final String timeString; // e.g. "9:00 AM"

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.slot,
    required this.timeString,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'instructions': instructions,
    'slot': slot.name,
    'timeString': timeString,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String,
    name: json['name'] as String,
    dosage: json['dosage'] as String,
    instructions: json['instructions'] as String,
    slot: TimeOfDaySlot.values.firstWhere(
      (e) => e.name == json['slot'],
      orElse: () => TimeOfDaySlot.morning,
    ),
    timeString: json['timeString'] as String,
  );
}

class MedicationLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime scheduledDate;
  final MedicationStatus status;
  final DateTime? takenAt;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledDate,
    required this.status,
    this.takenAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'medicationName': medicationName,
    'dosage': dosage,
    'scheduledDate': scheduledDate.toIso8601String(),
    'status': status.name,
    'takenAt': takenAt?.toIso8601String(),
  };

  factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
    id: json['id'] as String,
    medicationId: json['medicationId'] as String,
    medicationName: json['medicationName'] as String,
    dosage: json['dosage'] as String,
    scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    status: MedicationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MedicationStatus.pending,
    ),
    takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt'] as String) : null,
  );

  MedicationLog copyWith({
    MedicationStatus? status,
    DateTime? takenAt,
  }) {
    return MedicationLog(
      id: id,
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      scheduledDate: scheduledDate,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}
