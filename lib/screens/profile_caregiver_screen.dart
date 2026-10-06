import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../services/ai_food_service.dart';
import '../theme/app_theme.dart';
import '../widgets/senior_card.dart';

class ProfileCaregiverScreen extends StatelessWidget {
  const ProfileCaregiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isCaregiver = provider.isCaregiverMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCaregiver ? 'Caregiver Dashboard' : 'Profile & Family Care'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. VIEW TOGGLE BAR (Senior Mode vs Caregiver Mode)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.toggleCaregiverMode(false),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isCaregiver ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !isCaregiver ? AppTheme.cardShadow : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👴', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'Senior View',
                                style: TextStyle(
                                  fontWeight: !isCaregiver ? FontWeight.w800 : FontWeight.w500,
                                  color: !isCaregiver ? AppTheme.primaryBlue : AppTheme.textMuted,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.toggleCaregiverMode(true),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isCaregiver ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isCaregiver ? AppTheme.cardShadow : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👩', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'Caregiver View',
                                style: TextStyle(
                                  fontWeight: isCaregiver ? FontWeight.w800 : FontWeight.w500,
                                  color: isCaregiver ? AppTheme.primaryBlue : AppTheme.textMuted,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CAREGIVER VIEW CONTENT
              if (isCaregiver) ...[
                _buildCaregiverView(context, provider),
              ] else ...[
                // SENIOR PROFILE VIEW CONTENT
                _buildSeniorProfileView(context, provider),
              ],

              const SizedBox(height: 24),

              // 3. DEMO SCENARIOS PICKER (FOR HACKATHON JUDGES)
              Text(
                'DEMO SCENARIO SWITCHER',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _scenarioTile(
                      context,
                      provider,
                      index: 1,
                      title: 'Scenario 1: Evening Rise + Missed Dose',
                      subtitle: 'Primary PS Demo flow: 158 mg/dL spike, evening pattern & caregiver alert',
                      isActive: provider.activeScenario == 1,
                    ),
                    const Divider(height: 16),
                    _scenarioTile(
                      context,
                      provider,
                      index: 2,
                      title: 'Scenario 2: Post-Carb Spike (194 mg/dL)',
                      subtitle: 'Spike after family meal; AI advises portion moderation',
                      isActive: provider.activeScenario == 2,
                    ),
                    const Divider(height: 16),
                    _scenarioTile(
                      context,
                      provider,
                      index: 3,
                      title: 'Scenario 3: Stable Controlled Baseline',
                      subtitle: '104 mg/dL in range, 100% medication adherence',
                      isActive: provider.activeScenario == 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. REAL GEMINI LLM API CONFIGURATION TILE
              Text(
                'LIVE GEMINI AI ENGINE',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              SeniorCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlueSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Gemini 1.5 Flash',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Text(
                            'Tap to configure custom Gemini API Key for live AI responses',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Config', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      onPressed: () => _showApiKeyDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaregiverView(BuildContext context, HealthProvider provider) {
    final profile = provider.profile;
    final latest = provider.latestGlucose;
    final adherence = provider.adherenceRate;
    final insight = provider.activeInsight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Caregiver Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Text('👩', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.caregiverName} (${profile.caregiverRelation})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFF4ADE80), size: 10),
                              SizedBox(width: 6),
                              Text(
                                'Live Synced to Rajesh\'s App',
                                style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rajesh's Health Snapshot Cards
        SeniorCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profile.name}\'s Current Health',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🩸 Glucose', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            latest != null ? '${latest.value.toInt()} mg/dL' : '--',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: latest != null
                                  ? (latest.value > 140 ? AppTheme.warningAmber : AppTheme.successGreen)
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💊 Medication', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            '${(adherence * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: adherence >= 0.85 ? AppTheme.successGreen : AppTheme.warningAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Attention Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.warningAmber,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            insight.patternSummary,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Call Rajesh'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling +91 98123 45678...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        side: const BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.notifications_active_outlined, size: 18, color: AppTheme.primaryBlue),
                      label: const Text('Send Reminder', style: TextStyle(color: AppTheme.primaryBlue)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Reminder notification sent to Rajesh!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live Alerts Feed
        Text(
          'CAREGIVER NOTIFICATIONS & ALERTS',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        if (provider.alertsList.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Center(
              child: Text(
                'No pending alerts. Everything is normal.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ] else ...[
          ...provider.alertsList.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: alert.severity == 'alert'
                      ? AppTheme.dangerCoral.withValues(alpha: 0.3)
                      : AppTheme.warningAmber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.severity == 'alert' ? '🚨' : '⚠️',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.message,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM, h:mm a').format(alert.timestamp),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSeniorProfileView(BuildContext context, HealthProvider provider) {
    final profile = provider.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient Card
        SeniorCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryBlueSoft,
                    child: Text('👴', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Age: ${profile.age} · ${profile.diabetesType}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),

              // Preferences & Target
              _profileRow(label: 'Dietary Preference', value: '🍛 ${profile.dietaryPreference}'),
              const SizedBox(height: 8),
              _profileRow(
                label: 'Safe Target Range',
                value: '${profile.targetMinGlucose.toInt()} - ${profile.targetMaxGlucose.toInt()} mg/dL',
              ),
              const SizedBox(height: 8),
              _profileRow(
                label: 'Connected Caregiver',
                value: '👩 ${profile.caregiverName} (${profile.caregiverRelation})',
              ),
              const SizedBox(height: 8),
              _profileRow(label: 'Caregiver Alerts', value: '🔔 ON (Instant WhatsApp/Push)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Emergency Contact Card
        SeniorCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: AppTheme.dangerBg.withValues(alpha: 0.5),
          borderColor: AppTheme.dangerCoral.withValues(alpha: 0.3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emergency_rounded, color: AppTheme.dangerCoral, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency SOS Contact',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.dangerCoral,
                      ),
                    ),
                    Text(
                      '${profile.caregiverName} · ${profile.caregiverPhone}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerCoral,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.dangerCoral,
                      content: Text('🚨 Emergency alert dispatched to Caregiver!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scenarioTile(
    BuildContext context,
    HealthProvider provider, {
    required int index,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () async {
        await provider.switchScenario(index);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.primaryBlue,
              content: Text('Switched to $title'),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isActive ? AppTheme.primaryBlue : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showApiKeyDialog(BuildContext context) async {
    final currentKey = await AIFoodService.getApiKey() ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Gemini API Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API key to enable live LLM reasoning for any open-ended food or clinical query.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () async {
              await AIFoodService.saveApiKey(controller.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.successGreen,
                    content: Text(
                      controller.text.trim().isNotEmpty
                          ? '✓ Gemini API key saved! Live LLM active.'
                          : 'Gemini API key cleared. Using local clinical engine.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
