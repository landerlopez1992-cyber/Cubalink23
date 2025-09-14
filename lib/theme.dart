import 'package:flutter/material.dart';

// PALETA DE COLORES AUTÉNTICA PARA CUBALINK23
// Morado vibrante + Naranja energético = Identidad única y memorable
class LightModeColors {
  // COLORES PRINCIPALES - Morado vibrante como sello distintivo
  static const lightPrimary = Color(0xFF6B46C1); // Morado vibrante principal 
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFEDE9FE); // Morado claro contenedor
  static const lightOnPrimaryContainer = Color(0xFF2D1B69); // Morado oscuro texto
  
  // COLORES SECUNDARIOS - Naranja energético para dinamismo
  static const lightSecondary = Color(0xFFFF6B35); // Naranja energético
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFFFE5DB); // Naranja claro
  static const lightOnSecondaryContainer = Color(0xFF8B2500); // Naranja oscuro
  
  // COLORES DE ACENTO - Rosa coral para elementos especiales
  static const lightTertiary = Color(0xFFFF4785); // Rosa coral vibrante
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFFFFD9E2); // Rosa claro
  static const lightOnTertiaryContainer = Color(0xFF8C1538); // Rosa oscuro
  
  // COLORES DE ESTADO
  static const lightError = Color(0xFFDC2626); // Rojo vibrante error
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFECEC);
  static const lightOnErrorContainer = Color(0xFF5B0000);
  
  static const lightSuccess = Color(0xFF059669); // Verde éxito
  static const lightWarning = Color(0xFFF59E0B); // Amarillo advertencia
  
  // COLORES DE SUPERFICIE Y FONDOS
  static const lightInversePrimary = Color(0xFF9B7EF7); // Morado claro
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFFEFEFE); // Blanco puro
  static const lightOnSurface = Color(0xFF111827); // Gris muy oscuro
  static const lightSurfaceContainer = Color(0xFFF8FAFC); // Gris super claro
  
  // BARRAS Y ELEMENTOS ESPECIALES
  static const lightAppBarBackground = Color(0xFF6B46C1); // Morado principal
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightDivider = Color(0xFFE5E7EB);
}

class DarkModeColors {
  // MODO OSCURO - Manteniendo la identidad pero adaptada
  static const darkPrimary = Color(0xFF9B7EF7); // Morado más claro para contraste
  static const darkOnPrimary = Color(0xFF2D1B69);
  static const darkPrimaryContainer = Color(0xFF4C2889); // Morado medio
  static const darkOnPrimaryContainer = Color(0xFFEDE9FE);
  
  // COLORES SECUNDARIOS OSCUROS
  static const darkSecondary = Color(0xFFFF8A5B); // Naranja más suave
  static const darkOnSecondary = Color(0xFF8B2500);
  static const darkSecondaryContainer = Color(0xFFB63C0F); // Naranja medio
  static const darkOnSecondaryContainer = Color(0xFFFFE5DB);
  
  // COLORES DE ACENTO OSCUROS
  static const darkTertiary = Color(0xFFFF7BA3); // Rosa coral suave
  static const darkOnTertiary = Color(0xFF8C1538);
  static const darkTertiaryContainer = Color(0xFFB73E64); // Rosa medio
  static const darkOnTertiaryContainer = Color(0xFFFFD9E2);
  
  // COLORES DE ESTADO OSCUROS
  static const darkError = Color(0xFFEF4444); // Rojo más suave
  static const darkOnError = Color(0xFF5B0000);
  static const darkErrorContainer = Color(0xFF9B1C1C);
  static const darkOnErrorContainer = Color(0xFFFFECEC);
  
  static const darkSuccess = Color(0xFF10B981); // Verde más suave
  static const darkWarning = Color(0xFFFBBF24); // Amarillo más suave
  
  // SUPERFICIES OSCURAS
  static const darkInversePrimary = Color(0xFF6B46C1);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF0F172A); // Azul muy oscuro
  static const darkOnSurface = Color(0xFFE2E8F0); // Gris muy claro
  static const darkSurfaceContainer = Color(0xFF1E293B); // Azul oscuro contenedor
  
  // BARRAS Y ELEMENTOS ESPECIALES OSCUROS
  static const darkAppBarBackground = Color(0xFF4C2889); // Morado medio
  static const darkCardBackground = Color(0xFF1E293B);
  static const darkDivider = Color(0xFF334155);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    secondaryContainer: LightModeColors.lightSecondaryContainer,
    onSecondaryContainer: LightModeColors.lightOnSecondaryContainer,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    tertiaryContainer: LightModeColors.lightTertiaryContainer,
    onTertiaryContainer: LightModeColors.lightOnTertiaryContainer,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainer: LightModeColors.lightSurfaceContainer,
  ),
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimary,
    elevation: 2,
    shadowColor: LightModeColors.lightShadow,
    titleTextStyle: TextStyle(
      color: LightModeColors.lightOnPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: LightModeColors.lightCardBackground,
    elevation: 4,
    shadowColor: LightModeColors.lightShadow.withOpacity( 0.15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightModeColors.lightPrimary,
      foregroundColor: LightModeColors.lightOnPrimary,
      elevation: 3,
      shadowColor: LightModeColors.lightShadow.withOpacity( 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: LightModeColors.lightSecondary,
      foregroundColor: LightModeColors.lightOnSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: LightModeColors.lightPrimary,
      side: BorderSide(color: LightModeColors.lightPrimary, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: LightModeColors.lightDivider,
    thickness: 1,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: TextStyle(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: TextStyle(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: TextStyle(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);

// CLASE APPTHEME PARA ORGANIZAR LOS TEMAS  
class AppTheme {
  static ThemeData get lightTheme => _lightThemeData();
  static ThemeData get darkTheme => _darkThemeData();
}

ThemeData _lightThemeData() => lightTheme;
ThemeData _darkThemeData() => darkTheme;

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    secondaryContainer: DarkModeColors.darkSecondaryContainer,
    onSecondaryContainer: DarkModeColors.darkOnSecondaryContainer,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    tertiaryContainer: DarkModeColors.darkTertiaryContainer,
    onTertiaryContainer: DarkModeColors.darkOnTertiaryContainer,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    inversePrimary: DarkModeColors.darkInversePrimary,
    shadow: DarkModeColors.darkShadow,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainer: DarkModeColors.darkSurfaceContainer,
  ),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkModeColors.darkAppBarBackground,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 2,
    shadowColor: DarkModeColors.darkShadow,
    titleTextStyle: TextStyle(
      color: DarkModeColors.darkOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: DarkModeColors.darkCardBackground,
    elevation: 6,
    shadowColor: DarkModeColors.darkShadow.withOpacity( 0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkModeColors.darkPrimary,
      foregroundColor: DarkModeColors.darkOnPrimary,
      elevation: 4,
      shadowColor: DarkModeColors.darkShadow.withOpacity( 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DarkModeColors.darkSecondary,
      foregroundColor: DarkModeColors.darkOnSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkModeColors.darkPrimary,
      side: BorderSide(color: DarkModeColors.darkPrimary, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: DarkModeColors.darkDivider,
    thickness: 1,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: TextStyle(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: TextStyle(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: TextStyle(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);