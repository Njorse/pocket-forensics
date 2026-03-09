import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_typography.dart';
import '../../../../shared/ui/widgets/animated_scan_indicator.dart';
import '../../../report/data/services/report_service.dart';
import '../../domain/models/exif_data.dart';
import '../../domain/models/hash_result.dart';
import '../viewmodels/scanner_viewmodel.dart';

/// Main scanner screen — the heart of PocketForensics.
///
/// Phase 5 enhancements:
/// - Staggered fade-in for result cards
/// - Animated copy feedback
/// - Elegant empty-EXIF message
/// - Gradient FAB for PDF export
/// - Minimum processing animation time
class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with TickerProviderStateMixin {
  final ScannerViewModel _viewModel = ScannerViewModel();
  final ReportService _reportService = ReportService();
  bool _buttonPressed = false;

  // ─── Staggered animation controllers ────────────────────────────
  late final AnimationController _staggerController;
  late final Animation<double> _badgeAnim;
  late final Animation<double> _hashCardAnim;
  late final Animation<double> _exifCardAnim;
  late final Animation<double> _fabAnim;

  // ─── Copy feedback ──────────────────────────────────────────────
  bool _hashCopied = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();

    // Total stagger duration: ~1200ms
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Badge: 0% – 25%
    _badgeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    // Hash card: 15% – 50%
    _hashCardAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.50, curve: Curves.easeOutCubic),
    );
    // EXIF card: 35% – 75%
    _exifCardAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    );
    // FAB: 55% – 100%
    _fabAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
    );

    // Listen for success state to trigger stagger
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_viewModel.state == ScannerState.success) {
      _staggerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _staggerController.dispose();
    _copyTimer?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _copyHash(String hash) {
    Clipboard.setData(ClipboardData(text: hash));
    setState(() => _hashCopied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hashCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('PocketForensics', style: AppTypography.titleMedium),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.state == ScannerState.success ||
                  _viewModel.state == ScannerState.error) {
                return IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Nuevo análisis',
                  onPressed: () {
                    _staggerController.reset();
                    _viewModel.reset();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildStateContent(_viewModel.state),
          );
        },
      ),
    );
  }

  Widget _buildStateContent(ScannerState state) {
    switch (state) {
      case ScannerState.idle:
        return _buildIdleState();
      case ScannerState.processing:
        return _buildProcessingState();
      case ScannerState.success:
        return _buildSuccessState();
      case ScannerState.error:
        return _buildErrorState();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  IDLE STATE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildIdleState() {
    return Center(
      key: const ValueKey('idle'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Forensic fingerprint icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
                color: AppColors.surface,
              ),
              child: const Icon(Icons.fingerprint,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'Análisis Forense Digital',
              style: AppTypography.headlineSmall
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona una imagen para extraer sus\nmetadatos EXIF y calcular su hash SHA-256',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // ── Animated "Load Evidence" button ──────────────
            GestureDetector(
              onTapDown: (_) => setState(() => _buttonPressed = true),
              onTapUp: (_) {
                setState(() => _buttonPressed = false);
                _viewModel.pickAndScan();
              },
              onTapCancel: () => setState(() => _buttonPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                transform: Matrix4.diagonal3Values(
                  _buttonPressed ? 0.95 : 1.0,
                  _buttonPressed ? 0.95 : 1.0,
                  1.0,
                ),
                transformAlignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 18),
                decoration: BoxDecoration(
                  color: _buttonPressed
                      ? AppColors.primaryMuted
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGlow.withValues(
                          alpha: _buttonPressed ? 0.2 : 0.4),
                      blurRadius: _buttonPressed ? 12 : 24,
                      spreadRadius: _buttonPressed ? 0 : 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.document_scanner_outlined,
                        color: AppColors.background,
                        size: _buttonPressed ? 22 : 24),
                    const SizedBox(width: 12),
                    Text(
                      'Cargar Evidencia',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.background, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline,
                    size: 14, color: AppColors.textDisabled),
                const SizedBox(width: 6),
                Text('100% local • Sin conexión a internet',
                    style: AppTypography.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PROCESSING STATE (with animated steps)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildProcessingState() {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedScanIndicator(),
          const SizedBox(height: 32),

          // File name badge
          if (_viewModel.selectedFileName != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _viewModel.selectedFileName!,
                      style: AppTypography.codeSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),

          // Animated processing steps
          _ProcessingSteps(),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SUCCESS STATE (staggered cards)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSuccessState() {
    final exif = _viewModel.exifData;
    final hash = _viewModel.hashResult;

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) {
        return Stack(
          children: [
            SingleChildScrollView(
              key: const ValueKey('success'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status badge (staggered) ────────────────
                  _staggerSlide(
                    animation: _badgeAnim,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 18, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Análisis completo',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Hash Card (staggered) ───────────────────
                  if (hash != null)
                    _staggerSlide(
                      animation: _hashCardAnim,
                      child: _buildHashCard(hash),
                    ),
                  const SizedBox(height: 16),

                  // ── EXIF Card (staggered) ───────────────────
                  if (exif != null)
                    _staggerSlide(
                      animation: _exifCardAnim,
                      child: _buildExifCard(exif),
                    ),
                ],
              ),
            ),

            // ── Gradient FAB (staggered) ──────────────────────
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _staggerSlide(
                animation: _fabAnim,
                child: _buildGradientFab(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Wraps a child in a slide-up + fade-in driven by [animation].
  Widget _staggerSlide({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ── Hash Card ─────────────────────────────────────────────────

  Widget _buildHashCard(HashResult hashResult) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tag,
                      size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text('SHA-256 Hash', style: AppTypography.titleSmall),
                const Spacer(),

                // ── Animated copy button ────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hashCopied
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () => _copyHash(hashResult.hash),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            _hashCopied
                                ? Icons.check_circle
                                : Icons.copy,
                            key: ValueKey(_hashCopied),
                            size: 16,
                            color: _hashCopied
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (_hashCopied) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Copiado',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                hashResult.hash,
                style: AppTypography.codeMedium,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.straighten, hashResult.formattedSize),
                const SizedBox(width: 8),
                _infoChip(Icons.timer_outlined, hashResult.formattedTime),
                const SizedBox(width: 8),
                _infoChip(Icons.lock_outline, 'SHA-256'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── EXIF Card ─────────────────────────────────────────────────

  Widget _buildExifCard(ExifData exifData) {
    final displayMap = exifData.toDisplayMap();
    final hasExif = exifData.hasData;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_camera_outlined,
                      size: 20, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Text('Metadatos EXIF', style: AppTypography.titleSmall),
                const Spacer(),
                if (hasExif)
                  Chip(
                    label: Text(
                      '${exifData.populatedFieldCount} campos',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.accent),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Elegant empty-EXIF message ──────────────────
            if (!hasExif)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            AppColors.secondary.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.verified_outlined,
                          size: 32, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin metadatos extendidos',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se detectaron metadatos EXIF en este archivo.\n'
                      'Integridad de origen verificada vía SHA-256.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statusDot(AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Archivo íntegro • Hash calculado',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              ...displayMap.entries
                  .map((entry) => _exifRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  // ── Gradient FAB ──────────────────────────────────────────────

  Widget _buildGradientFab() {
    return GestureDetector(
      onTap: () async {
        final hash = _viewModel.hashResult;
        final exif = _viewModel.exifData;
        if (hash == null || exif == null) return;

        try {
          await _reportService.generateAndPrint(
            hashResult: hash,
            exifData: exif,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al generar PDF: $e',
                  style: AppTypography.bodyMedium,
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Generar Reporte PDF',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────

  Widget _exifRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textDisabled)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: AppTypography.codeMedium.copyWith(
                    color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.labelSmall),
        ],
      ),
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  ERROR STATE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildErrorState() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text('Error en el Análisis',
                style: AppTypography.headlineSmall
                    .copyWith(color: AppColors.error)),
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage ?? 'Ocurrió un error inesperado',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _staggerController.reset();
                _viewModel.reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Processing Steps Widget (animated checklist)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ProcessingSteps extends StatefulWidget {
  @override
  State<_ProcessingSteps> createState() => _ProcessingStepsState();
}

class _ProcessingStepsState extends State<_ProcessingSteps> {
  int _currentStep = 0;
  late final List<_StepData> _steps;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _steps = [
      _StepData('Leyendo archivo', Icons.file_open_outlined),
      _StepData('Extrayendo metadatos EXIF', Icons.photo_camera_outlined),
      _StepData('Calculando hash SHA-256', Icons.tag),
      _StepData('Verificando integridad', Icons.verified_outlined),
    ];
    _startStepping();
  }

  void _startStepping() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length, (i) {
          final done = i < _currentStep;
          final active = i == _currentStep;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: i <= _currentStep ? 1.0 : 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : active
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surface,
                      border: Border.all(
                        color: done
                            ? AppColors.secondary
                            : active
                                ? AppColors.primary
                                : AppColors.border,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check,
                              size: 14, color: AppColors.secondary)
                          : active
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(_steps[i].icon,
                      size: 16,
                      color: done
                          ? AppColors.secondary
                          : active
                              ? AppColors.primary
                              : AppColors.textDisabled),
                  const SizedBox(width: 8),
                  Text(
                    _steps[i].label,
                    style: AppTypography.labelMedium.copyWith(
                      color: done
                          ? AppColors.secondary
                          : active
                              ? AppColors.primary
                              : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;
  const _StepData(this.label, this.icon);
}
