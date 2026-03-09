import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// PocketForensics — Typography system.
///
/// - **JetBrains Mono**: Headlines, titles — terminal/code vibe
/// - **Inter**: Body text — clean readability
/// - **Fira Code**: Technical data (hashes, EXIF values) — monospaced with ligatures
abstract final class AppTypography {
  // ─── Headline Styles (JetBrains Mono) ─────────────────────────────

  static TextStyle get headlineLarge => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ─── Title Styles (JetBrains Mono) ────────────────────────────────

  static TextStyle get titleLarge => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  // ─── Body Styles (Inter) ──────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // ─── Label Styles (Inter) ─────────────────────────────────────────

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textDisabled,
        letterSpacing: 0.5,
      );

  // ─── Technical / Monospace (Fira Code) ────────────────────────────

  /// For SHA-256 hashes, EXIF raw values, file paths.
  static TextStyle get codeLarge => GoogleFonts.firaCode(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        letterSpacing: 0.5,
      );

  static TextStyle get codeMedium => GoogleFonts.firaCode(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        letterSpacing: 0.3,
      );

  static TextStyle get codeSmall => GoogleFonts.firaCode(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      );

  // ─── TextTheme (for ThemeData) ────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
