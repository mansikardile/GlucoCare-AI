enum InsightSeverity {
  info('Information', 'Routine progress', 'ℹ️'),
  warning('Pattern Detected', 'Requires slight attention', '⚠️'),
  critical('Health Alert', 'Immediate care / clinician consultation', '🚨');

  final String label;
  final String description;
  final String icon;
  const InsightSeverity(this.label, this.description, this.icon);
}

class HealthInsight {
  final String id;
  final String title;
  final InsightSeverity severity;
  final String patternSummary;
  final List<String> whyReasons;
  final List<String> actionableRecommendations;
  final String clinicianNote;
  final DateTime timestamp;
  final bool sentToCaregiver;
  final bool isAcknowledged;

  HealthInsight({
    required this.id,
    required this.title,
    required this.severity,
    required this.patternSummary,
    required this.whyReasons,
    required this.actionableRecommendations,
    required this.clinicianNote,
    required this.timestamp,
    this.sentToCaregiver = false,
    this.isAcknowledged = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'severity': severity.name,
    'patternSummary': patternSummary,
    'whyReasons': whyReasons,
    'actionableRecommendations': actionableRecommendations,
    'clinicianNote': clinicianNote,
    'timestamp': timestamp.toIso8601String(),
    'sentToCaregiver': sentToCaregiver,
    'isAcknowledged': isAcknowledged,
  };

  factory HealthInsight.fromJson(Map<String, dynamic> json) => HealthInsight(
    id: json['id'] as String,
    title: json['title'] as String,
    severity: InsightSeverity.values.firstWhere(
      (e) => e.name == json['severity'],
      orElse: () => InsightSeverity.warning,
    ),
    patternSummary: json['patternSummary'] as String,
    whyReasons: List<String>.from(json['whyReasons'] as List),
    actionableRecommendations: List<String>.from(json['actionableRecommendations'] as List),
    clinicianNote: json['clinicianNote'] as String? ?? 'Always follow your physician\'s advice.',
    timestamp: DateTime.parse(json['timestamp'] as String),
    sentToCaregiver: json['sentToCaregiver'] as bool? ?? false,
    isAcknowledged: json['isAcknowledged'] as bool? ?? false,
  );

  HealthInsight copyWith({
    bool? sentToCaregiver,
    bool? isAcknowledged,
  }) {
    return HealthInsight(
      id: id,
      title: title,
      severity: severity,
      patternSummary: patternSummary,
      whyReasons: whyReasons,
      actionableRecommendations: actionableRecommendations,
      clinicianNote: clinicianNote,
      timestamp: timestamp,
      sentToCaregiver: sentToCaregiver ?? this.sentToCaregiver,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }
}
