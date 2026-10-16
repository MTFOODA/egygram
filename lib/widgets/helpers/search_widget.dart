import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/love/get_love_logic/cubit.dart';
import '../../logics/save/create_save_logic/cubit.dart';
import '../../logics/save/get_save_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../navigation/reel_page.dart';
import '../post/post_details_page.dart';

Future<void> searchById({
  required BuildContext context,
  required String postId,
  required String currentUser,
  required TextEditingController controller,
}) async {
  try {
    final post = await sl.postRepository.getPost(postId);
    final reel = post == null ? await sl.reelRepository.getReel(postId) : null;

    if (post != null) {
      controller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => GetUserCubit()..getUsers()),
              BlocProvider(create: (context) => GetLoveCubit()),
              BlocProvider(create: (context) => CreateLoveCubit()),
              BlocProvider(create: (context) => GetSaveCubit()),
              BlocProvider(create: (context) => CreateSaveCubit()),
            ],
            child: PostDetailsPage(
              currentUser: currentUser,
              posts: post,
            ),
          ),
        ),
      );
      return;
    }

    if (reel != null) {
      controller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => GetUserCubit()..getUsers()),
              BlocProvider(create: (context) => GetLoveCubit()),
              BlocProvider(create: (context) => CreateLoveCubit()),
              BlocProvider(create: (context) => GetSaveCubit()),
              BlocProvider(create: (context) => CreateSaveCubit()),
            ],
            child: ReelPage(
              currentUser: currentUser,
              reelId: reel.reelID, // Pass the reel ID here
            ),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No matching item found with the given ID'.tr()),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error retrieving item: $e'),
      ),
    );
  }
}
