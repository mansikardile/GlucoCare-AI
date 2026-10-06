class CaregiverAlert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String severity; // info, warning, alert
  final bool isRead;

  CaregiverAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'severity': severity,
    'isRead': isRead,
  };

  factory CaregiverAlert.fromJson(Map<String, dynamic> json) => CaregiverAlert(
    id: json['id'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    severity: json['severity'] as String? ?? 'warning',
    isRead: json['isRead'] as bool? ?? false,
  );

  CaregiverAlert copyWith({bool? isRead}) {
    return CaregiverAlert(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      severity: severity,
      isRead: isRead ?? this.isRead,
    );
  }
}
