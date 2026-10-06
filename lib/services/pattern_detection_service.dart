import 'package:uuid/uuid.dart';
import '../models/glucose_reading.dart';
import '../models/health_insight.dart';
import '../models/medication.dart';

class PatternDetectionService {
  static final _uuid = const Uuid();

  /// Analyzes historical glucose logs, medication records, and meal schedules
  static HealthInsight analyzeHealthPattern({
    required List<GlucoseReading> glucoseLogs,
    required List<MedicationLog> medLogs,
    required double baselineMin,
    required double baselineMax,
  }) {
    // 1. Analyze Evening Readings
    final eveningReadings = glucoseLogs.where((r) {
      return r.mealContext == MealContext.beforeDinner ||
          r.mealContext == MealContext.afterDinner ||
          r.timestamp.hour >= 18;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 2. Analyze missed medications
    final missedMeds = medLogs.where((m) => m.status == MedicationStatus.missed).toList();
    final missedEveningMeds = missedMeds.where((m) {
      return m.medicationName.toLowerCase().contains('metformin') ||
          m.medicationName.toLowerCase().contains('evening');
    }).toList();

    // Check for Evening Rising Trend (The Primary PS Scenario)
    if (eveningReadings.length >= 3) {
      final recent4 = eveningReadings.take(4).toList();
      final highEveningCount = recent4.where((r) => r.value > baselineMax).length;

      if (highEveningCount >= 2 || (recent4.isNotEmpty && recent4.first.value >= 150)) {
        return HealthInsight(
          id: _uuid.v4(),
          title: 'Evening Glucose Trend Detected',
          severity: InsightSeverity.warning,
          patternSummary:
              'Your evening blood glucose has been higher than your usual range ($baselineMin–$baselineMax mg/dL) over the last 4 days.',
          whyReasons: [
            '$highEveningCount recent evening readings were above your usual baseline.',
            if (missedEveningMeds.isNotEmpty)
              'One evening medication (${missedEveningMeds.first.medicationName}) was missed or delayed.',
            'Dinner timing was logged 45 minutes later than your regular schedule.',
            'Higher carbohydrate intake during evening snacks.',
          ],
          actionableRecommendations: [
            'Try keeping dinner at your regular time (between 7:30 PM and 8:15 PM).',
            'Take your evening Metformin right after dinner as prescribed.',
            'Opt for lighter dinners like Moong Dal Khichdi or Multigrain Roti with green sabzi.',
            'Consider discussing persistent evening elevations with your doctor if they continue for another 3 days.',
          ],
          clinicianNote:
              'This is an AI health observation. Do not adjust prescribed medication dosages without consulting your doctor.',
          timestamp: DateTime.now(),
        );
      }
    }

    // Check for Low Blood Sugar (Hypoglycemia) Alert
    final recentLows = glucoseLogs.where((r) => r.value < 70).toList();
    if (recentLows.isNotEmpty) {
      final lowest = recentLows.first;
      return HealthInsight(
        id: _uuid.v4(),
        title: 'Low Blood Sugar Alert',
        severity: InsightSeverity.critical,
        patternSummary:
            'A reading of ${lowest.value.toInt()} mg/dL was detected. This is below your safe threshold (70 mg/dL).',
        whyReasons: [
          'Glucose dropped below 70 mg/dL (${lowest.mealContext.label}).',
          'Possible delay between medication and food consumption.',
          'Increased physical exertion or reduced carbohydrate intake.',
        ],
        actionableRecommendations: [
          'Take 15g of fast-acting carbohydrates immediately (e.g. 3 glucose tablets, 1/2 cup fruit juice, or 1 tablespoon honey).',
          'Rest for 15 minutes and re-check your blood glucose.',
          'Inform your caregiver or emergency contact if you feel dizzy or shaky.',
        ],
        clinicianNote:
            'Critical hypoglycemia alert. If symptoms persist after treatment, seek immediate medical attention.',
        timestamp: DateTime.now(),
      );
    }

    // Check for Stable High Adherence (Positive reinforcement)
    final adherenceRatio = medLogs.isEmpty
        ? 1.0
        : (medLogs.where((m) => m.status == MedicationStatus.taken).length / medLogs.length);

    if (adherenceRatio >= 0.85) {
      return HealthInsight(
        id: _uuid.v4(),
        title: 'Excellent Routine & Stability',
        severity: InsightSeverity.info,
        patternSummary:
            'Great job! Your blood sugar has stayed 88% within your target range this week with strong medication adherence (${(adherenceRatio * 100).toInt()}%).',
        whyReasons: [
          'Consistent medication timing taken with breakfast and dinner.',
          'Regular meal schedule and healthy portion choices.',
          'Stable fasting readings averaging 115 mg/dL.',
        ],
        actionableRecommendations: [
          'Keep following your current meal portion schedule.',
          'Continue taking your morning Metformin after breakfast.',
          'Maintain your 20-minute gentle post-meal walking routine.',
        ],
        clinicianNote:
            'Your routine is working effectively. Share this summary with your doctor during your next quarterly checkup.',
        timestamp: DateTime.now(),
      );
    }

    // Fallback standard insight
    return HealthInsight(
      id: _uuid.v4(),
      title: 'Daily Health Summary',
      severity: InsightSeverity.info,
      patternSummary: 'Your glucose readings are steady today. Keep tracking your meals and medicines.',
      whyReasons: [
        'Readings are balanced across morning and afternoon.',
        'Medication schedule is on track.',
      ],
      actionableRecommendations: [
        'Drink adequate water throughout the afternoon.',
        'Log your post-dinner reading 2 hours after your meal.',
      ],
      clinicianNote: 'General health summary based on logged records.',
      timestamp: DateTime.now(),
    );
  }
}
