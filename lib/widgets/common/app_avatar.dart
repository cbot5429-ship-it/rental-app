import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A consistent avatar widget with text, image, or icon support
class AppAvatar extends StatelessWidget {
  final String? text;
  final String? imageUrl;
  final IconData? icon;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showBorder;
  final VoidCallback? onTap;
  final BoxShape shape;

  const AppAvatar({
    super.key,
    this.text,
    this.imageUrl,
    this.icon,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 2,
    this.showBorder = false,
    this.onTap,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveTextColor = textColor ?? theme.colorScheme.onPrimaryContainer;

    Widget avatarChild;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarChild = ClipRRect(
        borderRadius: shape == BoxShape.circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(AppRadius.md),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(theme, effectiveBgColor, effectiveTextColor),
        ),
      );
    } else if (text != null && text!.isNotEmpty) {
      avatarChild = Center(
        child: Text(
          text!.substring(0, 1).toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      );
    } else if (icon != null) {
      avatarChild = Center(
        child: Icon(icon, size: size * 0.5, color: effectiveTextColor),
      );
    } else {
      avatarChild = Center(
        child: Icon(Icons.person, size: size * 0.5, color: effectiveTextColor),
      );
    }

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: shape,
        border: showBorder && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: avatarChild,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape == BoxShape.circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(AppRadius.md),
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  Widget _buildFallback(ThemeData theme, Color bgColor, Color textColor) {
    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: text != null && text!.isNotEmpty
            ? Text(
                text!.substring(0, 1).toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.4,
                ),
              )
            : Icon(icon ?? Icons.person, size: size * 0.5, color: textColor),
      ),
    );
  }
}