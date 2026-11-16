import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Primary action button
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: theme.textTheme.labelLarge),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: child,
      ),
    );
  }
}

/// Secondary action button
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: theme.textTheme.labelLarge),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: FilledButton.tonal(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: child,
      ),
    );
  }
}

/// Outline action button
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? textColor;

  const AppOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor ?? theme.colorScheme.primary),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: textColor)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? theme.colorScheme.primary,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          minimumSize: const Size(88, 48),
          side: BorderSide(color: borderColor ?? theme.colorScheme.outline, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: child,
      ),
    );
  }
}

/// Text button
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(color ?? theme.colorScheme.primary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: color)),
            ],
          );

    return TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      child: child,
    );
  }
}

/// Icon button with consistent styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    final effectiveBg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.circle),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: effectiveBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}

/// Floating action button with extended variant
class AppFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final bool extended;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppFAB({
    super.key,
    this.onPressed,
    this.icon,
    this.label,
    this.extended = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : assert(icon != null || label != null);

  const AppFAB.regular({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : label = null,
       extended = false;

  const AppFAB.extended({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : extended = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (extended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : null,
        label: Text(label!, style: theme.textTheme.labelLarge?.copyWith(color: foregroundColor)),
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        extendedIconLabelSpacing: AppSpacing.sm,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon, color: foregroundColor ?? theme.colorScheme.onPrimary),
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    );
  }
}

/// Segmented control for tab-like selection
class AppSegmentedControl<T> extends StatelessWidget {
  final T selectedValue;
  final List<Segment<T>> segments;
  final ValueChanged<T> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;

  const AppSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.segments,
    required this.onChanged,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSelected = selectedColor ?? theme.colorScheme.primary;
    final effectiveUnselected = unselectedColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: segments.map((segment) {
          final isSelected = segment.value == selectedValue;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(segment.value),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: AnimatedContainer(
                  duration: AppDuration.fast,
                  curve: AppCurves.standard,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: isSelected ? AppElevation.level1 : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (segment.icon != null) ...[
                        Icon(
                          segment.icon,
                          size: 18,
                          color: isSelected ? effectiveSelected : effectiveUnselected,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        segment.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected ? effectiveSelected : effectiveUnselected,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
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

class Segment<T> {
  final T value;
  final String label;
  final IconData? icon;

  const Segment({required this.value, required this.label, this.icon});
}

/// Badge for status/type indicators
class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  const AppBadge.success({super.key, required this.label, this.icon = Icons.check_circle})
      : color = Colors.green,
        backgroundColor = null,
        textColor = null,
        padding = null,
        fontSize = null,
        fontWeight = null;

  const AppBadge.warning({super.key, required this.label, this.icon = Icons.warning})
      : color = Colors.orange,
        backgroundColor = null,
        textColor = null,
        padding = null,
        fontSize = null,
        fontWeight = null;

  const AppBadge.error({super.key, required this.label, this.icon = Icons.error})
      : color = Colors.red,
        backgroundColor = null,
        textColor = null,
        padding = null,
        fontSize = null,
        fontWeight = null;

  const AppBadge.info({super.key, required this.label, this.icon = Icons.info})
      : color = Colors.blue,
        backgroundColor = null,
        textColor = null,
        padding = null,
        fontSize = null,
        fontWeight = null;

  const AppBadge.neutral({super.key, required this.label, this.icon})
      : color = Colors.grey,
        backgroundColor = null,
        textColor = null,
        padding = null,
        fontSize = null,
        fontWeight = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = backgroundColor ?? effectiveColor.withOpacity(0.12);
    final effectiveText = textColor ?? effectiveColor;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize ?? 11, color: effectiveText),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? 11,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: effectiveText,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-style badge (larger, for property types)
class AppPillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final bool selected;
  final VoidCallback? onTap;

  const AppPillBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = selected
        ? effectiveColor
        : (backgroundColor ?? theme.colorScheme.surfaceContainerHighest);
    final effectiveText = selected
        ? theme.colorScheme.onPrimary
        : (textColor ?? theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.round),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(AppRadius.round),
            border: Border.all(
              color: selected ? effectiveColor : theme.colorScheme.outlineVariant,
              width: selected ? 0 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: effectiveText),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: effectiveText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}