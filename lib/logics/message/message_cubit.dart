import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/message_model.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final DatabaseReference messagesRef;
  final String currentUser;
  final String selectedUser;

  MessageCubit(this.currentUser, this.selectedUser)
      : messagesRef = FirebaseDatabase.instance.ref('chats'),
        super(MessageInitialState());

  void fetchMessages() {
    messagesRef.onValue.listen((event) {
      final messages = event.snapshot.children.map((e) {
        final data = e.value as Map;
        return MessagesModel(
          sender: data['sender'],
          receiver: data['receiver'],
          text: data['text'] ?? '',
          mediaUrl: data['mediaUrl'], // Handle media URL
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).where((message) {
        // Filter messages for current chat room
        return (message.sender == currentUser && message.receiver == selectedUser) ||
            (message.sender == selectedUser && message.receiver == currentUser);
      }).toList();

      emit(MessageLoadingState(messages));
    });
  }

  void sendMessage(String sender, String text, {String? mediaUrl}) async {
    final message = {
      'sender': sender,
      'receiver': selectedUser,
      'text': text,
      'mediaUrl': mediaUrl, // Add media URL to the message
      'timestamp': DateTime.now().toIso8601String(),
    };
    await messagesRef.push().set(message);
  }
}
