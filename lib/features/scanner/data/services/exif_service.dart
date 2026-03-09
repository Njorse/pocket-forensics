import 'dart:typed_data';

import 'package:exif/exif.dart' hide ExifData;

import '../../domain/models/exif_data.dart';

/// Service responsible for extracting EXIF metadata from image bytes.
///
/// Stateless data-access layer. Works on all platforms (web, mobile, desktop)
/// by accepting raw bytes instead of file paths.
class ExifService {
  /// Reads EXIF tags from [bytes] and returns an [ExifData] model.
  ///
  /// [fileName] and [fileSize] are passed in since they come from the picker.
  Future<ExifData> extractMetadata({
    required Uint8List bytes,
    required String fileName,
    required int fileSize,
  }) async {
    final Map<String, IfdTag> tags = await readExifFromBytes(bytes);

    return ExifData(
      fileName: fileName,
      fileSize: fileSize,
      imageWidth: _intTag(tags, 'EXIF ExifImageWidth') ??
          _intTag(tags, 'Image ImageWidth'),
      imageHeight: _intTag(tags, 'EXIF ExifImageLength') ??
          _intTag(tags, 'Image ImageLength'),
      make: _stringTag(tags, 'Image Make'),
      model: _stringTag(tags, 'Image Model'),
      dateTimeOriginal: _stringTag(tags, 'EXIF DateTimeOriginal'),
      dateTimeDigitized: _stringTag(tags, 'EXIF DateTimeDigitized'),
      software: _stringTag(tags, 'Image Software'),
      orientation: _intTag(tags, 'Image Orientation'),
      xResolution: _doubleTag(tags, 'Image XResolution'),
      yResolution: _doubleTag(tags, 'Image YResolution'),
      exposureTime: _stringTag(tags, 'EXIF ExposureTime'),
      fNumber: _stringTag(tags, 'EXIF FNumber'),
      isoSpeed: _intTag(tags, 'EXIF ISOSpeedRatings'),
      focalLength: _focalLength(tags),
      flash: _stringTag(tags, 'EXIF Flash'),
      gpsLatitude: _gpsCoordinate(tags, 'GPS GPSLatitude', 'GPS GPSLatitudeRef'),
      gpsLongitude: _gpsCoordinate(tags, 'GPS GPSLongitude', 'GPS GPSLongitudeRef'),
      gpsAltitude: _gpsAltitude(tags),
      rawTags: tags.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  // ─── Private Helpers ─────────────────────────────────────────────

  String? _stringTag(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    final value = tag.toString().trim();
    return value.isEmpty ? null : value;
  }

  int? _intTag(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    return int.tryParse(tag.toString().trim());
  }

  double? _doubleTag(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    final str = tag.toString().trim();
    if (str.contains('/')) {
      final parts = str.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) return num / den;
      }
    }
    return double.tryParse(str);
  }

  double? _focalLength(Map<String, IfdTag> tags) {
    final tag = tags['EXIF FocalLength'];
    if (tag == null) return null;
    final str = tag.toString().trim();
    if (str.contains('/')) {
      final parts = str.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) return num / den;
      }
    }
    return double.tryParse(str.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  double? _gpsCoordinate(
    Map<String, IfdTag> tags,
    String coordKey,
    String refKey,
  ) {
    final coordTag = tags[coordKey];
    final refTag = tags[refKey];
    if (coordTag == null) return null;

    try {
      final values = coordTag.values;
      if (values is IfdRatios && values.ratios.length >= 3) {
        final degrees = values.ratios[0].toDouble();
        final minutes = values.ratios[1].toDouble();
        final seconds = values.ratios[2].toDouble();

        double decimal = degrees + (minutes / 60) + (seconds / 3600);

        final ref = refTag?.toString().trim().toUpperCase() ?? '';
        if (ref == 'S' || ref == 'W') {
          decimal = -decimal;
        }
        return decimal;
      }
    } catch (_) {
      // GPS data malformed — return null
    }
    return null;
  }

  double? _gpsAltitude(Map<String, IfdTag> tags) {
    final altTag = tags['GPS GPSAltitude'];
    if (altTag == null) return null;

    try {
      final values = altTag.values;
      if (values is IfdRatios && values.ratios.isNotEmpty) {
        double alt = values.ratios[0].toDouble();
        final ref = tags['GPS GPSAltitudeRef']?.toString().trim();
        if (ref == '1') alt = -alt;
        return alt;
      }
    } catch (_) {
      // Altitude data malformed — return null
    }
    return null;
  }
}
