import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import '../../../models/follow_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateFollowCubit extends Cubit<CreateFollowStates> {
  final SocialRepository _socialRepository;

  CreateFollowCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(CreateFollowInitialStates());

  Future<void> toggleFollow(FollowsModel follows) async {
    emit(CreateFollowLoadingStates());
    try {
      await _socialRepository.toggleFollow(follows);
      emit(CreateFollowSuccessStates());
    } catch (e) {
      emit(CreateFollowErrorStates(friendlyError(e)));
    }
  }
}
