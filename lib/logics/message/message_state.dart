import '../../models/message_model.dart';

abstract class MessageState {}
class MessageInitialState extends MessageState {}
class MessageLoadingState extends MessageState {
  final List<MessagesModel> messages;
  MessageLoadingState(this.messages);
}
class MessageErrorState extends MessageState {
  final String errorMessage;
  MessageErrorState(this.errorMessage);
}
