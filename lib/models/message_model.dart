class MessagesModel {
  final String sender;
  final String receiver;
  final String text;
  final String? mediaUrl;
  final DateTime timestamp;

  MessagesModel({
    required this.sender,
    required this.receiver,
    required this.text,
    this.mediaUrl,
    required this.timestamp,
  });
}
