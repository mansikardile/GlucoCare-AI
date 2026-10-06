import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../models/food_query.dart';
import '../models/caregiver_alert.dart';
import 'ai_food_service.dart';
import 'pattern_detection_service.dart';

class DatabaseService {
  static const _kProfileKey = 'glucocare_profile';
  static const _kGlucoseKey = 'glucocare_glucose';
  static const _kMedsKey = 'glucocare_meds';
  static const _kMedLogsKey = 'glucocare_med_logs';
  static const _kFoodQueriesKey = 'glucocare_food_queries';
  static const _kAlertsKey = 'glucocare_alerts';
  static const _kScenarioKey = 'glucocare_active_scenario';

  static final _uuid = const Uuid();

  /// Loads stored data or seeds initial synthetic database
  static Future<Map<String, dynamic>> initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    final profileJson = prefs.getString(_kProfileKey);
    if (profileJson == null) {
      return await seedScenario(1); // Default to Scenario 1 (PS Demo Flow)
    }

    try {
      final profile = UserProfile.fromJson(jsonDecode(profileJson));
      final glucoseList = _decodeList<GlucoseReading>(
        prefs.getString(_kGlucoseKey),
        (json) => GlucoseReading.fromJson(json),
      );
      final medsList = _decodeList<Medication>(
        prefs.getString(_kMedsKey),
        (json) => Medication.fromJson(json),
      );
      final medLogsList = _decodeList<MedicationLog>(
        prefs.getString(_kMedLogsKey),
        (json) => MedicationLog.fromJson(json),
      );
      final foodQueriesList = _decodeList<FoodQuery>(
        prefs.getString(_kFoodQueriesKey),
        (json) => FoodQuery.fromJson(json),
      );
      final alertsList = _decodeList<CaregiverAlert>(
        prefs.getString(_kAlertsKey),
        (json) => CaregiverAlert.fromJson(json),
      );
      final activeScenario = prefs.getInt(_kScenarioKey) ?? 1;

      final insight = PatternDetectionService.analyzeHealthPattern(
        glucoseLogs: glucoseList,
        medLogs: medLogsList,
        baselineMin: profile.targetMinGlucose,
        baselineMax: profile.targetMaxGlucose,
      );

      return {
        'profile': profile,
        'glucoseList': glucoseList,
        'medsList': medsList,
        'medLogsList': medLogsList,
        'foodQueriesList': foodQueriesList,
        'alertsList': alertsList,
        'activeInsight': insight,
        'scenario': activeScenario,
      };
    } catch (e) {
      // In case of parsing format mismatch, re-seed safely
      return await seedScenario(1);
    }
  }

  /// Generates synthetic dataset matching the exact hackathon scenario
  static Future<Map<String, dynamic>> seedScenario(int scenarioIndex) async {
    final now = DateTime.now();

    final profile = UserProfile(
      id: 'user_rajesh',
      name: 'Rajesh Sharma',
      age: 67,
      diabetesType: 'Type 2 Diabetes',
      dietaryPreference: 'Vegetarian',
      caregiverName: 'Priya Sharma',
      caregiverRelation: 'Daughter',
      caregiverPhone: '+91 98765 43210',
      caregiverAlertsEnabled: true,
      targetMinGlucose: 90,
      targetMaxGlucose: 140,
    );

    // Medications list
    final medsList = [
      Medication(
        id: 'med_metformin_morn',
        name: 'Metformin',
        dosage: '500 mg',
        instructions: 'After breakfast with water',
        slot: TimeOfDaySlot.morning,
        timeString: '9:00 AM',
      ),
      Medication(
        id: 'med_glimepiride_lunch',
        name: 'Glimepiride',
        dosage: '1 mg',
        instructions: '15 mins before lunch',
        slot: TimeOfDaySlot.afternoon,
        timeString: '1:00 PM',
      ),
      Medication(
        id: 'med_metformin_eve',
        name: 'Metformin',
        dosage: '500 mg',
        instructions: 'After dinner with water',
        slot: TimeOfDaySlot.evening,
        timeString: '8:00 PM',
      ),
      Medication(
        id: 'med_atorvastatin_night',
        name: 'Atorvastatin',
        dosage: '10 mg',
        instructions: 'Before bedtime',
        slot: TimeOfDaySlot.bedtime,
        timeString: '10:00 PM',
      ),
    ];

    List<GlucoseReading> glucoseList = [];
    List<MedicationLog> medLogsList = [];
    List<FoodQuery> foodQueriesList = [];
    List<CaregiverAlert> alertsList = [];

    if (scenarioIndex == 1) {
      // SCENARIO 1: Evening Rise + Missed Meds (The Hackathon Problem Statement hero flow)
      // 7 days of glucose readings
      final pastDays = [
        // Day -6
        GlucoseReading(
          id: _uuid.v4(),
          value: 110,
          timestamp: now.subtract(const Duration(days: 6, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 122,
          timestamp: now.subtract(const Duration(days: 6, hours: 4)),
          mealContext: MealContext.afterDinner,
        ),
        // Day -5
        GlucoseReading(
          id: _uuid.v4(),
          value: 115,
          timestamp: now.subtract(const Duration(days: 5, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 128,
          timestamp: now.subtract(const Duration(days: 5, hours: 4)),
          mealContext: MealContext.afterDinner,
        ),
        // Day -4
        GlucoseReading(
          id: _uuid.v4(),
          value: 118,
          timestamp: now.subtract(const Duration(days: 4, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 142,
          timestamp: now.subtract(const Duration(days: 4, hours: 4)),
          mealContext: MealContext.afterDinner,
          note: 'Dinner delayed to 9:30 PM',
        ),
        // Day -3
        GlucoseReading(
          id: _uuid.v4(),
          value: 124,
          timestamp: now.subtract(const Duration(days: 3, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 148,
          timestamp: now.subtract(const Duration(days: 3, hours: 4)),
          mealContext: MealContext.afterDinner,
        ),
        // Day -2
        GlucoseReading(
          id: _uuid.v4(),
          value: 126,
          timestamp: now.subtract(const Duration(days: 2, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 151,
          timestamp: now.subtract(const Duration(days: 2, hours: 4)),
          mealContext: MealContext.afterDinner,
          note: 'Metformin evening missed',
        ),
        // Day -1
        GlucoseReading(
          id: _uuid.v4(),
          value: 128,
          timestamp: now.subtract(const Duration(days: 1, hours: 14)),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 158,
          timestamp: now.subtract(const Duration(days: 1, hours: 4)),
          mealContext: MealContext.afterDinner,
        ),
        // Today
        GlucoseReading(
          id: _uuid.v4(),
          value: 128,
          timestamp: DateTime(now.year, now.month, now.day, 8, 30),
          mealContext: MealContext.fasting,
          note: 'Morning fasting check',
        ),
      ];
      glucoseList = pastDays;

      // Medication logs (9 of 10 taken - 90% adherence)
      medLogsList = [
        // Today's Meds
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 9, 0),
          status: MedicationStatus.taken,
          takenAt: DateTime(now.year, now.month, now.day, 9, 15),
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_glimepiride_lunch',
          medicationName: 'Glimepiride',
          dosage: '1 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 13, 0),
          status: MedicationStatus.taken,
          takenAt: DateTime(now.year, now.month, now.day, 13, 5),
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_eve',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 20, 0),
          status: MedicationStatus.pending,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_atorvastatin_night',
          medicationName: 'Atorvastatin',
          dosage: '10 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 22, 0),
          status: MedicationStatus.pending,
        ),
        // Yesterday
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 1)),
          status: MedicationStatus.taken,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_eve',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 1)),
          status: MedicationStatus.missed,
        ),
        // 2 days ago
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 2)),
          status: MedicationStatus.taken,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_eve',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 2)),
          status: MedicationStatus.taken,
        ),
        // 3 days ago
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 3)),
          status: MedicationStatus.taken,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_eve',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: now.subtract(const Duration(days: 3)),
          status: MedicationStatus.taken,
        ),
      ];

      // Pre-seed initial food query sample (Dosa)
      foodQueriesList = [
        AIFoodService.evaluateFood(
          query: 'Can I eat dosa?',
          latestGlucose: 128,
          missedRecentMed: true,
        ),
      ];

      // Pre-seed caregiver alerts
      alertsList = [
        CaregiverAlert(
          id: _uuid.v4(),
          title: 'Evening Glucose Trend Detected',
          message:
              'Rajesh\'s evening blood glucose has been elevated (148-158 mg/dL) for the past 4 days.',
          timestamp: now.subtract(const Duration(hours: 2)),
          severity: 'warning',
        ),
      ];
    } else if (scenarioIndex == 2) {
      // SCENARIO 2: Post-Prandial Spike (194 mg/dL after high carb meal)
      glucoseList = [
        GlucoseReading(
          id: _uuid.v4(),
          value: 112,
          timestamp: DateTime(now.year, now.month, now.day, 8, 0),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 194,
          timestamp: DateTime(now.year, now.month, now.day, 14, 30),
          mealContext: MealContext.afterLunch,
          note: 'Attended family function (Biryani & Gulab Jamun)',
        ),
      ];

      medLogsList = [
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 9, 0),
          status: MedicationStatus.taken,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_glimepiride_lunch',
          medicationName: 'Glimepiride',
          dosage: '1 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 13, 0),
          status: MedicationStatus.missed,
        ),
      ];

      foodQueriesList = [
        AIFoodService.evaluateFood(
          query: 'Can I eat Gulab Jamun?',
          latestGlucose: 194,
        ),
      ];

      alertsList = [
        CaregiverAlert(
          id: _uuid.v4(),
          title: 'Post-Meal High Glucose Spike',
          message: 'Rajesh logged a reading of 194 mg/dL after lunch.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          severity: 'alert',
        ),
      ];
    } else {
      // SCENARIO 3: Stable & Well Controlled
      glucoseList = [
        GlucoseReading(
          id: _uuid.v4(),
          value: 104,
          timestamp: DateTime(now.year, now.month, now.day, 8, 0),
          mealContext: MealContext.fasting,
        ),
        GlucoseReading(
          id: _uuid.v4(),
          value: 126,
          timestamp: DateTime(now.year, now.month, now.day, 13, 45),
          mealContext: MealContext.afterLunch,
        ),
      ];

      medLogsList = [
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_metformin_morn',
          medicationName: 'Metformin',
          dosage: '500 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 9, 0),
          status: MedicationStatus.taken,
        ),
        MedicationLog(
          id: _uuid.v4(),
          medicationId: 'med_glimepiride_lunch',
          medicationName: 'Glimepiride',
          dosage: '1 mg',
          scheduledDate: DateTime(now.year, now.month, now.day, 13, 0),
          status: MedicationStatus.taken,
        ),
      ];

      foodQueriesList = [
        AIFoodService.evaluateFood(
          query: 'Is Oatmeal good for breakfast?',
          latestGlucose: 104,
        ),
      ];

      alertsList = [];
    }

    final insight = PatternDetectionService.analyzeHealthPattern(
      glucoseLogs: glucoseList,
      medLogs: medLogsList,
      baselineMin: profile.targetMinGlucose,
      baselineMax: profile.targetMaxGlucose,
    );

    // Save all to local preferences
    final result = {
      'profile': profile,
      'glucoseList': glucoseList,
      'medsList': medsList,
      'medLogsList': medLogsList,
      'foodQueriesList': foodQueriesList,
      'alertsList': alertsList,
      'activeInsight': insight,
      'scenario': scenarioIndex,
    };

    await saveAllData(
      profile: profile,
      glucoseList: glucoseList,
      medsList: medsList,
      medLogsList: medLogsList,
      foodQueriesList: foodQueriesList,
      alertsList: alertsList,
      scenario: scenarioIndex,
    );

    return result;
  }

  static Future<void> saveAllData({
    required UserProfile profile,
    required List<GlucoseReading> glucoseList,
    required List<Medication> medsList,
    required List<MedicationLog> medLogsList,
    required List<FoodQuery> foodQueriesList,
    required List<CaregiverAlert> alertsList,
    required int scenario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, jsonEncode(profile.toJson()));
    await prefs.setString(
      _kGlucoseKey,
      jsonEncode(glucoseList.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kMedsKey,
      jsonEncode(medsList.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kMedLogsKey,
      jsonEncode(medLogsList.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kFoodQueriesKey,
      jsonEncode(foodQueriesList.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kAlertsKey,
      jsonEncode(alertsList.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt(_kScenarioKey, scenario);
  }

  static List<T> _decodeList<T>(
    String? jsonStr,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
