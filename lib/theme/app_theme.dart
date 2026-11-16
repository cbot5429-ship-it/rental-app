import 'package:flutter/material.dart';

/// App-wide spacing scale (4px base unit)
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// App-wide border radius scale
class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double round = 999;
  static const double circle = 9999;
}

/// App-wide elevation/shadow tokens
class AppElevation {
  static const List<BoxShadow> level0 = [];
  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

/// App-wide animation durations
class AppDuration {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
}

/// App-wide animation curves
class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasize = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve accelerate = Curves.easeInQuart;
}

/// Custom theme extension for property-specific colors
class PropertyThemeExtension extends ThemeExtension<PropertyThemeExtension> {
  final Color rentColor;
  final Color rentContainer;
  final Color saleColor;
  final Color saleContainer;
  final Color commercialColor;
  final Color commercialContainer;
  final Color verifiedColor;
  final Color verifiedContainer;
  final Color featuredColor;
  final Color featuredContainer;
  final Color priceColor;
  final Color surfaceVariant;
  final Color outlineVariant;
  final Color scrim;

  const PropertyThemeExtension({
    required this.rentColor,
    required this.rentContainer,
    required this.saleColor,
    required this.saleContainer,
    required this.commercialColor,
    required this.commercialContainer,
    required this.verifiedColor,
    required this.verifiedContainer,
    required this.featuredColor,
    required this.featuredContainer,
    required this.priceColor,
    required this.surfaceVariant,
    required this.outlineVariant,
    required this.scrim,
  });

