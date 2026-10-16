import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/reel_repository.dart';
import '../../../models/reel_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class EditReelCubit extends Cubit<EditReelsState> {
  final ReelRepository _reelRepository;

  EditReelCubit({ReelRepository? reelRepository})
      : _reelRepository = reelRepository ?? sl.reelRepository,
        super(EditReelInitialState());

  Future<void> editReel(String reelID, ReelsModel updatedReel) async {
    emit(EditReelLoadingState());
    try {
      final existing = await _reelRepository.getReel(reelID);
      if (existing == null) {
        emit(EditReelErrorState("Reel not found"));
        return;
      }
      await _reelRepository.updateReel(reelID, updatedReel);
      emit(EditReelSuccessState(updatedReel));
    } catch (e) {
      emit(EditReelErrorState(friendlyError(e)));
    }
  }
}
