import '../../models/reel_model.dart';

/// Reels contract.
abstract class ReelRepository {
  Stream<List<ReelsModel>> watchReels();

  Future<void> createReel(ReelsModel reel);

  Future<ReelsModel?> getReel(String reelId);

  Future<void> updateReel(String reelId, ReelsModel updatedReel);

  Future<void> deleteReel(String reelId);
}