  @override
  PropertyThemeExtension copyWith({
    Color? rentColor,
    Color? rentContainer,
    Color? saleColor,
    Color? saleContainer,
    Color? commercialColor,
    Color? commercialContainer,
    Color? verifiedColor,
    Color? verifiedContainer,
    Color? featuredColor,
    Color? featuredContainer,
    Color? priceColor,
    Color? surfaceVariant,
    Color? outlineVariant,
    Color? scrim,
  }) {
    return PropertyThemeExtension(
      rentColor: rentColor ?? this.rentColor,
      rentContainer: rentContainer ?? this.rentContainer,
      saleColor: saleColor ?? this.saleColor,
      saleContainer: saleContainer ?? this.saleContainer,
      commercialColor: commercialColor ?? this.commercialColor,
      commercialContainer: commercialContainer ?? this.commercialContainer,
      verifiedColor: verifiedColor ?? this.verifiedColor,
      verifiedContainer: verifiedContainer ?? this.verifiedContainer,
      featuredColor: featuredColor ?? this.featuredColor,
      featuredContainer: featuredContainer ?? this.featuredContainer,
      priceColor: priceColor ?? this.priceColor,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  PropertyThemeExtension lerp(ThemeExtension<PropertyThemeExtension>? other, double t) {
    if (other is! PropertyThemeExtension) return this;
    return PropertyThemeExtension(
      rentColor: Color.lerp(rentColor, other.rentColor, t)!,
      rentContainer: Color.lerp(rentContainer, other.rentContainer, t)!,
      saleColor: Color.lerp(saleColor, other.saleColor, t)!,
      saleContainer: Color.lerp(saleContainer, other.saleContainer, t)!,
      commercialColor: Color.lerp(commercialColor, other.commercialColor, t)!,
      commercialContainer: Color.lerp(commercialContainer, other.commercialContainer, t)!,
      verifiedColor: Color.lerp(verifiedColor, other.verifiedColor, t)!,
      verifiedContainer: Color.lerp(verifiedContainer, other.verifiedContainer, t)!,
      featuredColor: Color.lerp(featuredColor, other.featuredColor, t)!,
      featuredContainer: Color.lerp(featuredContainer, other.featuredContainer, t)!,
      priceColor: Color.lerp(priceColor, other.priceColor, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }

  static const PropertyThemeExtension light = PropertyThemeExtension(
    rentColor: Color(0xFF1E88E5),
    rentContainer: Color(0xFFE3F2FD),
    saleColor: Color(0xFF43A047),
    saleContainer: Color(0xFFE8F5E9),
    commercialColor: Color(0xFF8E24AA),
    commercialContainer: Color(0xFFF3E5F5),
    verifiedColor: Color(0xFF00ACC1),
    verifiedContainer: Color(0xFFE0F7FA),
    featuredColor: Color(0xFFFFB300),
    featuredContainer: Color(0xFFFFF8E1),
    priceColor: Color(0xFF1B5E20),
    surfaceVariant: Color(0xFFF5F5F5),
    outlineVariant: Color(0xFFE0E0E0),
    scrim: Color(0x80000000),
  );

  static const PropertyThemeExtension dark = PropertyThemeExtension(
    rentColor: Color(0xFF64B5F6),
    rentContainer: Color(0xFF1565C0),
    saleColor: Color(0xFF81C784),
    saleContainer: Color(0xFF2E7D32),
    commercialColor: Color(0xFFCE93D8),
    commercialContainer: Color(0xFF6A1B9A),
    verifiedColor: Color(0xFF4DD0E1),
    verifiedContainer: Color(0xFF006064),
    featuredColor: Color(0xFFFFD54F),
    featuredContainer: Color(0xFFF57F17),
    priceColor: Color(0xFFA5D6A7),
    surfaceVariant: Color(0xFF2C2C2C),
    outlineVariant: Color(0xFF444444),
    scrim: Color(0xCC000000),
  );
}

/// Custom theme extension for status colors
class StatusThemeExtension extends ThemeExtension<StatusThemeExtension> {
  final Color pendingColor;
  final Color pendingContainer;
  final Color approvedColor;
  final Color approvedContainer;
  final Color rejectedColor;
  final Color rejectedContainer;
  final Color resolvedColor;
  final Color resolvedContainer;
  final Color activeColor;
  final Color activeContainer;
  final Color inactiveColor;
  final Color inactiveContainer;

  const StatusThemeExtension({
    required this.pendingColor,
    required this.pendingContainer,
    required this.approvedColor,
    required this.approvedContainer,
    required this.rejectedColor,
    required this.rejectedContainer,
    required this.resolvedColor,
    required this.resolvedContainer,
    required this.activeColor,
    required this.activeContainer,
    required this.inactiveColor,
    required this.inactiveContainer,
  });

  @override
  StatusThemeExtension copyWith({
    Color? pendingColor,
    Color? pendingContainer,
    Color? approvedColor,
    Color? approvedContainer,
    Color? rejectedColor,
    Color? rejectedContainer,
    Color? resolvedColor,
    Color? resolvedContainer,
    Color? activeColor,
    Color? activeContainer,
    Color? inactiveColor,
    Color? inactiveContainer,
  }) {
    return StatusThemeExtension(
      pendingColor: pendingColor ?? this.pendingColor,
      pendingContainer: pendingContainer ?? this.pendingContainer,
      approvedColor: approvedColor ?? this.approvedColor,
      approvedContainer: approvedContainer ?? this.approvedContainer,
      rejectedColor: rejectedColor ?? this.rejectedColor,
      rejectedContainer: rejectedContainer ?? this.rejectedContainer,
      resolvedColor: resolvedColor ?? this.resolvedColor,
      resolvedContainer: resolvedContainer ?? this.resolvedContainer,
      activeColor: activeColor ?? this.activeColor,
      activeContainer: activeContainer ?? this.activeContainer,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      inactiveContainer: inactiveContainer ?? this.inactiveContainer,
    );
  }

  @override
  StatusThemeExtension lerp(ThemeExtension<StatusThemeExtension>? other, double t) {
    if (other is! StatusThemeExtension) return this;
    return StatusThemeExtension(
      pendingColor: Color.lerp(pendingColor, other.pendingColor, t)!,
      pendingContainer: Color.lerp(pendingContainer, other.pendingContainer, t)!,
      approvedColor: Color.lerp(approvedColor, other.approvedColor, t)!,
      approvedContainer: Color.lerp(approvedContainer, other.approvedContainer, t)!,
      rejectedColor: Color.lerp(rejectedColor, other.rejectedColor, t)!,
      rejectedContainer: Color.lerp(rejectedContainer, other.rejectedContainer, t)!,
      resolvedColor: Color.lerp(resolvedColor, other.resolvedColor, t)!,
      resolvedContainer: Color.lerp(resolvedContainer, other.resolvedContainer, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      activeContainer: Color.lerp(activeContainer, other.activeContainer, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      inactiveContainer: Color.lerp(inactiveContainer, other.inactiveContainer, t)!,
    );
  }

  static const StatusThemeExtension light = StatusThemeExtension(
    pendingColor: Color(0xFFFF8F00),
    pendingContainer: Color(0xFFFFF8E1),
    approvedColor: Color(0xFF2E7D32),
    approvedContainer: Color(0xFFE8F5E9),
    rejectedColor: Color(0xFFC62828),
    rejectedContainer: Color(0xFFEFEBE9),
    resolvedColor: Color(0xFF00695C),
    resolvedContainer: Color(0xFFE0F2F1),
    activeColor: Color(0xFF1E88E5),
    activeContainer: Color(0xFFE3F2FD),
    inactiveColor: Color(0xFF757575),
    inactiveContainer: Color(0xFFF5F5F5),
  );

  static const StatusThemeExtension dark = StatusThemeExtension(
    pendingColor: Color(0xFFFFB74D),
    pendingContainer: Color(0xFFE65100),
    approvedColor: Color(0xFF66BB6A),
    approvedContainer: Color(0xFF1B5E20),
    rejectedColor: Color(0xFFEF5350),
    rejectedContainer: Color(0xFFB71C1C),
    resolvedColor: Color(0xFF4DB6AC),
    resolvedContainer: Color(0xFF004D40),
    activeColor: Color(0xFF64B5F6),
    activeContainer: Color(0xFF1565C0),
    inactiveColor: Color(0xFF9E9E9E),
    inactiveContainer: Color(0xFF424242),
  );
}

/// Build the light theme
ThemeData buildLightTheme() {
  const seedColor = Color(0xFF6366F1); // Indigo primary
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
    primary: const Color(0xFF6366F1),
    secondary: const Color(0xFF0EA5E9),
    tertiary: const Color(0xFFF43F5E),
    surface: Colors.white,
    background: const Color(0xFFFAFAFA),
    error: const Color(0xFFDC2626),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE5E5E5),
    shadowColor: const Color(0x1A000000),

    extensions: [
      PropertyThemeExtension.light,
      StatusThemeExtension.light,
    ],

    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25, height: 1.12),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.16),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.22),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.25),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.29),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.33),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.27),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.5),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45),
    ).apply(
      bodyColor: const Color(0xFF1D1D1F),
      displayColor: const Color(0xFF1D1D1F),
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1D1F),
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1D1D1F), size: 24),
      actionsIconTheme: const IconThemeData(color: Color(0xFF1D1D1F), size: 24),
      toolbarHeight: 56,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: Colors.white.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        side: BorderSide.none,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return colorScheme.primary.withOpacity(0.12);
          if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
          if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
          return null;
        }),
      ),
    ),

    // Filled button theme
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: Colors.white.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w400),
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w400),
      floatingLabelStyle: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w500),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: Colors.grey.shade500,
      suffixIconColor: Colors.grey.shade500,
      iconColor: Colors.grey.shade500,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF5F5F5),
      disabledColor: Colors.grey.shade200,
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
      secondaryLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
      brightness: Brightness.light,
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
      side: BorderSide.none,
      showCheckmark: false,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),

    // Navigation bar theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary);
        }
        return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.primary, size: 24);
        }
        return IconThemeData(color: Colors.grey.shade500, size: 24);
      }),
      height: 72,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: Colors.grey.shade500,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: const Color(0xFFE5E5E5),
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),

    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
      subtitleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey.shade600),
      leadingAndTrailingTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
      iconColor: Colors.grey.shade500,
      textColor: const Color(0xFF1D1D1F),
      dense: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      selectedTileColor: colorScheme.primaryContainer,
      selectedColor: colorScheme.primary,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
      contentTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF4D4D4D)),
      alignment: Alignment.center,
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0x1A000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      modalBackgroundColor: Colors.white,
      dragHandleColor: Colors.grey.shade400,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF333333),
      contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
      actionTextColor: colorScheme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      elevation: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      dismissDirection: DismissDirection.horizontal,
    ),

    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      extendedTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      extendedIconLabelSpacing: 8,
    ),

    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primaryContainer,
      circularTrackColor: colorScheme.primaryContainer,
      refreshBackgroundColor: colorScheme.surfaceContainerHighest,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primaryContainer,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.12),
      valueIndicatorColor: colorScheme.primary,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary.withOpacity(0.5);
        return Colors.grey.shade300;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade300;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: Colors.grey.shade400, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade400;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      verticalOffset: 8,
      preferBelow: true,
      excludeFromSemantics: false,
    ),

    // Material banner theme
    materialBannerTheme: MaterialBannerThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      leadingPadding: const EdgeInsets.all(16),
      contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      dividerColor: colorScheme.outlineVariant,
    ),

    // Time picker theme
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      hourMinuteTextColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFF1D1D1F);
      }),
      hourMinuteColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.primaryContainer;
      }),
      dayPeriodTextColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return colorScheme.primary;
      }),
      dayPeriodColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.primaryContainer;
      }),
      dialHandColor: colorScheme.primary,
      dialBackgroundColor: colorScheme.primaryContainer,
      entryModeIconColor: colorScheme.primary,
    ),

    // Date picker theme
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      headerBackgroundColor: colorScheme.primary,
      headerForegroundColor: Colors.white,
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        if (states.contains(WidgetState.hovered)) return colorScheme.primaryContainer;
        return Colors.transparent;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) return Colors.grey.shade400;
        return const Color(0xFF1D1D1F);
      }),
      todayBackgroundColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      todayForegroundColor: WidgetStateProperty.all(colorScheme.primary),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFF1D1D1F);
      }),
      rangePickerHeaderBackgroundColor: colorScheme.primary,
      rangePickerHeaderForegroundColor: Colors.white,
    ),

    // Menu theme
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shadowColor: WidgetStateProperty.all(const Color(0x1A000000)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
        minimumSize: WidgetStateProperty.all(const Size(48, 48)),
        maximumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
      ),
    ),

    // Popup menu theme
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1D1D1F)),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1D1D1F))),
      iconColor: Colors.grey.shade600,
      padding: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Expansion tile theme
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: const Color(0xFF1D1D1F),
      collapsedTextColor: const Color(0xFF1D1D1F),
      iconColor: Colors.grey.shade600,
      collapsedIconColor: Colors.grey.shade600,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      expandedAlignment: Alignment.centerLeft,
    ),
  );
}

