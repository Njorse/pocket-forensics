import 'package:flutter/foundation.dart';

import 'package:first_app/shared/data/models/result.dart';
import 'package:first_app/shared/data/services/file_picker_service.dart';
import '../../data/repositories/scanner_repository.dart';
import '../../domain/models/exif_data.dart';
import '../../domain/models/hash_result.dart';
import '../../domain/models/scan_result.dart';

/// Possible states for the scanner screen.
enum ScannerState { idle, processing, success, error }

/// ViewModel for the Scanner feature.
///
/// Transforms repository data into UI state, manages scanner lifecycle,
/// and exposes state via [ChangeNotifier].
class ScannerViewModel extends ChangeNotifier {
  ScannerViewModel({
    ScannerRepository? repository,
    FilePickerService? filePickerService,
  })  : _repository = repository ?? ScannerRepository(),
        _filePickerService = filePickerService ?? FilePickerService();

  final ScannerRepository _repository;
  final FilePickerService _filePickerService;

  /// Minimum time (ms) the processing screen stays visible
  /// so the user can appreciate the scan animation.
  static const int _minProcessingTimeMs = 2500;

  // ─── State ──────────────────────────────────────────────────────

  ScannerState _state = ScannerState.idle;
  ScannerState get state => _state;

  ExifData? _exifData;
  ExifData? get exifData => _exifData;

  HashResult? _hashResult;
  HashResult? get hashResult => _hashResult;

  String? _selectedFileName;
  String? get selectedFileName => _selectedFileName;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Commands ───────────────────────────────────────────────────

  /// Opens the file picker and, if a file is selected, runs a full scan.
  /// Ensures the processing screen is shown for at least [_minProcessingTimeMs].
  Future<void> pickAndScan() async {
    final pickedFile = await _filePickerService.pickImage();
    if (pickedFile == null) return;

    _selectedFileName = pickedFile.fileName;
    _state = ScannerState.processing;
    _exifData = null;
    _hashResult = null;
    _errorMessage = null;
    notifyListeners();

    // Run scan + minimum timer in parallel
    final results = await Future.wait([
      _repository.fullScan(
        bytes: pickedFile.bytes,
        fileName: pickedFile.fileName,
        fileSizeBytes: pickedFile.sizeBytes,
      ),
      Future<void>.delayed(
        const Duration(milliseconds: _minProcessingTimeMs),
      ),
    ]);

    final result = results[0] as Result<ScanResult>;

    switch (result) {
      case Ok<ScanResult>():
        _exifData = result.value.exifData;
        _hashResult = result.value.hashResult;
        _state = ScannerState.success;
      case Error<ScanResult>():
        _errorMessage = result.error.toString();
        _state = ScannerState.error;
    }

    notifyListeners();
  }

  /// Resets the scanner to idle state for a new scan.
  void reset() {
    _state = ScannerState.idle;
    _exifData = null;
    _hashResult = null;
    _selectedFileName = null;
    _errorMessage = null;
    notifyListeners();
  }
}
