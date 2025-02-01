import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../logics/message/message_cubit.dart';
import '../logics/message/message_state.dart';
import '../utilities/decoration.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/helpers/full_screen_image.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String selectedUser;

  const ChatScreen({super.key, required this.currentUser, required this.selectedUser});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  late MessageCubit messageCubit;
  List<XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();
    messageCubit = MessageCubit(widget.currentUser, widget.selectedUser);
    messageCubit.fetchMessages();
  }

  Future<void> selectImages() async {
    final picker = ImagePicker();
    try {
      final pickedMedia = await picker.pickMultipleMedia();
      setState(() {
        selectedImages.addAll(pickedMedia);
      });
    } catch (e) {
      debugPrint("Media Selection Error: $e");
    }
  }

  Future<List<String>> uploadImages(List<XFile> images, String userName) async {
    List<String> mediaUrls = [];
    try {
      for (XFile media in images) {
        final isVideo = media.mimeType?.startsWith('video') ?? false;
        final extension = isVideo ? '.mp4' : '.jpg';
        final mediaTypeFolder = isVideo ? "videos" : "images";

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("messagesMedia/$userName/$mediaTypeFolder/${DateTime.now().millisecondsSinceEpoch}$extension");

        await storageRef.putFile(File(media.path));
        String mediaUrl = await storageRef.getDownloadURL();
        mediaUrls.add(mediaUrl);
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    }
    return mediaUrls;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('${'Chat with '.tr()}${widget.selectedUser}',style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageCubit, MessageState>(
              bloc: messageCubit,
              builder: (context, state) {
                if (state is MessageLoadingState) {
                  return ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.sender == widget.currentUser;

                      return ListTile(
                        title: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (message.mediaUrl != null) // Display media if available
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                          imageUrl: message.mediaUrl! ,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    message.mediaUrl!,
                                    height: 200,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                              if (message.text.isNotEmpty) // Display text if available
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    await selectImages();
                    if (selectedImages.isNotEmpty) {
                      final mediaUrls =
                      await uploadImages(selectedImages, widget.currentUser);
                      for (String mediaUrl in mediaUrls) {
                        messageCubit.sendMessage(widget.currentUser, '', mediaUrl: mediaUrl);
                      }
                      selectedImages.clear();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: searchInputDecoration(
                      context,
                      'Type a message'.tr(),
                      const Icon(CupertinoIcons.tag_circle),
                    )
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text.trim();
                    if (text.isNotEmpty) {
                      messageCubit.sendMessage(widget.currentUser, text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