/// Build the dark theme
ThemeData buildDarkTheme() {
  const seedColor = Color(0xFF818CF8); // Indigo primary for dark
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
    primary: const Color(0xFF818CF8),
    secondary: const Color(0xFF38BDF8),
    tertiary: const Color(0xFFF87171),
    surface: const Color(0xFF1E1E1E),
    background: const Color(0xFF121212),
    error: const Color(0xFFF87171),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: const Color(0xFF1E1E1E),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF333333),
    shadowColor: const Color(0x33000000),

    extensions: [
      PropertyThemeExtension.dark,
      StatusThemeExtension.dark,
    ],

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25, height: 1.12),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.16),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.22),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.25),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.29),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.33),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.27),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.5),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45),
    ).apply(
      bodyColor: const Color(0xFFE4E4E7),
      displayColor: const Color(0xFFE4E4E7),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE4E4E7),
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE4E4E7), size: 24),
      actionsIconTheme: const IconThemeData(color: Color(0xFFE4E4E7), size: 24),
      toolbarHeight: 56,
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: Colors.white.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        side: BorderSide.none,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return colorScheme.primary.withOpacity(0.12);
          if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
          if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
          return null;
        }),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: Colors.white.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w400),
      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w400),
      floatingLabelStyle: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w500),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: Colors.grey.shade500,
      suffixIconColor: Colors.grey.shade500,
      iconColor: Colors.grey.shade500,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      disabledColor: const Color(0xFF333333),
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
      secondaryLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
      brightness: Brightness.dark,
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
      side: BorderSide.none,
      showCheckmark: false,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary);
        }
        return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade400);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.primary, size: 24);
        }
        return IconThemeData(color: Colors.grey.shade500, size: 24);
      }),
      height: 72,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: Colors.grey.shade500,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    ),

    dividerTheme: DividerThemeData(
      color: const Color(0xFF333333),
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE4E4E7)),
      subtitleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey.shade400),
      leadingAndTrailingTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
      iconColor: Colors.grey.shade500,
      textColor: const Color(0xFFE4E4E7),
      dense: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      selectedTileColor: colorScheme.primaryContainer,
      selectedColor: colorScheme.primary,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE4E4E7)),
      contentTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFA3A3A3)),
      alignment: Alignment.center,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0x33000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      modalBackgroundColor: const Color(0xFF1E1E1E),
      dragHandleColor: Colors.grey.shade600,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFE4E4E7),
      contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1D1D1F)),
      actionTextColor: colorScheme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      elevation: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      dismissDirection: DismissDirection.horizontal,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      extendedTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      extendedIconLabelSpacing: 8,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primaryContainer,
      circularTrackColor: colorScheme.primaryContainer,
      refreshBackgroundColor: colorScheme.surfaceContainerHighest,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primaryContainer,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.12),
      valueIndicatorColor: colorScheme.primary,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary.withOpacity(0.5);
        return Colors.grey.shade700;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade700;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: Colors.grey.shade600, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.grey.shade600;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withOpacity(0.08);
        if (states.contains(WidgetState.focused)) return colorScheme.primary.withOpacity(0.12);
        return null;
      }),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E7),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF1D1D1F)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      verticalOffset: 8,
      preferBelow: true,
      excludeFromSemantics: false,
    ),

    materialBannerTheme: MaterialBannerThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      leadingPadding: const EdgeInsets.all(16),
      contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      dividerColor: colorScheme.outlineVariant,
    ),

    timePickerTheme: TimePickerThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      hourMinuteTextColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFFE4E4E7);
      }),
      hourMinuteColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.primaryContainer;
      }),
      dayPeriodTextColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return colorScheme.primary;
      }),
      dayPeriodColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.primaryContainer,
      }),
      dialHandColor: colorScheme.primary,
      dialBackgroundColor: colorScheme.primaryContainer,
      entryModeIconColor: colorScheme.primary,
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
      headerBackgroundColor: colorScheme.primary,
      headerForegroundColor: Colors.white,
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        if (states.contains(WidgetState.hovered)) return colorScheme.primaryContainer;
        return Colors.transparent;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) return Colors.grey.shade600;
        return const Color(0xFFE4E4E7);
      }),
      todayBackgroundColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      todayForegroundColor: WidgetStateProperty.all(colorScheme.primary),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFFE4E4E7);
      }),
      rangePickerHeaderBackgroundColor: colorScheme.primary,
      rangePickerHeaderForegroundColor: Colors.white,
    ),

    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shadowColor: WidgetStateProperty.all(const Color(0x33000000)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
        minimumSize: WidgetStateProperty.all(const Size(48, 48)),
        maximumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE4E4E7)),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE4E4E7))),
      iconColor: Colors.grey.shade400,
      padding: const EdgeInsets.symmetric(vertical: 8),
    ),

    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: const Color(0xFFE4E4E7),
      collapsedTextColor: const Color(0xFFE4E4E7),
      iconColor: Colors.grey.shade400,
      collapsedIconColor: Colors.grey.shade400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      expandedAlignment: Alignment.centerLeft,
    ),
  );
}