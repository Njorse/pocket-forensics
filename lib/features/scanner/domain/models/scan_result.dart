import 'exif_data.dart';
import 'hash_result.dart';

/// Aggregated result of a full forensic scan (EXIF + Hash).
class ScanResult {
  const ScanResult({
    required this.exifData,
    required this.hashResult,
  });

  final ExifData exifData;
  final HashResult hashResult;
}
