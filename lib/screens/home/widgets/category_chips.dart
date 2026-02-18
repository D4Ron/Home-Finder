import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CategoryChips extends StatelessWidget {
  final String?        active;
  final ValueChanged<String?> onSelect;

  const CategoryChips({super.key, this.active, required this.onSelect});

  static const _types = {
    null:        'Tous',
    'HOUSE':     'Maison',
    'APARTMENT': 'Appartement',
    'VILLA':     'Villa',
    'STUDIO':    'Studio',
    'HOTEL':     'Hôtel',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        children: _types.entries.map((e) {
          final isActive = e.key == active;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.textLight,
                  ),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: isActive ? AppColors.textWhite : AppColors.textDark,
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}