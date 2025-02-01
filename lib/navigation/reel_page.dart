import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/logics/user/get_user_logic/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../logics/love/create_love_logic/cubit.dart';
import '../logics/love/get_love_logic/cubit.dart';
import '../logics/reel/get_reel_logic/cubit.dart';
import '../logics/reel/get_reel_logic/state.dart';
import '../logics/save/create_save_logic/cubit.dart';
import '../logics/save/get_save_logic/cubit.dart';
import '../models/reel_model.dart';
import '../utilities/colors_dart.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/reel/reel_widget.dart';

class ReelPage extends StatelessWidget {
  final String currentUser;
  final String? reelId;

  const ReelPage({super.key, required this.currentUser, this.reelId}); // Modify this line

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetReelCubit()..subscribeToReels()),
        BlocProvider(create: (context) => GetLoveCubit()),
        BlocProvider(create: (context) => CreateLoveCubit()),
        BlocProvider(create: (context) => GetSaveCubit()),
        BlocProvider(create: (context) => GetUserCubit()),
        BlocProvider(create: (context) => CreateSaveCubit()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: BlocBuilder<GetReelCubit, GetReelsState>(
          builder: (context, state) {
            if (state is GetReelLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetReelSuccessState) {
              if (state.reels.isNotEmpty) {
                return ReelPageView(
                  reels: state.reels,
                  currentUser: currentUser,
                  initialReelId: reelId, // Pass the reelId to the PageView
                );
              } else {
                return Center(
                  child: Text(
                    'No Reels found'.tr(),
                    style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold,
                  ),
                );
              }
            } else if (state is GetReelErrorState) {
              return Center(
                child: Text(
                  'Error: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return Center(
                child: Text(
                  'No Reels found'.tr(),
                  style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ReelPageView extends StatefulWidget {
  final List<ReelsModel> reels;
  final String currentUser;
  final String? initialReelId;

  const ReelPageView({
    super.key,
    required this.reels,
    required this.currentUser,
    this.initialReelId,
  });

  @override
  ReelPageViewState createState() => ReelPageViewState();
}

class ReelPageViewState extends State<ReelPageView> {
  late PageController _pageController;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    // Find the index of the reel with the given ID
    if (widget.initialReelId != null) {
      _initialPage = widget.reels.indexWhere((reel) => reel.reelID == widget.initialReelId);
      if (_initialPage == -1) _initialPage = 0; // Fallback to the first reel if not found
    }
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.reels.length,
      itemBuilder: (context, index) {
        return ReelWidget(
          reels: widget.reels[index],
          currentUser: widget.currentUser,
        );
      },
    );
  }
}
