import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/story_repository.dart';
import '../../../models/story_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateStoryCubit extends Cubit<CreateStoryStates> {
  final StoryRepository _storyRepository;

  CreateStoryCubit({StoryRepository? storyRepository})
      : _storyRepository = storyRepository ?? sl.storyRepository,
        super(CreateStoryInitialStates());

  Future createStory(StoriesModel stories) async {
    emit(CreateStoryLoadingStates());
    try {
      await _storyRepository.createStory(stories);
      emit(CreateStorySuccessStates());
    } catch (e) {
      emit(CreateStoryErrorStates(friendlyError(e)));
    }
  }
}
