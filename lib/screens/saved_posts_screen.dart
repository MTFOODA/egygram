import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/cubit.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/state.dart';
import 'package:flutter_application_3/logics/save/get_save_logic/cubit.dart';
import 'package:flutter_application_3/logics/save/get_save_logic/state.dart';
import 'package:provider/provider.dart';
import '../logics/love/create_love_logic/cubit.dart';
import '../logics/love/get_love_logic/cubit.dart';
import '../logics/save/create_save_logic/cubit.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/post/post_widget.dart';

class SavedPostsScreen extends StatelessWidget {
  final String currentUser;

  const SavedPostsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Posts".tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetSaveCubit()..getSaves(currentUser)),
          BlocProvider(create: (context) => GetPostCubit()..subscribeToPosts()),
          BlocProvider(create: (context) => GetLoveCubit()),
          BlocProvider(create: (context) => CreateLoveCubit()),
          BlocProvider(create: (context) => CreateSaveCubit()),
        ],
        child: BlocBuilder<GetSaveCubit, GetSavesState>(
          builder: (context, saveState) {
            if (saveState is GetSaveLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (saveState is GetSaveSuccessState) {
              final currentUserSaves = saveState.saves
                  .where((save) => save.userName == currentUser)
                  .toList();

              if (currentUserSaves.isEmpty) {
                return Center(
                  child: Text('No saved posts found'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                );
              }

              final savedPostIds = currentUserSaves.map((save) => save.postId).toList();
              final postIdsText = savedPostIds.join(' , ');

              return BlocBuilder<GetPostCubit, GetPostsState>(
                builder: (context, postState) {
                  if (postState is GetPostLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (postState is GetPostSuccessState) {
                    final savedPosts = postState.posts
                        .where((post) => postIdsText.contains(post.postID))
                        .toList();

                    if (savedPosts.isEmpty) {
                      return Center(
                        child: Text('No matching saved posts found'.tr()),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: savedPosts.length,
                      itemBuilder: (context, index) {
                        return PostWidget(
                          posts: savedPosts[index],
                          currentUser: currentUser,
                        );
                      },
                    );
                  } else if (postState is GetPostErrorState) {
                    return Center(
                      child: Text(
                        'Error: ${postState.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text('No posts found'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                    );
                  }
                },
              );
            } else if (saveState is GetSaveErrorState) {
              return Center(
                child: Text(
                  'Error: ${saveState.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return Center(
                child: Text('Error loading saved posts'.tr()),
              );
            }
          },
        ),
      ),
    );
  }
}
