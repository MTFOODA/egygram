import 'dart:io';

/// Media upload contract backed by Supabase Storage.
abstract class StorageRepository {
  /// Uploads [file] under [folder]/[owner]/[fileName] in the media bucket and
  /// returns the public URL.
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String owner,
    required String fileName,
  });

  /// Uploads raw [bytes] (used on web) under the given path.
  Future<String> uploadBytes({
    required List<int> bytes,
    required String folder,
    required String owner,
    required String fileName,
  });
}
