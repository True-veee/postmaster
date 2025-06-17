import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CharacterCounterWidget extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const CharacterCounterWidget({
    super.key,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final remainingChars = maxLength - currentLength;
    final isNearLimit = remainingChars <= 20;
    final isOverLimit = remainingChars < 0;

    Color textColor;
    if (isOverLimit) {
      textColor = AppTheme.errorLight;
    } else if (isNearLimit) {
      textColor = AppTheme.warningLight;
    } else {
      textColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isNearLimit || isOverLimit) ...[
          CustomIconWidget(
            iconName: isOverLimit ? 'error' : 'warning',
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          '\$currentLength/\$maxLength',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isNearLimit ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
