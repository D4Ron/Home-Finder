import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum _Variant { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String     label;
  final VoidCallback? onPressed;
  final bool       loading;
  final _Variant   _variant;
  final Color?     color;
  final Widget?    icon;
  final double?    width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
    this.icon,
    this.width,
  }) : _variant = _Variant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
    this.icon,
    this.width,
  }) : _variant = _Variant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
    this.icon,
    this.width,
  }) : _variant = _Variant.text;

  @override
  Widget build(BuildContext context) {
    Widget child = loading
        ? const SizedBox(
      width: 20, height: 20,
      child: CircularProgressIndicator(strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white)),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: AppSizes.sm)],
        Text(label),
      ],
    );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(width ?? double.infinity, AppSizes.buttonH),
      ),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      )),
    );

    return switch (_variant) {
      _Variant.filled => ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
        ).merge(style),
        child: child,
      ),
      _Variant.outlined => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? AppColors.primary),
          foregroundColor: color ?? AppColors.primary,
        ).merge(style),
        child: child,
      ),
      _Variant.text => TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
        ).merge(style),
        child: child,
      ),
    };
  }
}