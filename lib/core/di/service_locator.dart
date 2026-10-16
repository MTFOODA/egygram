import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/reel_repository_impl.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/story_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/reel_repository.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Lightweight, type-safe service locator.
///
/// A hand-rolled locator keeps dependency injection consistent across the app
/// without pulling in an extra package. Call [init] once, right after
/// `Supabase.initialize`, from `main.dart`.
final sl = ServiceLocator._();

class ServiceLocator {
  ServiceLocator._();

  bool _ready = false;
  bool get isReady => _ready;

  late final SupabaseClient client;

  // Repositories (created once during [init]).
  late final AuthRepository authRepository;
  late final UserRepository userRepository;
  late final PostRepository postRepository;
  late final ReelRepository reelRepository;
  late final StoryRepository storyRepository;
  late final CommentRepository commentRepository;
  late final SocialRepository socialRepository;
  late final MessageRepository messageRepository;
  late final StorageRepository storageRepository;
  late final NotificationRepository notificationRepository;

  /// Wires the Supabase client and every repository implementation.
  ///
  /// Must be called after `Supabase.initialize(...)` succeeds.
  void init(SupabaseClient supabaseClient) {
    client = supabaseClient;

    storageRepository = StorageRepositoryImpl(supabaseClient);
    authRepository = AuthRepositoryImpl(supabaseClient);
    userRepository = UserRepositoryImpl(supabaseClient);
    notificationRepository = NotificationRepositoryImpl(supabaseClient);
    postRepository = PostRepositoryImpl(supabaseClient);
    reelRepository = ReelRepositoryImpl(supabaseClient);
    storyRepository = StoryRepositoryImpl(supabaseClient);
    commentRepository = CommentRepositoryImpl(supabaseClient);
    socialRepository = SocialRepositoryImpl(supabaseClient);
    messageRepository = MessageRepositoryImpl(supabaseClient);

    _ready = true;
  }
}
