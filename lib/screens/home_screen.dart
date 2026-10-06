import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_insight_sheet.dart';
import '../widgets/log_glucose_modal.dart';
import '../widgets/senior_card.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HealthProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = provider.profile;
    final latestGlucose = provider.latestGlucose;
    final nextMed = provider.nextPendingMed;
    final insight = provider.activeInsight;
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.init(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Senior Greeting Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, ${profile.name.split(' ').first} 👋',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateString,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick Caregiver Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlueSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryBlueLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('👩', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            profile.caregiverName.split(' ').first,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1️⃣ HERO CARD: Blood Sugar Status
                SeniorCard(
                  hasActiveGlow: true,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.dangerBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('🩸', style: TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Blood Sugar',
                                style: GoogleFonts.outfit(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (latestGlucose != null)
                            Text(
                              DateFormat('h:mm a').format(latestGlucose.timestamp),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            latestGlucose != null ? '${latestGlucose.value.toInt()}' : '--',
                            style: GoogleFonts.outfit(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: latestGlucose != null
                                  ? _getGlucoseColor(latestGlucose.value)
                                  : AppTheme.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'mg/dL',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (latestGlucose != null) ...[
                        Row(
                          children: [
                            Flexible(
                              child: StatusBadge.fromGlucose(latestGlucose.status),
                            ),
                            if (latestGlucose.mealContext != MealContext.random) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${latestGlucose.mealContext.label}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        label: const Text(
                          'Log Reading',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => LogGlucoseModal.show(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION TITLE: TODAY
                Text(
                  'TODAY',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // 2️⃣ TODAY'S MEDICATION CARD
                if (nextMed != null) ...[
                  SeniorCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlueSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('💊', style: TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Medicine',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${nextMed.medicationName} ${nextMed.dosage}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(nextMed.scheduledDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successGreen,
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.check_rounded, size: 20),
                                label: const Text(
                                  '✓ Taken',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  provider.updateMedicationStatus(
                                    nextMed.id,
                                    MedicationStatus.taken,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.successGreen,
                                      content: Text('✓ ${nextMed.medicationName} marked as taken!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Later',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                onPressed: () {
                                  provider.updateMedicationStatus(
                                    nextMed.id,
                                    MedicationStatus.snoozed,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SeniorCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Medicines Taken!',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'You have completed all scheduled doses for today.',
                                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // 3️⃣ NEXT MEAL CARD
                SeniorCard(
                  onTap: () => onNavigateTab?.call(2), // Jump to Food Advisor tab
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🍽️', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Meal · 9:30 AM',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              'Breakfast Planning',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Ask AI',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: AppTheme.primaryBlue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4️⃣ AI TODAY'S INSIGHT CARD
                SeniorCard(
                  backgroundColor: AppTheme.warningBg,
                  borderColor: AppTheme.warningAmber.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Today\'s Health Insight',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.warningAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.patternSummary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () => AIInsightSheet.show(context, insight),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View AI Explanation & Why',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warningAmber,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.warningAmber),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGlucoseColor(double value) {
    if (value < 70) return AppTheme.dangerCoral;
    if (value <= 140) return AppTheme.successGreen;
    if (value <= 180) return AppTheme.warningAmber;
    return AppTheme.dangerCoral;
  }
}
