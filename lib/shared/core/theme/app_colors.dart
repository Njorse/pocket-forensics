import 'package:flutter/material.dart';

/// PocketForensics — Dark forensic color palette.
///
/// Inspired by cybersecurity terminals and digital forensics tools.
/// All colors are defined as static constants for compile-time safety.
abstract final class AppColors {
  // ─── Background & Surface ──────────────────────────────────────────
  /// Main background — deep obsidian black
  static const Color background = Color(0xFF101318);

  /// Cards, bottom sheets — dark graphite
  static const Color surface = Color(0xFF1B1E24);

  /// AppBars, text fields — elevated slate
  static const Color surfaceElevated = Color(0xFF272A31);

  /// Borders, dividers — steel gray
  static const Color border = Color(0xFF383B42);

  // ─── Primary Accents ───────────────────────────────────────────────
  /// Primary action color — neon cyan
  static const Color primary = Color(0xFF00FFFF);

  /// Pressed/hover states — deep cyan
  static const Color primaryMuted = Color(0xFF1BA3A3);

  /// Success, verified hash — matrix green
  static const Color secondary = Color(0xFF00FF66);

  /// EXIF highlights, badges — electric purple
  static const Color accent = Color(0xFF9933FF);

  /// Warnings — amber alert
  static const Color warning = Color(0xFFFFB31A);

  /// Errors, corrupted integrity — crimson
  static const Color error = Color(0xFFE62E2E);

  // ─── Text ──────────────────────────────────────────────────────────
  /// High-emphasis text
  static const Color textPrimary = Color(0xFFEBEBEB);

  /// Medium-emphasis text
  static const Color textSecondary = Color(0xFF8F939C);

  /// Disabled text
  static const Color textDisabled = Color(0xFF525660);

  // ─── Utility ───────────────────────────────────────────────────────
  /// Semi-transparent overlay for glassmorphism cards
  static const Color glassOverlay = Color(0x331B1E24);

  /// Glow effect color for neon elements
  static const Color neonGlow = Color(0x6600FFFF);
}
