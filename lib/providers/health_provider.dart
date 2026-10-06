import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../models/food_query.dart';
import '../models/health_insight.dart';
import '../models/caregiver_alert.dart';
import '../services/ai_food_service.dart';
import '../services/database_service.dart';
import '../services/pattern_detection_service.dart';

class HealthProvider extends ChangeNotifier {
  bool _isLoading = true;
  final _uuid = const Uuid();

  late UserProfile _profile;
  List<GlucoseReading> _glucoseList = [];
  List<Medication> _medsList = [];
  List<MedicationLog> _medLogsList = [];
  List<FoodQuery> _foodQueriesList = [];
  List<CaregiverAlert> _alertsList = [];
  late HealthInsight _activeInsight;
  int _activeScenario = 1;

  // Caregiver Mode toggle
  bool _isCaregiverMode = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCaregiverMode => _isCaregiverMode;
  UserProfile get profile => _profile;
  List<GlucoseReading> get glucoseList => _glucoseList;
  List<Medication> get medsList => _medsList;
  List<MedicationLog> get medLogsList => _medLogsList;
  List<FoodQuery> get foodQueriesList => _foodQueriesList;
  List<CaregiverAlert> get alertsList => _alertsList;
  HealthInsight get activeInsight => _activeInsight;
  int get activeScenario => _activeScenario;

  // Computed metrics
  GlucoseReading? get latestGlucose {
    if (_glucoseList.isEmpty) return null;
    final sorted = List<GlucoseReading>.from(_glucoseList)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first;
  }

  double get averageGlucose {
    if (_glucoseList.isEmpty) return 0;
    final sum = _glucoseList.fold<double>(0, (p, c) => p + c.value);
    return sum / _glucoseList.length;
  }

