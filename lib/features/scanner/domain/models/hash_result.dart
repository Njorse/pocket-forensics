import 'package:first_app/shared/data/utils/format_utils.dart';

/// Domain model representing the result of a file hash computation.
class HashResult {
  const HashResult({
    required this.algorithm,
    required this.hash,
    required this.fileName,
    required this.fileSizeBytes,
    required this.computationTimeMs,
  });

  /// Name of the hash algorithm used (e.g. "SHA-256").
  final String algorithm;

  /// The computed hash as a lowercase hex string.
  final String hash;

  /// Name of the file that was hashed.
  final String fileName;

  /// Size of the hashed file in bytes.
  final int fileSizeBytes;

  /// Time in milliseconds the computation took.
  final int computationTimeMs;

  /// Formatted file size for display.
  String get formattedSize => FormatUtils.formatBytes(fileSizeBytes);

  /// Formatted computation time for display.
  String get formattedTime {
    if (computationTimeMs < 1000) return '${computationTimeMs}ms';
    return '${(computationTimeMs / 1000).toStringAsFixed(2)}s';
  }

  /// First and last 8 characters of the hash for truncated display.
  String get truncatedHash {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 8)}';
  }
}
