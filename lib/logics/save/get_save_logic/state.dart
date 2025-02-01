import '../../../models/save_model.dart';

abstract class GetSavesState {}

class GetSaveInitialState extends GetSavesState {}

class GetSaveLoadingState extends GetSavesState {}

class GetSaveSuccessState extends GetSavesState {
  final List<SavesModel> saves;

  GetSaveSuccessState({required this.saves});
}

class GetSaveErrorState extends GetSavesState {
  final String errorMessage;
  GetSaveErrorState(this.errorMessage);
}
