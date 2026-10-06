import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_medication_modal.dart';
import '../widgets/senior_card.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HealthProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final todayLogs = provider.todayMedLogs;
    final adherence = provider.adherenceRate;
    final takenCount = provider.takenDosesCount;
    final totalCount = provider.totalDosesCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            tooltip: 'Add Medicine',
            onPressed: () => AddMedicationModal.show(context),
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
              // 1. Weekly Adherence Card
              SeniorCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adherence this week',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${(adherence * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
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
                        minHeight: 14,
                        backgroundColor: AppTheme.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          adherence >= 0.85 ? AppTheme.successGreen : AppTheme.warningAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$takenCount of $totalCount prescribed doses completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Today's Medicine List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TODAY\'S SCHEDULE',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMM').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (todayLogs.isEmpty) ...[
                SeniorCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('💊', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        Text('No medications scheduled for today', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final log = todayLogs[idx];
                    return _buildMedicationCard(context, log, provider);
                  },
                ),
              ],
              const SizedBox(height: 20),

              // Add Medicine Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceAlt,
                  foregroundColor: AppTheme.primaryBlue,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add, size: 22, color: AppTheme.primaryBlue),
                label: const Text(
                  '+ Add New Medicine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                onPressed: () => AddMedicationModal.show(context),
              ),
              const SizedBox(height: 24),

              // Prescribed Daily Schedule reference
              Text(
                'YOUR PRESCRIBED REGIMEN',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              ...provider.medsList.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Text(m.slot.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${m.name} (${m.dosage})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${m.timeString} · ${m.instructions}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context,
    MedicationLog log,
    HealthProvider provider,
  ) {
    final isTaken = log.status == MedicationStatus.taken;
    final isMissed = log.status == MedicationStatus.missed;

    Color borderColor = AppTheme.borderLight;
    Color bgColor = AppTheme.surface;
    if (isTaken) {
      borderColor = AppTheme.successGreen.withValues(alpha: 0.4);
      bgColor = AppTheme.successBg.withValues(alpha: 0.4);
    } else if (isMissed) {
      borderColor = AppTheme.dangerCoral.withValues(alpha: 0.4);
      bgColor = AppTheme.dangerBg.withValues(alpha: 0.4);
    }

    return SeniorCard(
      backgroundColor: bgColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isTaken ? AppTheme.successBg : AppTheme.primaryBlueSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isTaken ? '✓' : '💊',
                  style: TextStyle(
                    fontSize: 22,
                    color: isTaken ? AppTheme.successGreen : AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${log.medicationName} ${log.dosage}',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('h:mm a').format(log.scheduledDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(log.status),
            ],
          ),
          const SizedBox(height: 14),

          // Actions
          if (!isTaken) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('✓ Taken', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      provider.updateMedicationStatus(log.id, MedicationStatus.taken);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: const BorderSide(color: AppTheme.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Missed', style: TextStyle(color: AppTheme.textSecondary)),
                  onPressed: () {
                    provider.updateMedicationStatus(log.id, MedicationStatus.missed);
                  },
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taken at ${log.takenAt != null ? DateFormat('h:mm a').format(log.takenAt!) : 'scheduled time'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successGreen,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    provider.updateMedicationStatus(log.id, MedicationStatus.pending);
                  },
                  child: const Text('Undo', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPill(MedicationStatus status) {
    Color color;
    Color bg;
    switch (status) {
      case MedicationStatus.taken:
        color = AppTheme.successGreen;
        bg = AppTheme.successBg;
        break;
      case MedicationStatus.missed:
        color = AppTheme.dangerCoral;
        bg = AppTheme.dangerBg;
        break;
      case MedicationStatus.pending:
        color = AppTheme.primaryBlue;
        bg = AppTheme.primaryBlueSoft;
        break;
      case MedicationStatus.snoozed:
        color = AppTheme.warningAmber;
        bg = AppTheme.warningBg;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
