import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class TagSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> availableTags;
  final List<String> selectedTags;
  final Function(String) onTagSelected;
  final bool isEnabled;

  const TagSelectorWidget({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagSelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final tagName = tag['name'] as String;
        final isSelected = selectedTags.contains(tagName);
        final colorValue = int.parse(tag['color'] as String);
        final tagColor = Color(colorValue);

        return GestureDetector(
          onTap: isEnabled ? () => onTagSelected(tagName) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? tagColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? tagColor
                    : AppTheme.lightTheme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: tagColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  tagName,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? tagColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
