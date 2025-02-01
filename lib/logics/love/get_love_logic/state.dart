import '../../../models/love_model.dart';

abstract class GetLovesState {}

class GetLoveInitialState extends GetLovesState {}

class GetLoveLoadingState extends GetLovesState {}

class GetLoveSuccessState extends GetLovesState {
  final List<LovesModel> loves;

  GetLoveSuccessState({required this.loves});
}

class GetLoveErrorState extends GetLovesState {
  final String errorMessage;
  GetLoveErrorState(this.errorMessage);
}
