import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../di/service_locator.dart';

/// Centralised media upload + id helpers used by the create/edit flows.
///
/// Replaces the per-widget object-storage upload code that was duplicated
/// across post/reel/story/chat/profile widgets. All uploads go to Supabase
/// Storage through [sl.storageRepository].
class MediaUploadHelper {
  const MediaUploadHelper._();

  static const _uuid = Uuid();

  /// Generates a new unique content id (was previously a Firestore doc id).
  static String newId() => _uuid.v4();

  static bool _isVideo(XFile file) =>
      file.mimeType?.startsWith('video') ?? false;

  static String _extension(XFile file) => _isVideo(file) ? '.mp4' : '.jpg';

  /// Uploads a list of picked media (images/videos) under [folder]/[owner]/ and
  /// returns their public URLs, preserving order.
  static Future<List<String>> uploadMedia({
    required List<XFile> files,
    required String folder,
    required String owner,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${newId()}${_extension(file)}';
      final url = await sl.storageRepository.uploadFile(
        file: File(file.path),
        folder: folder,
        owner: owner,
        fileName: fileName,
      );
      urls.add(url);
    }
    return urls;
  }

  /// Uploads a single picked video and returns its public URL.
  static Future<String> uploadVideo({
    required XFile video,
    required String folder,
    required String owner,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${newId()}.mp4';
    return sl.storageRepository.uploadFile(
      file: File(video.path),
      folder: folder,
      owner: owner,
      fileName: fileName,
    );
  }

  /// Uploads a profile image (dart:io File) and returns its public URL.
  static Future<String> uploadProfileImage({
    required File image,
    required String owner,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${newId()}.jpg';
    return sl.storageRepository.uploadFile(
      file: image,
      folder: StorageBuckets.avatarsFolder,
      owner: owner,
      fileName: fileName,
    );
  }
}
