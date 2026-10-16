import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetFollowCubit extends Cubit<GetFollowsState> {
  final SocialRepository _socialRepository;

  GetFollowCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(GetFollowInitialState());

  Future<void> getFollows(String userName) async {
    emit(GetFollowLoadingState());
    try {
      final follows = await _socialRepository.getFollows(userName);
      emit(GetFollowSuccessState(follows: follows));
    } catch (e) {
      emit(GetFollowErrorState(friendlyError(e)));
    }
  }

  Future<bool> getFollowStatus(String userFollowed, String userName) async {
    try {
      return await _socialRepository.getFollowStatus(userFollowed, userName);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
  }
}
