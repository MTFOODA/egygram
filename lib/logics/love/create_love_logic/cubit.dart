import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import '../../../models/love_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateLoveCubit extends Cubit<CreateLoveStates> {
  final SocialRepository _socialRepository;

  CreateLoveCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(CreateLoveInitialStates());

  Future<void> toggleLove(LovesModel loves) async {
    emit(CreateLoveLoadingStates());
    try {
      await _socialRepository.toggleLove(loves);
      emit(CreateLoveSuccessStates());
    } catch (e) {
      emit(CreateLoveErrorStates(friendlyError(e)));
    }
  }
}