  double get highestGlucose {
    if (_glucoseList.isEmpty) return 0;
    return _glucoseList.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  double get lowestGlucose {
    if (_glucoseList.isEmpty) return 0;
    return _glucoseList.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  int get totalDosesCount => _medLogsList.length;

  int get takenDosesCount =>
      _medLogsList.where((m) => m.status == MedicationStatus.taken).length;

  double get adherenceRate {
    if (_medLogsList.isEmpty) return 1.0;
    return takenDosesCount / _medLogsList.length;
  }

  List<MedicationLog> get todayMedLogs {
    final now = DateTime.now();
    return _medLogsList.where((m) {
      return m.scheduledDate.year == now.year &&
          m.scheduledDate.month == now.month &&
          m.scheduledDate.day == now.day;
    }).toList();
  }

  MedicationLog? get nextPendingMed {
    final pending = todayMedLogs.where((m) => m.status == MedicationStatus.pending).toList();
    if (pending.isNotEmpty) return pending.first;
    return null;
  }

  // Initialization
  HealthProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final data = await DatabaseService.initializeData();
    _profile = data['profile'] as UserProfile;
    _glucoseList = data['glucoseList'] as List<GlucoseReading>;
    _medsList = data['medsList'] as List<Medication>;
    _medLogsList = data['medLogsList'] as List<MedicationLog>;
    _foodQueriesList = data['foodQueriesList'] as List<FoodQuery>;
    _alertsList = data['alertsList'] as List<CaregiverAlert>;
    _activeInsight = data['activeInsight'] as HealthInsight;
    _activeScenario = data['scenario'] as int;

    _isLoading = false;
    notifyListeners();
  }

  void toggleCaregiverMode(bool value) {
    _isCaregiverMode = value;
    notifyListeners();
  }

  Future<void> switchScenario(int scenarioIndex) async {
    _isLoading = true;
    notifyListeners();

    final data = await DatabaseService.seedScenario(scenarioIndex);
    _profile = data['profile'] as UserProfile;
    _glucoseList = data['glucoseList'] as List<GlucoseReading>;
    _medsList = data['medsList'] as List<Medication>;
    _medLogsList = data['medLogsList'] as List<MedicationLog>;
    _foodQueriesList = data['foodQueriesList'] as List<FoodQuery>;
    _alertsList = data['alertsList'] as List<CaregiverAlert>;
    _activeInsight = data['activeInsight'] as HealthInsight;
    _activeScenario = scenarioIndex;

    _isLoading = false;
    notifyListeners();
  }

  // Glucose Actions
  Future<void> logGlucose({
    required double value,
    required MealContext mealContext,
    String? note,
    DateTime? customTimestamp,
  }) async {
    final reading = GlucoseReading(
      id: _uuid.v4(),
      value: value,
      timestamp: customTimestamp ?? DateTime.now(),
      mealContext: mealContext,
      note: note,
    );

    _glucoseList.insert(0, reading);
    _recomputeInsights();
    await _persist();
    notifyListeners();
  }

  // Medication Actions
  Future<void> updateMedicationStatus(String logId, MedicationStatus status) async {
    final index = _medLogsList.indexWhere((m) => m.id == logId);
    if (index != -1) {
      _medLogsList[index] = _medLogsList[index].copyWith(
        status: status,
        takenAt: status == MedicationStatus.taken ? DateTime.now() : null,
      );
      _recomputeInsights();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> addNewMedication({
    required String name,
    required String dosage,
    required String instructions,
    required TimeOfDaySlot slot,
    required String timeString,
  }) async {
    final newMed = Medication(
      id: _uuid.v4(),
      name: name,
      dosage: dosage,
      instructions: instructions,
      slot: slot,
      timeString: timeString,
    );
    _medsList.add(newMed);

    // Create a today log for it
    final now = DateTime.now();
    _medLogsList.insert(
      0,
      MedicationLog(
        id: _uuid.v4(),
        medicationId: newMed.id,
        medicationName: newMed.name,
        dosage: newMed.dosage,
        scheduledDate: now,
        status: MedicationStatus.pending,
      ),
    );

    await _persist();
    notifyListeners();
  }

  // Food Advisor Actions
  Future<FoodQuery> askFoodAdvisor(String query) async {
    final latestVal = latestGlucose?.value;
    final hasMissed = _medLogsList.any((m) => m.status == MedicationStatus.missed);

    final result = await AIFoodService.evaluateFoodAsync(
      query: query,
      latestGlucose: latestVal,
      missedRecentMed: hasMissed,
      patientName: _profile.name,
      patientAge: _profile.age,
    );

    _foodQueriesList.insert(0, result);
    await _persist();
    notifyListeners();
    return result;
  }

  // Caregiver Alert dispatch
  Future<void> sendInsightToCaregiver() async {
    _activeInsight = _activeInsight.copyWith(sentToCaregiver: true);

    final newAlert = CaregiverAlert(
      id: _uuid.v4(),
      title: 'Alert: ${_activeInsight.title}',
      message:
          '${_profile.name}\'s glucose has been outside usual target range. ${_activeInsight.patternSummary}',
      timestamp: DateTime.now(),
      severity: _activeInsight.severity == InsightSeverity.critical
          ? 'alert'
          : 'warning',
    );

    _alertsList.insert(0, newAlert);
    await _persist();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    await _persist();
    notifyListeners();
  }

  void _recomputeInsights() {
    _activeInsight = PatternDetectionService.analyzeHealthPattern(
      glucoseLogs: _glucoseList,
      medLogs: _medLogsList,
      baselineMin: _profile.targetMinGlucose,
      baselineMax: _profile.targetMaxGlucose,
    );
  }

  Future<void> _persist() async {
    await DatabaseService.saveAllData(
      profile: _profile,
      glucoseList: _glucoseList,
      medsList: _medsList,
      medLogsList: _medLogsList,
      foodQueriesList: _foodQueriesList,
      alertsList: _alertsList,
      scenario: _activeScenario,
    );
  }
}
