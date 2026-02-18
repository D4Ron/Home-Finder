import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/common/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final void Function(double? minPrice, double? maxPrice, int? minBeds) onApply;
  const FilterBottomSheet({super.key, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  int? _beds;

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final min = double.tryParse(_minCtrl.text.replaceAll(' ', ''));
    final max = double.tryParse(_maxCtrl.text.replaceAll(' ', ''));
    widget.onApply(min, max, _beds);
    Navigator.pop(context);
  }

  void _reset() {
    _minCtrl.clear();
    _maxCtrl.clear();
    setState(() => _beds = null);
    widget.onApply(null, null, null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg, AppSizes.lg, AppSizes.lg,
        AppSizes.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text('Filtres',
              style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.lg),

          const Text('Fourchette de prix (Fcfa)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Text('—'),
              ),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          const Text('Chambres minimum',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [null, 1, 2, 3, 4].map((n) {
              final label = n == null ? 'Tous' : '$n+';
              final sel   = _beds == n;
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _beds = n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: AppSizes.sm),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.textLight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          color: sel ? AppColors.textWhite : AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSizes.xl),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: 'Réinitialiser',
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  label: 'Appliquer',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}