import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetSaveCubit extends Cubit<GetSavesState> {
  final SocialRepository _socialRepository;

  GetSaveCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(GetSaveInitialState());

  Future<void> getSaves(String userName) async {
    emit(GetSaveLoadingState());
    try {
      final saves = await _socialRepository.getSaves(userName);
      emit(GetSaveSuccessState(saves: saves));
    } catch (e) {
      emit(GetSaveErrorState(friendlyError(e)));
    }
  }

  Future<bool> getSaveStatus(String postId, String userName) async {
    try {
      return await _socialRepository.getSaveStatus(postId, userName);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
  }
}
