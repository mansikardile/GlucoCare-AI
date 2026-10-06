import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeniorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hasActiveGlow;

  const SeniorCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.hasActiveGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppTheme.surface;
    final effectiveBorder = borderColor ?? AppTheme.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: effectiveBorder, width: 1.4),
        boxShadow: hasActiveGlow ? AppTheme.activeCardShadow : AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
