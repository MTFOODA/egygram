import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/storage_repository.dart';

/// Supabase Storage implementation.
///
/// All files live in a single public `media` bucket, organised into
/// sub-folders (posts/, reels/, stories/, avatars/, messages/). Public read is
/// enabled by the bucket's RLS policies defined in the SQL migrations.
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _client;

  StorageRepositoryImpl(this._client);

  String _path(String folder, String owner, String fileName) {
    final safeOwner = _sanitize(owner);
    return '$folder/$safeOwner/$fileName';
  }

  /// Keeps only filesystem/uuid-safe characters to avoid odd storage keys.
  String _sanitize(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');

  @override
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String owner,
    required String fileName,
  }) async {
    try {
      final path = _path(folder, owner, fileName);
      await _client.storage.from(StorageBuckets.media).upload(path, file);
      return _client.storage.from(StorageBuckets.media).getPublicUrl(path);
    } catch (e) {
      throw StorageException('Failed to upload media: $e');
    }
  }

  @override
  Future<String> uploadBytes({
    required List<int> bytes,
    required String folder,
    required String owner,
    required String fileName,
  }) async {
    try {
      final path = _path(folder, owner, fileName);
      await _client.storage
          .from(StorageBuckets.media)
          .uploadBinary(path, Uint8List.fromList(bytes));
      return _client.storage.from(StorageBuckets.media).getPublicUrl(path);
    } catch (e) {
      throw StorageException('Failed to upload media: $e');
    }
  }
}
