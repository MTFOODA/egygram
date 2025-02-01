import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/cubit.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/state.dart';
import 'package:flutter_application_3/logics/save/get_save_logic/cubit.dart';
import 'package:provider/provider.dart';
import '../logics/love/create_love_logic/cubit.dart';
import '../logics/love/get_love_logic/cubit.dart';
import '../logics/love/get_love_logic/state.dart';
import '../logics/save/create_save_logic/cubit.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/post/post_widget.dart';

class LovedPostsScreen extends StatelessWidget {
  final String currentUser;

  const LovedPostsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Loved Posts".tr(),
            style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetLoveCubit()..getLoves(currentUser)),
          BlocProvider(create: (context) => GetPostCubit()..subscribeToPosts()),
          BlocProvider(create: (context) => GetSaveCubit()),
          BlocProvider(create: (context) => CreateLoveCubit()),
          BlocProvider(create: (context) => CreateSaveCubit()),
        ],
        child: BlocBuilder<GetLoveCubit, GetLovesState>(
          builder: (context, loveState) {
            if (loveState is GetLoveLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (loveState is GetLoveSuccessState) {
              final currentUserLoves = loveState.loves
                  .where((love) => love.userName == currentUser)
                  .toList();

              if (currentUserLoves.isEmpty) {
                return Center(
                  child: Text('No Loved posts found'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                );
              }

              final lovedPostIds = currentUserLoves.map((love) => love.postId).toList();
              final postIdsText = lovedPostIds.join(' , ');

              return BlocBuilder<GetPostCubit, GetPostsState>(
                builder: (context, postState) {
                  if (postState is GetPostLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (postState is GetPostSuccessState) {
                    final lovedPosts = postState.posts
                        .where((post) => postIdsText.contains(post.postID))
                        .toList();

                    if (lovedPosts.isEmpty) {
                      return Center(
                        child: Text('No matching Loved posts found'.tr()),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: lovedPosts.length,
                      itemBuilder: (context, index) {
                        return PostWidget(
                          posts: lovedPosts[index],
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
                      child: Text('No posts found'.tr(),
                          style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                    );
                  }
                },
              );
            } else if (loveState is GetLoveErrorState) {
              return Center(
                child: Text(
                  'Error: ${loveState.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return Center(
                child: Text('Error loading Loved posts'.tr()),
              );
            }
          },
        ),
      ),
    );
  }
}
