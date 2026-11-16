import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A consistent section header with title and optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.onActionTap,
    this.actionIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null || (actionLabel != null && onActionTap != null))
            action ??
                (onActionTap != null
                    ? AppTextButton(
                        label: actionLabel!,
                        onPressed: onActionTap,
                        icon: actionIcon,
                      )
                    : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// A header with a chip filter indicator
class SectionHeaderWithFilter extends StatelessWidget {
  final String title;
  final int filterCount;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearFilters;
  final EdgeInsetsGeometry? padding;

  const SectionHeaderWithFilter({
    super.key,
    required this.title,
    this.filterCount = 0,
    this.onFilterTap,
    this.onClearFilters,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              if (filterCount > 0 && onClearFilters != null)
                AppTextButton(
                  label: 'Clear',
                  onPressed: onClearFilters,
                  color: theme.colorScheme.error,
                ),
              if (onFilterTap != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onFilterTap,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: filterCount > 0 ? theme.colorScheme.primaryContainer : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.tune,
                            color: filterCount > 0
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          if (filterCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  filterCount.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onError,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Category chips row
class CategoryChips extends StatelessWidget {
  final List<CategoryChip> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry? padding;
  final double height;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
    this.padding,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(AppRadius.round),
              child: AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurves.standard,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category.icon != null) ...[
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      category.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChip {
  final String label;
  final IconData? icon;
  final String? query;

  const CategoryChip({required this.label, this.icon, this.query});
}

/// Filter chips row (multi-select)
class FilterChips extends StatelessWidget {
  final List<FilterChipData> chips;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;
  final EdgeInsetsGeometry? padding;
  final bool singleSelect;

  const FilterChips({
    super.key,
    required this.chips,
    required this.selectedValues,
    required this.onChanged,
    this.padding,
    this.singleSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: chips.map((chip) {
        final isSelected = selectedValues.contains(chip.value);
        return FilterChip(
          label: Text(chip.label, style: theme.textTheme.labelMedium),
          icon: chip.icon != null ? Icon(chip.icon, size: 16) : null,
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = Set<String>.from(selectedValues);
            if (singleSelect) {
              newSelection.clear();
              if (selected) newSelection.add(chip.value);
            } else {
              if (selected) {
                newSelection.add(chip.value);
              } else {
                newSelection.remove(chip.value);
              }
            }
            onChanged(newSelection);
          },
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
          labelStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer);
            }
            return theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface);
          }),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

class FilterChipData {
  final String value;
  final String label;
  final IconData? icon;

  const FilterChipData({required this.value, required this.label, this.icon});
}