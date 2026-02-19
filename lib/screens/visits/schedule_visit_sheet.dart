import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/visit_provider.dart';

class ScheduleVisitSheet extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const ScheduleVisitSheet({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<ScheduleVisitSheet> createState() => _ScheduleVisitSheetState();
}

class _ScheduleVisitSheetState extends State<ScheduleVisitSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir une date et une heure'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final scheduled = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() => _submitting = true);

    final ok = await context.read<VisitProvider>().scheduleVisit(
      propertyId: widget.propertyId,
      scheduledDate: scheduled,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visite planifiée avec succès !'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la planification'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Planifier une visite',
            style: TextStyle(
                fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            widget.propertyTitle,
            style: const TextStyle(
                color: AppColors.textGrey, fontSize: AppSizes.fontSm),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.lg),

          // Date picker
          const Text('Date',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textLight),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    _selectedDate != null
                        ? dateFmt.format(_selectedDate!)
                        : 'Choisir une date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Time picker
          const Text('Heure',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textLight),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Choisir une heure',
                    style: TextStyle(
                      color: _selectedTime != null
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Notes
          const Text('Notes (optionnel)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Je viendrai avec mon épouse...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide:
                const BorderSide(color: AppColors.textLight),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonH,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white)),
              )
                  : const Text('Confirmer la visite'),
            ),
          ),
        ],
      ),
    );
  }
}