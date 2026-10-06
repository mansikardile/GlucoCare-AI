import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/glucose_reading.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';

class LogGlucoseModal extends StatefulWidget {
  final double? initialValue;
  final MealContext? initialContext;

  const LogGlucoseModal({
    super.key,
    this.initialValue,
    this.initialContext,
  });

  static Future<void> show(BuildContext context, {double? initialValue, MealContext? initialContext}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogGlucoseModal(
        initialValue: initialValue,
        initialContext: initialContext,
      ),
    );
  }

  @override
  State<LogGlucoseModal> createState() => _LogGlucoseModalState();
}

class _LogGlucoseModalState extends State<LogGlucoseModal> {
  late double _glucoseValue;
  late MealContext _selectedContext;
  final TextEditingController _noteController = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _glucoseValue = widget.initialValue ?? 128.0;
    _selectedContext = widget.initialContext ?? MealContext.afterDinner;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _adjustGlucose(double delta) {
    setState(() {
      _glucoseValue = (_glucoseValue + delta).clamp(40.0, 450.0);
    });
  }

  void _saveReading() {
    final provider = Provider.of<HealthProvider>(context, listen: false);
    provider.logGlucose(
      value: _glucoseValue,
      mealContext: _selectedContext,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    setState(() {
      _saved = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_saved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.successBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.successGreen, width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.successGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '✓ Reading Saved',
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_glucoseValue.toInt()} mg/dL · ${_selectedContext.label}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your reading has been added to today\'s health record and AI insights have been updated.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log Blood Sugar',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Number Stepper / Value Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlueSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryBlueLight.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'How much is your reading?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      _adjustButton(
                        icon: Icons.remove,
                        onTap: () => _adjustGlucose(-1),
                        onLongPress: () => _adjustGlucose(-5),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            '${_glucoseValue.toInt()}',
                            style: GoogleFonts.outfit(
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              color: _getGlucoseColor(_glucoseValue),
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'mg/dL',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Plus button
                      _adjustButton(
                        icon: Icons.add,
                        onTap: () => _adjustGlucose(1),
                        onLongPress: () => _adjustGlucose(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick adjustment chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _quickStepChip('-10', () => _adjustGlucose(-10)),
                      const SizedBox(width: 8),
                      _quickStepChip('-5', () => _adjustGlucose(-5)),
                      const SizedBox(width: 8),
                      _quickStepChip('+5', () => _adjustGlucose(5)),
                      const SizedBox(width: 8),
                      _quickStepChip('+10', () => _adjustGlucose(10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal Context Selection
            Text(
              'When was this reading taken?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealContext.values.map((ctx) {
                final isSelected = ctx == _selectedContext;
                return ChoiceChip(
                  label: Text(
                    ctx.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: AppTheme.surfaceAlt,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                      width: 1.4,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedContext = ctx;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Optional note
            TextField(
              controller: _noteController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Add note (e.g. After 2 dosas + tea)',
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                prefixIcon: const Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveReading,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 24),
                  SizedBox(width: 8),
                  Text('Save Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adjustButton({
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 28, color: AppTheme.primaryBlue),
        ),
      ),
    );
  }

  Widget _quickStepChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: 13,
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
