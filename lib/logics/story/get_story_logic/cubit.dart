import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/story_repository.dart';
import '../../../models/story_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetStoryCubit extends Cubit<GetStoriesState> {
  final StoryRepository _storyRepository;
  StreamSubscription<List<StoriesModel>>? _subscription;

  GetStoryCubit({StoryRepository? storyRepository})
      : _storyRepository = storyRepository ?? sl.storyRepository,
        super(GetStoryInitialState());

  Stream<List<StoriesModel>> _getStoryStream() =>
      _storyRepository.watchStories();

  void subscribeToStories() {
    emit(GetStoryLoadingState());
    _subscription?.cancel();
    _subscription = _getStoryStream().listen(
      (stories) => emit(GetStorySuccessState(stories)),
      onError: (error) => emit(GetStoryErrorState(friendlyError(error))),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
