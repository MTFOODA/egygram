import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';

/// Deletes stories older than the configured retention window
/// (Supabase-side cleanup happens through the repository's best-effort RPC).
Future<void> deleteOldStories(BuildContext context) async {
  try {
    final removed = await sl.storyRepository
        .deleteStoriesOlderThan(const Duration(minutes: 50));
    debugPrint(
      removed > 0
          ? "Old stories have been deleted ($removed)."
          : "No stories to delete.",
    );
  } catch (e) {
    // Show an error message if something went wrong
    debugPrint("Error deleting stories: $e");
  }
}
