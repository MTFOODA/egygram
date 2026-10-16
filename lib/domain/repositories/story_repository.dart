import '../../models/story_model.dart';

/// Stories contract.
abstract class StoryRepository {
  Stream<List<StoriesModel>> watchStories();

  Future<void> createStory(StoriesModel story);

  Future<void> deleteStory(String storyId);

  /// Deletes stories older than [olderThan] (best-effort cleanup).
  Future<int> deleteStoriesOlderThan(Duration maxAge);
}
