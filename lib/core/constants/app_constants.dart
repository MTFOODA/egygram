/// Application-wide constants: Supabase table/column names and storage buckets.
///
/// Keep these in one place so the SQL migrations under `supabase/migrations`
/// and the Dart data layer never drift apart.
library;

class DbTables {
  const DbTables._();

  static const String profiles = 'profiles';
  static const String posts = 'posts';
  static const String reels = 'reels';
  static const String stories = 'stories';
  static const String comments = 'comments';
  static const String loves = 'loves';
  static const String saves = 'saves';
  static const String follows = 'follows';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
}

class DbColumns {
  const DbColumns._();

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String createdAt = 'created_at';
}

class StorageBuckets {
  const StorageBuckets._();

  /// Single public media bucket. Files are organised in sub-folders:
  /// posts/, reels/, stories/, avatars/, messages/.
  static const String media = 'media';

  static const String postsFolder = 'posts';
  static const String reelsFolder = 'reels';
  static const String storiesFolder = 'stories';
  static const String avatarsFolder = 'avatars';
  static const String messagesFolder = 'messages';
}
