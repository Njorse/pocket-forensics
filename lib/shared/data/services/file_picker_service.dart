import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

/// Data returned from the file picker — works on both web and mobile.
class PickedFileData {
  const PickedFileData({
    required this.fileName,
    required this.bytes,
    required this.sizeBytes,
  });

  final String fileName;
  final Uint8List bytes;
  final int sizeBytes;
}

/// Shared service that abstracts file selection from the platform.
///
/// Returns raw bytes so it works on web, mobile, and desktop equally.
class FilePickerService {
  /// Opens the native file picker and returns file data (bytes + name).
  ///
  /// Returns `null` if the user cancels the picker.
  Future<PickedFileData?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: true, // Critical: ensures bytes are loaded (needed for web)
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.bytes == null) return null;

    return PickedFileData(
      fileName: file.name,
      bytes: file.bytes!,
      sizeBytes: file.size,
    );
  }

  /// Opens the native file picker for images only.
  Future<PickedFileData?> pickImage() async {
    return pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'tiff', 'heic', 'heif', 'webp'],
    );
  }
}
