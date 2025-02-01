import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../logics/user/edit_user_logic/cubit.dart';
import '../logics/user/edit_user_logic/state.dart';
import '../models/user_model.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import 'navigation_screen.dart';

class EditProfilePage extends StatefulWidget {
  final UsersModel userModel;

  const EditProfilePage({super.key, required this.userModel});

  @override
  State<EditProfilePage> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController userNameController =
  TextEditingController(text: widget.userModel.userName);
  late TextEditingController bioController =
  TextEditingController(text: widget.userModel.bio);
  late TextEditingController websiteController =
  TextEditingController(text: widget.userModel.webpage);
  late TextEditingController emailController =
  TextEditingController(text: widget.userModel.email);
  late TextEditingController phoneController =
  TextEditingController(text: widget.userModel.phone);
  late String selectedGender = widget.userModel.gender ?? 'None';
  File? pickedImage;

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadProfileImage(File image, String userName) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref().child("profileImages/$userName/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  void editUser(BuildContext context) async {
    String? imageUrl;
    if (pickedImage != null) {
      imageUrl = await uploadProfileImage(pickedImage!, widget.userModel.userName);
    }

    final updatedUser = UsersModel(
      userName: userNameController.text,
      bio: bioController.text,
      webpage: websiteController.text,
      email: emailController.text,
      phone: phoneController.text,
      gender: selectedGender,
      profileImage: imageUrl ?? widget.userModel.profileImage,
    );

    await BlocProvider.of<EditUserCubit>(context)
        .editUser(widget.userModel.userName, updatedUser);

    final state = BlocProvider.of<EditUserCubit>(context).state;
    if (state is EditUserSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(initialIndex: 0,userName: widget.userModel.userName),
        ),
            (Route<dynamic> route) => false,
      );
    } else if (state is EditUserErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Profile'.tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
        actions: [
          TextButton(
            onPressed: () => editUser(context),
            child: Text(
              'Done'.tr(),//TODO
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: pickedImage != null
                        ? FileImage(pickedImage!)
                        : widget.userModel.profileImage != null
                        ? NetworkImage(widget.userModel.profileImage!)
                        : const AssetImage('assets/images/profile_picture.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: const CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                enabled: false,
                labelText: "User Name".tr(),//TODO
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: websiteController,
              decoration: InputDecoration(
                labelText: 'Website'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: 'Bio'.tr(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 15.0),
            Text(
              'Private Information'.tr(),
              style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: [
                DropdownMenuItem(value: 'None', child: Text('None'.tr())),
                DropdownMenuItem(value: 'Male', child: Text('Male'.tr())),
                DropdownMenuItem(value: 'Female', child: Text('Female'.tr())),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedGender = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Gender'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
