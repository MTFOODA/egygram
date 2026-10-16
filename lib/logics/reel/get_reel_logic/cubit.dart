import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/reel_repository.dart';
import '../../../models/reel_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetReelCubit extends Cubit<GetReelsState> {
  final ReelRepository _reelRepository;
  StreamSubscription<List<ReelsModel>>? _subscription;

  GetReelCubit({ReelRepository? reelRepository})
      : _reelRepository = reelRepository ?? sl.reelRepository,
        super(GetReelInitialState());

  Stream<List<ReelsModel>> getReelStream() => _reelRepository.watchReels();

  void subscribeToReels() {
    emit(GetReelLoadingState());
    _subscription?.cancel();
    _subscription = getReelStream().listen(
      (reels) => emit(GetReelSuccessState(reels)),
      onError: (error) => emit(GetReelErrorState(friendlyError(error))),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
