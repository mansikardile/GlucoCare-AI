import 'package:flutter/material.dart';
import '../models/food_query.dart';
import '../models/glucose_reading.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final String? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.text,
    required this.textColor,
    required this.bgColor,
    this.icon,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  factory StatusBadge.fromGlucose(GlucoseStatus status, {bool isCompact = false}) {
    if (isCompact) {
      switch (status) {
        case GlucoseStatus.normal:
          return const StatusBadge(
            text: 'In Range',
            textColor: AppTheme.successGreen,
            bgColor: AppTheme.successBg,
            icon: '✓',
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
        case GlucoseStatus.elevated:
          return const StatusBadge(
            text: 'Elevated',
            textColor: AppTheme.warningAmber,
            bgColor: AppTheme.warningBg,
            icon: '⚠️',
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
        case GlucoseStatus.high:
          return const StatusBadge(
            text: 'High',
            textColor: AppTheme.dangerCoral,
            bgColor: AppTheme.dangerBg,
            icon: '🚨',
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
        case GlucoseStatus.low:
          return const StatusBadge(
            text: 'Low (<70)',
            textColor: AppTheme.dangerCoral,
            bgColor: AppTheme.dangerBg,
            icon: '⚠️',
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
      }
    }

    switch (status) {
      case GlucoseStatus.normal:
        return const StatusBadge(
          text: '✓ Within your usual range',
          textColor: AppTheme.successGreen,
          bgColor: AppTheme.successBg,
          icon: '✓',
        );
      case GlucoseStatus.elevated:
        return const StatusBadge(
          text: '⚠️ Slightly Above Baseline',
          textColor: AppTheme.warningAmber,
          bgColor: AppTheme.warningBg,
          icon: '⚠️',
        );
      case GlucoseStatus.high:
        return const StatusBadge(
          text: '🚨 High Glucose Spike',
          textColor: AppTheme.dangerCoral,
          bgColor: AppTheme.dangerBg,
          icon: '🚨',
        );
      case GlucoseStatus.low:
        return const StatusBadge(
          text: '⚠️ Below Safe Target (<70)',
          textColor: AppTheme.dangerCoral,
          bgColor: AppTheme.dangerBg,
          icon: '⚠️',
        );
    }
  }

  factory StatusBadge.fromFoodVerdict(FoodVerdict verdict, {bool isCompact = false}) {
    if (isCompact) {
      switch (verdict) {
        case FoodVerdict.goodChoice:
          return const StatusBadge(
            text: '🟢 Good',
            textColor: AppTheme.successGreen,
            bgColor: AppTheme.successBg,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
        case FoodVerdict.haveWithCare:
          return const StatusBadge(
            text: '🟡 Caution',
            textColor: AppTheme.warningAmber,
            bgColor: AppTheme.warningBg,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
        case FoodVerdict.avoidOrConsult:
          return const StatusBadge(
            text: '🔴 Avoid',
            textColor: AppTheme.dangerCoral,
            bgColor: AppTheme.dangerBg,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          );
      }
    }

    switch (verdict) {
      case FoodVerdict.goodChoice:
        return const StatusBadge(
          text: '🟢 GOOD CHOICE',
          textColor: AppTheme.successGreen,
          bgColor: AppTheme.successBg,
          fontSize: 14,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        );
      case FoodVerdict.haveWithCare:
        return const StatusBadge(
          text: '🟡 HAVE WITH CARE',
          textColor: AppTheme.warningAmber,
          bgColor: AppTheme.warningBg,
          fontSize: 14,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        );
      case FoodVerdict.avoidOrConsult:
        return const StatusBadge(
          text: '🔴 CONSIDER AVOIDING',
          textColor: AppTheme.dangerCoral,
          bgColor: AppTheme.dangerBg,
          fontSize: 14,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: textColor.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !text.startsWith(icon!)) ...[
            Text(icon!, style: TextStyle(fontSize: fontSize)),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
