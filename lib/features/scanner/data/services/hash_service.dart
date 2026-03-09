import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../domain/models/hash_result.dart';

/// Service responsible for computing cryptographic hashes.
///
/// Stateless data-access layer. Works on all platforms (web, mobile, desktop)
/// by accepting raw bytes instead of file paths.
class HashService {
  /// Computes the SHA-256 hash of [bytes].
  ///
  /// [fileName] and [fileSizeBytes] are metadata passed from the picker.
  Future<HashResult> computeSha256({
    required Uint8List bytes,
    required String fileName,
    required int fileSizeBytes,
  }) async {
    final stopwatch = Stopwatch()..start();

    final digest = sha256.convert(bytes);

    stopwatch.stop();

    return HashResult(
      algorithm: 'SHA-256',
      hash: digest.toString(),
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      computationTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
}
