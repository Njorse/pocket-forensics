import 'dart:typed_data';

import 'package:first_app/shared/data/models/result.dart';
import '../services/exif_service.dart';
import '../services/hash_service.dart';
import '../../domain/models/exif_data.dart';
import '../../domain/models/hash_result.dart';
import '../../domain/models/scan_result.dart';

/// Single source of truth for scanner operations.
///
/// Coordinates [ExifService] and [HashService] to perform a complete
/// forensic analysis. All methods accept raw bytes so they work on
/// every platform (web, mobile, desktop).
///
/// Uses [Result] pattern for type-safe error handling as recommended
/// by the flutter-architecture skill.
class ScannerRepository {
  ScannerRepository({
    ExifService? exifService,
    HashService? hashService,
  })  : _exifService = exifService ?? ExifService(),
        _hashService = hashService ?? HashService();

  final ExifService _exifService;
  final HashService _hashService;

  /// Performs a full forensic scan: EXIF extraction + SHA-256 hash.
  ///
  /// Both operations run concurrently for performance.
  Future<Result<ScanResult>> fullScan({
    required Uint8List bytes,
    required String fileName,
    required int fileSizeBytes,
  }) async {
    try {
      final results = await Future.wait([
        _exifService.extractMetadata(
          bytes: bytes,
          fileName: fileName,
          fileSize: fileSizeBytes,
        ),
        _hashService.computeSha256(
          bytes: bytes,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
        ),
      ]);

      final exifData = results[0] as ExifData;
      final hashResult = results[1] as HashResult;

      return Result.ok(ScanResult(
        exifData: exifData,
        hashResult: hashResult,
      ));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Full scan failed: $e'));
    }
  }
}
