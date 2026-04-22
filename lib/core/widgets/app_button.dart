import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary ? Colors.white : AppColors.primary,
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        if (!loading) Text(label),
      ],
    );

    final sizedChild = SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
            onPressed: loading ? null : onPressed,
            child: child,
          ),
        AppButtonVariant.outline => OutlinedButton(
            onPressed: loading ? null : onPressed,
            child: child,
          ),
        AppButtonVariant.ghost => TextButton(
            onPressed: loading ? null : onPressed,
            child: child,
          ),
        AppButtonVariant.danger => ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
      },
    );

    return sizedChild;
  }
}

enum AppButtonVariant { primary, outline, ghost, danger }
