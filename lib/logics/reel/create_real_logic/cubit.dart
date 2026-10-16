import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/reel_repository.dart';
import '../../../models/reel_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateReelCubit extends Cubit<CreateReelStates> {
  final ReelRepository _reelRepository;

  CreateReelCubit({ReelRepository? reelRepository})
      : _reelRepository = reelRepository ?? sl.reelRepository,
        super(CreateReelInitialStates());

  Future<void> createReel(ReelsModel reels) async {
    emit(CreateReelLoadingStates());
    try {
      await _reelRepository.createReel(reels);
      emit(CreateReelSuccessStates());
    } catch (e) {
      emit(CreateReelErrorStates(friendlyError(e)));
    }
  }
}
