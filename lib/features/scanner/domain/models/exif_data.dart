import 'package:first_app/shared/data/utils/format_utils.dart';

/// Domain model representing extracted EXIF metadata from an image file.
///
/// All fields are nullable since not every image contains
/// complete EXIF data — some may be stripped or absent.
class ExifData {
  const ExifData({
    this.fileName,
    this.fileSize,
    this.imageWidth,
    this.imageHeight,
    this.make,
    this.model,
    this.dateTimeOriginal,
    this.dateTimeDigitized,
    this.software,
    this.orientation,
    this.xResolution,
    this.yResolution,
    this.exposureTime,
    this.fNumber,
    this.isoSpeed,
    this.focalLength,
    this.flash,
    this.gpsLatitude,
    this.gpsLongitude,
    this.gpsAltitude,
    this.rawTags,
  });

  // ─── File Info ─────────────────────────────────────────────────────
  /// Original file name (from path, not EXIF).
  final String? fileName;

  /// File size in bytes (from file system, not EXIF).
  final int? fileSize;

  // ─── Image Dimensions ─────────────────────────────────────────────
  final int? imageWidth;
  final int? imageHeight;

  // ─── Camera / Device ──────────────────────────────────────────────
  /// Camera manufacturer (e.g. "Apple", "Samsung").
  final String? make;

  /// Camera model (e.g. "iPhone 15 Pro", "Galaxy S24").
  final String? model;

  // ─── Date & Time ──────────────────────────────────────────────────
  /// Original capture date/time.
  final String? dateTimeOriginal;

  /// Digitization date/time.
  final String? dateTimeDigitized;

  // ─── Software ─────────────────────────────────────────────────────
  /// Software used to produce the image.
  final String? software;

  // ─── Orientation ──────────────────────────────────────────────────
  /// EXIF orientation value (1–8).
  final int? orientation;

  // ─── Resolution ───────────────────────────────────────────────────
  final double? xResolution;
  final double? yResolution;

  // ─── Exposure ─────────────────────────────────────────────────────
  /// Shutter speed (e.g. "1/120").
  final String? exposureTime;

  /// Aperture (e.g. "f/1.8").
  final String? fNumber;

  /// ISO sensitivity.
  final int? isoSpeed;

  /// Focal length in mm.
  final double? focalLength;

  /// Flash status description.
  final String? flash;

  // ─── GPS ──────────────────────────────────────────────────────────
  /// Latitude in decimal degrees.
  final double? gpsLatitude;

  /// Longitude in decimal degrees.
  final double? gpsLongitude;

  /// Altitude in meters.
  final double? gpsAltitude;

  // ─── Raw Data ─────────────────────────────────────────────────────
  /// All raw EXIF tags as key-value pairs for complete access.
  final Map<String, String>? rawTags;

  /// Whether any meaningful EXIF data was found.
  bool get hasData =>
      make != null ||
      model != null ||
      dateTimeOriginal != null ||
      gpsLatitude != null;

  /// Number of non-null fields (excluding rawTags and file info).
  int get populatedFieldCount {
    int count = 0;
    if (imageWidth != null) count++;
    if (imageHeight != null) count++;
    if (make != null) count++;
    if (model != null) count++;
    if (dateTimeOriginal != null) count++;
    if (dateTimeDigitized != null) count++;
    if (software != null) count++;
    if (orientation != null) count++;
    if (xResolution != null) count++;
    if (yResolution != null) count++;
    if (exposureTime != null) count++;
    if (fNumber != null) count++;
    if (isoSpeed != null) count++;
    if (focalLength != null) count++;
    if (flash != null) count++;
    if (gpsLatitude != null) count++;
    if (gpsLongitude != null) count++;
    if (gpsAltitude != null) count++;
    return count;
  }

  /// Converts the model to a display-friendly map (only non-null entries).
  Map<String, String> toDisplayMap() {
    final map = <String, String>{};
    if (fileName != null) map['File Name'] = fileName!;
    if (fileSize != null) map['File Size'] = FormatUtils.formatBytes(fileSize!);
    if (imageWidth != null && imageHeight != null) {
      map['Dimensions'] = '$imageWidth×$imageHeight';
    }
    if (make != null) map['Make'] = make!;
    if (model != null) map['Model'] = model!;
    if (dateTimeOriginal != null) map['Date Taken'] = dateTimeOriginal!;
    if (dateTimeDigitized != null) map['Date Digitized'] = dateTimeDigitized!;
    if (software != null) map['Software'] = software!;
    if (orientation != null) map['Orientation'] = '$orientation';
    if (xResolution != null) map['X Resolution'] = '${xResolution!} dpi';
    if (yResolution != null) map['Y Resolution'] = '${yResolution!} dpi';
    if (exposureTime != null) map['Exposure'] = exposureTime!;
    if (fNumber != null) map['Aperture'] = fNumber!;
    if (isoSpeed != null) map['ISO'] = '$isoSpeed';
    if (focalLength != null) map['Focal Length'] = '${focalLength!} mm';
    if (flash != null) map['Flash'] = flash!;
    if (gpsLatitude != null) map['Latitude'] = gpsLatitude!.toStringAsFixed(6);
    if (gpsLongitude != null) {
      map['Longitude'] = gpsLongitude!.toStringAsFixed(6);
    }
    if (gpsAltitude != null) map['Altitude'] = '${gpsAltitude!.toStringAsFixed(1)} m';
    return map;
  }


}
