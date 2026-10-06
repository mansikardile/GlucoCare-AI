import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';

class AddMedicationModal extends StatefulWidget {
  const AddMedicationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddMedicationModal(),
    );
  }

  @override
  State<AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends State<AddMedicationModal> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(text: '500 mg');
  final _instructionsController = TextEditingController(text: 'After meal with water');
  TimeOfDaySlot _selectedSlot = TimeOfDaySlot.morning;
  String _timeString = '9:00 AM';

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveMedication() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    final provider = Provider.of<HealthProvider>(context, listen: false);
    provider.addNewMedication(
      name: name,
      dosage: _dosageController.text.trim().isNotEmpty ? _dosageController.text.trim() : '1 dose',
      instructions: _instructionsController.text.trim(),
      slot: _selectedSlot,
      timeString: _timeString,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                  'Add Medicine',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Medicine Name
            Text('Medicine Name', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                hintText: 'e.g. Metformin, Glimepiride, Januvia',
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                prefixIcon: const Icon(Icons.medication_rounded, color: AppTheme.primaryBlue),
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
            const SizedBox(height: 16),

            // Dosage
            Text('Dosage / Strength', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                hintText: 'e.g. 500 mg, 1 tablet, 10 units',
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                prefixIcon: const Icon(Icons.local_pharmacy_rounded, color: AppTheme.primaryBlue),
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
            const SizedBox(height: 16),

            // Timing Slot
            Text('Time of Day', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimeOfDaySlot.values.map((slot) {
                final isSelected = slot == _selectedSlot;
                return ChoiceChip(
                  label: Text('${slot.icon} ${slot.title}'),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: AppTheme.surfaceAlt,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSlot = slot;
                        if (slot == TimeOfDaySlot.morning) _timeString = '9:00 AM';
                        if (slot == TimeOfDaySlot.afternoon) _timeString = '1:00 PM';
                        if (slot == TimeOfDaySlot.evening) _timeString = '8:00 PM';
                        if (slot == TimeOfDaySlot.bedtime) _timeString = '10:00 PM';
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Instructions
            Text('Instructions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. After breakfast with water',
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                prefixIcon: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
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

            ElevatedButton(
              onPressed: _saveMedication,
              child: const Text('Add to Schedule', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
