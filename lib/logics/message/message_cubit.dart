import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../../models/message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageRepository _messageRepository;
  final String currentUser;
  final String selectedUser;
  StreamSubscription<List<MessagesModel>>? _subscription;

  MessageCubit({
    required this.currentUser,
    required this.selectedUser,
    MessageRepository? messageRepository,
  })  : _messageRepository = messageRepository ?? sl.messageRepository,
        super(MessageInitialState());

  void fetchMessages() {
    emit(MessageLoadingState(const []));
    _subscription?.cancel();
    _subscription = _messageRepository
        .watchMessages(currentUser: currentUser, selectedUser: selectedUser)
        .listen(
          (messages) => emit(MessageLoadingState(messages)),
          onError: (error) => emit(MessageErrorState(friendlyError(error))),
        );
  }

  Future<void> sendMessage(String sender, String text,
      {String? mediaUrl}) async {
    try {
      await _messageRepository.sendMessage(
        sender: sender,
        receiver: selectedUser,
        text: text,
        mediaUrl: mediaUrl,
      );
    } catch (e) {
      emit(MessageErrorState(friendlyError(e)));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
