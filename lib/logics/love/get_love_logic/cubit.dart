import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetLoveCubit extends Cubit<GetLovesState> {
  final SocialRepository _socialRepository;

  GetLoveCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(GetLoveInitialState());

  Future<void> getLoves(String userName) async {
    emit(GetLoveLoadingState());
    try {
      final loves = await _socialRepository.getLoves(userName);
      emit(GetLoveSuccessState(loves: loves));
    } catch (e) {
      emit(GetLoveErrorState(friendlyError(e)));
    }
  }

  Future<bool> getLoveStatus(String postId, String userName) async {
    try {
      return await _socialRepository.getLoveStatus(postId, userName);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
  }
}
