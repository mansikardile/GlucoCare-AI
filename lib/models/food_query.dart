enum FoodVerdict {
  goodChoice(
    'GOOD CHOICE',
    'Safe to enjoy with standard portions',
    '🟢',
    'safe',
  ),
  haveWithCare(
    'HAVE WITH CARE',
    'Portion control & balanced pairing needed',
    '🟡',
    'caution',
  ),
  avoidOrConsult(
    'CONSIDER AVOIDING',
    'High glycemic spike risk; consult clinician',
    '🔴',
    'avoid',
  );

  final String title;
  final String subtitle;
  final String icon;
  final String key;
  const FoodVerdict(this.title, this.subtitle, this.icon, this.key);
}

class FoodQuery {
  final String id;
  final String queryText;
  final String foodName;
  final String emoji;
  final FoodVerdict verdict;
  final String portionAdvice;
  final String glycemicReasoning;
  final String clinicalImpact;
  final String betterAlternative;
  final int estimatedCarbsGrams;
  final String glycemicIndexCategory; // Low, Medium, High
  final DateTime timestamp;

  FoodQuery({
    required this.id,
    required this.queryText,
    required this.foodName,
    required this.emoji,
    required this.verdict,
    required this.portionAdvice,
    required this.glycemicReasoning,
    required this.clinicalImpact,
    required this.betterAlternative,
    required this.estimatedCarbsGrams,
    required this.glycemicIndexCategory,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'queryText': queryText,
    'foodName': foodName,
    'emoji': emoji,
    'verdict': verdict.name,
    'portionAdvice': portionAdvice,
    'glycemicReasoning': glycemicReasoning,
    'clinicalImpact': clinicalImpact,
    'betterAlternative': betterAlternative,
    'estimatedCarbsGrams': estimatedCarbsGrams,
    'glycemicIndexCategory': glycemicIndexCategory,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FoodQuery.fromJson(Map<String, dynamic> json) => FoodQuery(
    id: json['id'] as String,
    queryText: json['queryText'] as String,
    foodName: json['foodName'] as String,
    emoji: json['emoji'] as String? ?? '🍽️',
    verdict: FoodVerdict.values.firstWhere(
      (e) => e.name == json['verdict'],
      orElse: () => FoodVerdict.haveWithCare,
    ),
    portionAdvice: json['portionAdvice'] as String,
    glycemicReasoning: json['glycemicReasoning'] as String,
    clinicalImpact: json['clinicalImpact'] as String,
    betterAlternative: json['betterAlternative'] as String,
    estimatedCarbsGrams: (json['estimatedCarbsGrams'] as int?) ?? 30,
    glycemicIndexCategory: json['glycemicIndexCategory'] as String? ?? 'Medium',
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
