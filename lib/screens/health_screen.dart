import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/glucose_reading.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_insight_sheet.dart';
import '../widgets/log_glucose_modal.dart';
import '../widgets/senior_card.dart';
import '../widgets/status_badge.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HealthProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final latest = provider.latestGlucose;
    final avg = provider.averageGlucose;
    final high = provider.highestGlucose;
    final low = provider.lowestGlucose;
    final adherence = provider.adherenceRate;
    final takenCount = provider.takenDosesCount;
    final totalCount = provider.totalDosesCount;
    final insight = provider.activeInsight;

    // Prepare chart data from 7 days
    final sortedAsc = List<GlucoseReading>.from(provider.glucoseList)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final recentPoints = sortedAsc.length > 7 ? sortedAsc.sublist(sortedAsc.length - 7) : sortedAsc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            tooltip: 'Log Glucose',
            onPressed: () => LogGlucoseModal.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BLOOD SUGAR HERO & 7-DAY CHART CARD
              SeniorCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('🩸', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Blood Sugar Trends',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (latest != null)
                          Text(
                            '${latest.value.toInt()} mg/dL',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _getGlucoseColor(latest.value),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last 7 days readings with target range band (90-140 mg/dL)',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Interactive Line Chart
                    SizedBox(
                      height: 180,
                      child: recentPoints.isEmpty
                          ? const Center(child: Text('No glucose records yet.'))
                          : LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: (recentPoints.length - 1).toDouble().clamp(1.0, 10.0),
                                minY: 60,
                                maxY: 200,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 40,
                                  getDrawingHorizontalLine: (val) {
                                    if (val == 140 || val == 90) {
                                      return FlLine(
                                        color: AppTheme.successGreen.withValues(alpha: 0.3),
                                        strokeWidth: 1.5,
                                        dashArray: [5, 5],
                                      );
                                    }
                                    return FlLine(
                                      color: AppTheme.borderLight,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      interval: 40,
                                      getTitlesWidget: (val, meta) => Text(
                                        '${val.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (val, meta) {
                                        final idx = val.toInt();
                                        if (idx >= 0 && idx < recentPoints.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              DateFormat('E').format(recentPoints[idx].timestamp),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(recentPoints.length, (i) {
                                      return FlSpot(i.toDouble(), recentPoints[i].value);
                                    }),
                                    isCurved: true,
                                    curveSmoothness: 0.35,
                                    color: AppTheme.primaryBlue,
                                    barWidth: 3.5,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        final isHigh = spot.y > 140;
                                        return FlDotCirclePainter(
                                          radius: 5.5,
                                          color: isHigh ? AppTheme.warningAmber : AppTheme.primaryBlue,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.primaryBlueLight.withValues(alpha: 0.25),
                                          AppTheme.primaryBlueLight.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. SUMMARY METRICS (Average, Highest, Lowest)
              Row(
                children: [
                  Expanded(
                    child: _metricBox(
                      label: 'Average',
                      value: '${avg.toInt()}',
                      unit: 'mg/dL',
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'Highest',
                      value: '${high.toInt()}',
                      unit: 'mg/dL',
                      color: AppTheme.dangerCoral,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'Lowest',
                      value: '${low.toInt()}',
                      unit: 'mg/dL',
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. MEDICATION ADHERENCE CARD
              SeniorCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medication Adherence',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${(adherence * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: adherence >= 0.85
                                ? AppTheme.successGreen
                                : AppTheme.warningAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: adherence.clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: AppTheme.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          adherence >= 0.85 ? AppTheme.successGreen : AppTheme.warningAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$takenCount of $totalCount doses taken on schedule this week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. DETECTED AI PATTERN BANNER
              SeniorCard(
                backgroundColor: AppTheme.warningBg,
                borderColor: AppTheme.warningAmber.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight.title,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.warningAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.patternSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningAmber,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.psychology_alt_rounded, size: 20),
                      label: const Text(
                        'See AI Explanation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => AIInsightSheet.show(context, insight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. RECENT READINGS LIST
              Text(
                'RECENT READINGS',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.glucoseList.take(6).length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final reading = provider.glucoseList[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reading.mealContext.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                DateFormat('EEE, d MMM · h:mm a').format(reading.timestamp),
                                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                              if (reading.note != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  reading.note!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${reading.value.toInt()} mg/dL',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _getGlucoseColor(reading.value),
                              ),
                            ),
                            const SizedBox(height: 3),
                            StatusBadge.fromGlucose(reading.status, isCompact: true),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
        ],
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
