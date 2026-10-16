import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/social_repository.dart';
import '../../../models/save_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateSaveCubit extends Cubit<CreateSaveStates> {
  final SocialRepository _socialRepository;

  CreateSaveCubit({SocialRepository? socialRepository})
      : _socialRepository = socialRepository ?? sl.socialRepository,
        super(CreateSaveInitialStates());

  Future<void> toggleSave(SavesModel saves) async {
    emit(CreateSaveLoadingStates());
    try {
      await _socialRepository.toggleSave(saves);
      emit(CreateSaveSuccessStates());
    } catch (e) {
      emit(CreateSaveErrorStates(friendlyError(e)));
    }
  }
}
